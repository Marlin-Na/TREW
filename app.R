################################################################################
# TREW_0.3.2_2016.9.6
# Database version: TREW_0.2.1
# fluidPage
# Input_Gene name (fuzzy search), species, target, modification, content type.
# Output_Table with select and download function.
################################################################################

library(shiny)
library(sqldf)
library(RMySQL)
library(DT)

#### Load the database.
#db <- dbConnect(MySQL(), dbname="TREW", username = "root", password = "yumenwh3920851")
db <- dbConnect(SQLite(), dbname= "TREW.db")
Genome_Location <- dbReadTable(db, "Genome_Location")
Sites_Info <- dbReadTable(db, "Sites_Info")
Source_Info <- dbReadTable(db, "Source_Info")
#Gene_C <- unique(tolower(Sites_Info$Gene_ID))
#### Generate the indexes.
idx_2to1 = table(Genome_Location$Meth_Site_ID)
idx_3to2 = table(Sites_Info$Source_ID)[Source_Info$DataSet_ID]
idx_3to1 = table(rep(Sites_Info$Source_ID,idx_2to1))[Source_Info$DataSet_ID]
#### Load the functions.
#==#1.Search and generate full table (With the Record_quantity column).
GenerateFull <- function(Species = NULL, 
                         Target = NULL, 
                         Modification = NULL, 
                         Gene_ID = NULL,
                         Liftover = NULL)
{# Join the tables through indexes.
    idx2 = !vector(length = dim(Sites_Info)[1])
    idx3 = !vector(length = dim(Source_Info)[1])
    # Option-Species.
    if (!is.null(Species) & Species != "All of following") {
        idx3 <- Source_Info$Species == Species
    }else{}
    # Option-Regulation type.
    if (Target == "Regulator") {
        idx3 <- idx3 & (Source_Info$Target != "YTHDF1" & Source_Info$Target != "YTHDF2" &
                            Source_Info$Target != "YTHDC1")
    }else{
        if (Target == "Regulatee") {
            idx3 <- idx3 & (Source_Info$Target == "YTHDF1" | Source_Info$Target == "YTHDF2" |
                                Source_Info$Target == "YTHDC1")
        }else{}
    }
    # Option-Modification type.
    if (!is.null(Modification) & Modification != "All of following") {
        idx3 <- idx3 & (Source_Info$Modification == Modification)
    }else{}
    
    # Fuzzy search function.
    #if (length(grep(Gene_ID, Sites_Info$Gene_ID, ignore.case = TRUE, value = TRUE)) != 0 &
    #    nchar(Gene_ID) != 0) {
    if (length(grep(Gene_ID, Sites_Info$Gene_ID, ignore.case = TRUE, value = TRUE)) != 0) {
        Fuzzy_Gene <- grep(Gene_ID, Sites_Info$Gene_ID, ignore.case = TRUE, value = TRUE)
        idx2 <- (tolower(Sites_Info$Gene_ID) == tolower(Fuzzy_Gene)) & rep(idx3,idx_3to2)
    } else {
        idx2 <- (tolower(Sites_Info$Gene_ID) == tolower(Sites_Info$Gene_ID)) & rep(idx3,idx_3to2)
    }
    # Merge the table.
    idx2[which(is.na(idx2))] <- FALSE
    
    idx1 <- rep(idx2,idx_2to1)
    
    Full_table <- cbind(Genome_Location[which(idx1),],
                        Sites_Info[rep(which(idx2),idx_2to1[which(idx2)]),],
                        Source_Info[rep(1:dim(Source_Info)[1],idx_3to1)[which(idx1)],])
    # Option-Liftover.
    if (Liftover == "No") {
        Full_table <- Full_table[which(is.na(Full_table[,"LiftOver"])),]
    }else{}
    # Add column-Positivity.
    Positivity <- vector(mode = "character", length = length(Full_table[,"Target"]))
    
    for (i in 1:length(Full_table[,"Target"])) {
        if (Full_table[i, "Diff_fdr"] < 0.05) {
            Positivity[i] <- "Positive"
        } else {
            Positivity[i] <- "Negative"
        }
    }
    # Add column-Record_Q.
    Full_table <- cbind(Full_table, Positivity)
    
    Record_Q <- vector(mode = "integer", length = length(Full_table[,"Target"]))
    
    for (i in 1:length(Full_table[,"Target"])) {
        Record_Q[i] <- length(which(Full_table[,"Target"] == Full_table[,"Target"][i] & 
                                        Full_table[,"Modification"] == Full_table[,"Modification"][i] &
                                        Full_table[,"Gene_ID"] == Full_table[,"Gene_ID"][i]))
    }
    # Add column-Consistency_Q.
    Consistent_Q <- vector(mode = "integer", length = length(Full_table[,"Target"]))
    
    for (i in 1:length(Full_table[,"Target"])) {
        Consistent_Q[i] <- length(which(Full_table[,"Target"] == Full_table[,"Target"][i] & 
                                            Full_table[,"Modification"] == Full_table[,"Modification"][i] &
                                            Full_table[,"Gene_ID"] == Full_table[,"Gene_ID"][i] &
                                            Full_table[,"Consistency"] == 1))
    }
    # Add column-Positive_Q.
    Positive_Q <- vector(mode = "integer", length = length(Full_table[,"Target"]))
    
    for (i in 1:length(Full_table[,"Target"])) {
        Positive_Q[i] <- length(which(Full_table[,"Target"] == Full_table[,"Target"][i] & 
                                          Full_table[,"Modification"] == Full_table[,"Modification"][i] &
                                          Full_table[,"Gene_ID"] == Full_table[,"Gene_ID"][i] &
                                          Full_table[,"Positivity"] == "Positive"))
    }
    
    Full_table <- cbind(Full_table, Positive_Q, Consistent_Q, Record_Q)
    # Add column-Negative_Q.
    Negative_Q <- vector(mode = "integer", length = length(Full_table[,"Target"]))
    
    for (i in 1:length(Full_table[,"Target"])) {
        Negative_Q[i] <- Full_table[i,"Record_Q"] - Full_table[i,"Positive_Q"]
    }
    
    Full_table <- cbind(Full_table, Negative_Q)
    # Add column-Positivity_percent.
    Positivity_percent <- vector(mode = "numeric", length = length(Full_table[,"Target"]))
    
    for (i in 1:length(Full_table[,"Target"])) {
        
        Positivity_P <- Full_table[i,"Positive_Q"] / Full_table[i,"Record_Q"]
        
        Positivity_percent[i] <- paste(round(Positivity_P*100, digits = 2), "%", sep = '')
    }
    
    Full_table <- cbind(Full_table, Positivity_percent)
    # Remove useless columns.
    Full_table[, c("Note_t1")] <- NULL                       ############################### 
    Full_table[, c("Note_t2")] <- NULL                       ############################### 
    Full_table[, c("Note_t3")] <- NULL 
    # Assign row names.
    rownames(Full_table) <- 1:length(Full_table[, "Target"])
    Full_table
}

#==#2.Generate the general DT table with Record_quantity marked.
GenerateGeneral <- function(Species2 = NULL, 
                            Target2 = NULL, 
                            Modification2 = NULL, 
                            Gene_ID2 = NULL,
                            Liftover2 = NULL)
{# Generate full table.
    FullTable <- GenerateFull(Species = Species2, 
                              Target = Target2, 
                              Modification = Modification2, 
                              Gene_ID = Gene_ID2,
                              Liftover = Liftover2)
    # Extract needed columns.
    FullGeneral <- FullTable[, c("Gene_ID" ,"Target", "Target_type", "Modification", "Record_Q", "Positivity_percent", 
                                 "Positive_Q", "Negative_Q", "Consistent_Q")]
    colnames(FullGeneral)[3] <- "Function"
    colnames(FullGeneral)[5] <- paste("Record", "#", sep = "")
    colnames(FullGeneral)[6] <- paste("Positivity", "%", sep = "")
    colnames(FullGeneral)[7] <- paste("Positive", "#", sep = "")
    colnames(FullGeneral)[8] <- paste("Negative", "#", sep = "")
    colnames(FullGeneral)[9] <- paste("Consistent", "#", sep = "")
    # Generate unique general table.
    UniqueGeneral <- unique(FullGeneral)
}

#==#3.Generate the specific tables (Default & Completed) which were selected.
GenerateSpecific <- function(Species2 = NULL, 
                             Target2 = NULL, 
                             Modification2 = NULL, 
                             Gene_ID2 = NULL,
                             Liftover2 = NULL,
                             Content = "Default",
                             Positivity_choice = NULL,
                             GeneralTable = NULL,
                             Select_Number = NULL)
{# Generate full table.
    FullTable <- GenerateFull(Species = Species2, 
                              Target = Target2, 
                              Modification = Modification2, 
                              Gene_ID = Gene_ID2,
                              Liftover = Liftover2)
    
    Select_Target <- GeneralTable[Select_Number, "Target"]
    Select_Modification <- GeneralTable[Select_Number, "Modification"]
    Select_Gene <- GeneralTable[Select_Number, "Gene_ID"]
    
    FullSpecific <- FullTable[which(FullTable[,"Target"] %in% Select_Target & 
                                        FullTable[,"Modification"] %in% Select_Modification &
                                        FullTable[,"Gene_ID"] %in% Select_Gene),]
    
    if (Positivity_choice == "Only positive results") {
        FullSpecific <- FullSpecific[which(FullSpecific[, "Positivity"] == "Positive"),]
    } else {}
    
    if (Content == "Default") {
        FullSpecific <- FullSpecific[, c("Genome_assembly", "Cell_line", "Target", "Modification", 
                                         "Technique", "Positivity", "Consistency", "Meth_Site_ID", 
                                         "Source_ID")]
    } else {
        FullSpecific <- FullSpecific[, c("Species",	"Genome_assembly", "Gene_ID", "Meth_Range_ID", "Chromosome", 
                                         "Strand", "Range_start", "Range_width", "Methylation_ID", "Source_ID",	
                                         "Modification", "Technique", "Target", "Target_type", "Perturbation", 
                                         "Cell_line", "Treatment", "LiftOver", "Diff_p_value", "Diff_fdr", 
                                         "Positivity", "Log2_RPKM_Wt", "Log2_RPKM_Treated", "Diff_log2FoldChange", 
                                         "Consistency", "Overlap_UTR5", "Overlap_CDS", "Overlap_UTR3", 
                                         "Overlap_mRNA", "Overlap_lncRNA", "Overlap_sncRNA", "Overlap_tRNA", 
                                         "Overlap_miRNA", "Overlap_miRNATS", "Distance_ConsensusMotif", 
                                         "Distance_StartCodon", "Distance_StopCodon", "Paper", "Computation_pepline", 
                                         "Date_of_process")]
    }
    DT::datatable(FullSpecific, rownames= FALSE, filter = "top",
                  extensions = list("ColReorder" = NULL,
                                    "Buttons" = NULL,
                                    "FixedHeader" = NULL,
                                    "Scroller" = NULL),
                  options = list(
                      scrollX = TRUE,
                      deferRender = TRUE,
                      scrollY = 400,
                      scroller = TRUE,
                      dom = 'BRrlftpi',
                      autoWidth=TRUE,
                      fixedHeader = TRUE,
                      lengthMenu = list(c(10, 50, -1), c('10', '50', 'All')),
                      ColReorder = TRUE,
                      buttons =
                          list(
                              'copy',
                              'print',
                              list(
                                  extend = 'collection',
                                  buttons = c('csv', 'excel'),
                                  text = 'Download'
                              ),
                              I('colvis')
                          )
                  ))
}


#############################################################################################
#### UI
ui <- shinyUI(fluidPage(
    #theme = "lowdown.css",
    #includeCSS("fonts.css"),
    titlePanel("TREW"),
    navlistPanel("Home", widths = c(2, 10),
        tabPanel("Introduction", value = "intro",
            h2("Welcome to TREW"),
            h3("Epitranscriptomic targets of RNA modification readers, erasers and writers"),
            br(),
            hr(),
            p("In eukaryotic cells, the control of mRNA translation and degradation 
              is critical for managing the quantity and duration of gene expression. 
              Global translation regulation is typically achieved by modulating both 
              the activity of translation initiation factors and the availability of 
              ribosomes. Several process, including cell growth, division, and differentiation, 
              are mediated by RNA-binding proteins and small complementary RNAs (microRNAs 
              and short interfering RNAs)."),
            br(),
            br(),
            p("However, as indicated by most recent evidence, dynamic modifications of mRNA, 
              including 5-methylcytidine, pseudouridine, and N6-methyladenosinde, have emerged 
              as potential new mechanisms of post-transcriptional gene regulation. Three types 
              of proteins, methyltransferases, demethylases and specific binding proteins, which 
              are also called writers, erasers and readers, are involved in these mechanisms."),
            br(),
            br(),
            p("This database, TREW, focus on the epitranscriptomic targets of RNA modification 
              readers, erasers and writers and it consists of specific details of the targets of 
              RNA modification. Users could easily obtain the detailed targets information by 
              using the Search function and get an intuitive impression with the Visualization function.")
        ),
        "Function",
        tabPanel("Querying", value = "query",
            fluidRow(
                column(width = 6, offset = 4,
                       h2("TREW Database Search"))
            ),
            fluidRow(
                column(width = 6, offset = 3,
                       textInput("Gene_choice", "", width = 600, placeholder = "e.g CDK1")),
                column(width = 3,
                       actionButton(inputId = 'submit_gene',label = 'Submit'))
            ),
            fluidRow(
                column(width = 6, offset = 3,
                       helpText("•Please input a gene symbol in the search box above."), 
                       helpText("•The incomplete symbol could be identified by this search engine."),
                       helpText("•The search process will take several seconds. Thanks for your patient waiting."))
            ),
            hr(),
            fluidRow(
                column(width = 8,
                       DT::dataTableOutput("G_Table")),
                column(width = 4,
                       h4("Advanced options"),
                       helpText("The following options could help you to screen out the needed data."),
                       hr(),
                       selectInput("Species_choice", "Species", c("All of following", "Homo sapiens","Drosophila melanogaster", 
                                                                  "Mus musculus")),
                       selectInput("Regulation_choice", "Regulation type", c("Both of following", "Regulator", "Regulatee")),
                       selectInput("Modification_choice", "Modification type", c("All of following", "m6A","m1A", "m5C", "Psi")),
                       selectInput("Liftover_choice", "Conversion", c("Yes", "No")))
            ),
            hr(),
            helpText("Choose and select the row(s) you are interested in the above table, then you can check the detailed data 
                     from the table below."),
            hr(),
            fluidRow(
                column(width = 8,
                       DT::dataTableOutput("S_Table")),
                column(width = 4,
                       helpText("☜ Search within returned table"),
                       hr(),
                       helpText("☟ Please indicate the content of the specific table and whether to present the negative results."),
                       selectInput("Content_choice", "Output table content", c("Default", "Completed")),
                       selectInput("Positivity_choice", "Positivity", c("Only positive results", "All of results")),
                       hr(),
                       helpText("☜ This table could be copy, print and download by clicking the buttons at the top-left corner. The 
                                button 'Column visibility' could be used to hide the column(s) you are not interested."))
            )
        ),
        tabPanel("Visualization", value = "viz",
                 h3("Coming soon...")),
        "About",
        tabPanel("Help", value = "help",
            h2("How to use the query engine"),
            br(),
            hr(),
            h3("Search box"),
            "A gene symbol is required to be typed in the search box to retrieve the information in the database. Incomplete symbol 
            could be automatically matched to the gene symbols which consist of the inputted character(s) since the search engine 
            supports fuzzy search. The initial loading of the generated table would take several seconds.",
            hr(),
            h3("Options"),
            "• ", strong("Species"), ": TREW supports three species, including human, fly and mouse (", em('Homo sapiens'), ", ", 
            em('Drosophila melanogaster'), "and ", em('Mus musculus'), "). In the default setting, the engine searches data among 
            all of the three species.",
            br(),
            br(),
            "• ", strong("Regulation type"), ": The target proteins could be classified into regulators and regulates. Regulators 
            function as writer or eraser, while regulates as reader. Both of the two types would be present as default.",
            br(),
            br(),
            "• ", strong("Modification type"), ": Four modification types, m6A, m1A, m5C and Psi, could be select and the default 
            setting is all of them.",
            br(),
            "m6A: N6-methyladenosine",
            br(),
            "m1A: N1-methyladenosine",
            br(),
            "m5C: 5-methylcytosine",
            br(),
            "Psi: pseudouridine",
            br(),
            br(),
            "• ", strong("Conversion"), ": Whether to present the data that converting genome coordinates and genome annotation 
            files between assemblies (Default to present).",
            br(),
            hr(),
            h2("Contact information"),
            br(),
            strong("Hao Wu"),
            br(),
            "Hao.Wu13@student.xjtlu.edu.cn",
            br(),
            "Department of Biology Science",
            br(),
            "Xi'an Jiaotong - Liverpool Unversity",
            br(),
            br(),
            strong("Zhen Wei"),
            br(),
            "Zhen.Wei@xjtlu.edu.cn",
            br(),
            "Department of Biology Science",
            br(),
            "Xi'an Jiaotong - Liverpool Unversity",
            br(),
            br(),
            br()
        )
    )
))

###########################################################################################
#### Server
server <- shinyServer(function(input, output) {
    #Generate and output the general table.
    General_Table <-
        eventReactive(input$submit_gene,{
            GenerateGeneral(
                Species2 = input$Species_choice,
                Target2 = input$Regulation_choice,
                Modification2 = input$Modification_choice,
                Gene_ID2 = input$Gene_choice,
                Liftover2 = input$Liftover_choice
            )
        })
    DT_General_Table <-
        reactive({
            DT::datatable(
                General_Table(),
                rownames = FALSE,
                options = list(
                    scrollX = TRUE,
                    deferRender = TRUE,
                    scrollY = 340,
                    dom = 'lrtip',
                    autoWidth = TRUE,
                    ColReorder = TRUE
                )
            )
        })
    output$G_Table <-
        DT::renderDataTable(DT_General_Table(), server = TRUE)
    #Select the Records and generate the specific tables (Default & Competed).
    Select_number <-
        reactive({
            as.numeric(input$G_Table_rows_selected)
        })
    
    Specific_Table <-
        reactive({
            GenerateSpecific(
                Species2 = input$Species_choice,
                Target2 = input$Regulation_choice,
                Modification2 = input$Modification_choice,
                Gene_ID2 = input$Gene_choice,
                Liftover2 = input$Liftover_choice,
                Content = input$Content_choice,
                Positivity_choice = input$Positivity_choice,
                GeneralTable = General_Table(),
                Select_Number = Select_number()
            )
        })
    
    output$S_Table <-
        DT::renderDataTable(Specific_Table(), server = TRUE)
})


#### Run the application 
shinyApp(ui = ui, server = server)
