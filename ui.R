fluidPage(theme = "Yeti.css",
  navbarPage(title = 'TREW',
    tabPanel('Query',
      titlePanel("TREW: search epitranscriptomic target of reader, eraser, and writer"),
      hr(),
      textInput("gene", NULL, width = 600, placeholder = "Please input gene symbol."),
      actionButton("button", "Search"),
      actionButton("more", "More options."),
      #Fluid Row 1#===========================================================================
      conditionalPanel(
        condition = "input.more % 2 == 1",
        hr(),
        fluidRow(
          #Column 1#####################################
          column(3,
                 selectInput("mod",
                             "Marks:",
                             c("All",unique(Table3$Modification)))
          ),
          #Column 2#####################################
          column(3,
                 selectInput("pro",
                             "Regulators:",
                             c("All","Reader","Writer","Eraser",unique(Table3$Target)))
          ),
          #Column 3#####################################
          column(3,selectInput("spes",
                               "Species:",
                               c("All",unique(Table3$Species))
          )
          ),
          #Column 4#####################################
          column(3,selectInput("lift",
                               "Include liftover",
                               c("Yes","No")
          )
          )
        ),
        #Fluid row 2#====================================================================
        fluidRow(
          #Column 1#####################################
          column(3,
                 selectInput("rtyp",
                             "RNA types:",
                             c("All","mRNA","lncRNA","sncRNA","tRNA","miRNA")
                 )
          ),
          #Column 2######################################
          column(3,
                 selectInput("rreg",
                             "RNA regions:",
                             c("All","UTR5","CDS","UTR3","miRNATS")
                 )
          ),
          #Column 3#####################################
          column(3,
                 selectInput("celline",
                             "Cell lines:",
                             c("All","S2","Hek293T","MEF","Mouse 3T3L1","Mouse Mid Brain","A549","Hela Cell","Mouse ESC", "HEF")
                 )
          ),
          #Column 4######################################
          column(3,
                 selectInput("teq",
                             "Technique",
                             c("All",unique(Table3$Technique))
                 )
          )
        ),
        #Fluid row 3#===================================================================
        fluidRow(
          #Column 1#####################################
          column(3,
                 selectInput("stat_sig",
                             "Statistical significance",
                             c("No filter","p < .05","p < .01","fdr < .05","fdr < .01")
                 )
          ),
          #Column 2#####################################
          column(3,
                 selectInput("consis",
                             "Consistency",
                             c("No filter","Consistent sites only")
                 )
          ),
          #Column 3######################################
          column(3,
                 selectInput("motif",
                             "Motif restriction",
                             c("No filter","Motif restriction")
                 )
          ),
          #Column 4######################################
          column(3,
                 selectInput("stop",
                             "Stop codon restriction",
                             c("No filter","On top stop codon")
                 )
          )
        ),

        fluidRow(
          br(),
          column(12,
                 downloadButton('downloadData', 'Download all the results returned by the query (including those not selected).')
          )
        )
      ),

      conditionalPanel(
      condition = "input.button >= 1",
      hr(),
      h3("Query results:"),
      br()
      ),

      #Fluid row 3#================================================================
      fluidRow(
        #Column 1#####################################
        column(6,
          DT::dataTableOutput("table")
        ),
        #Column 2#####################################
        column(6,
         DT::dataTableOutput("table2")
        )
      ),

      #Fluid row 4#================================================================
      conditionalPanel(
        condition = "input.button >= 1",
        hr(),
        htmltools::a("All Rights Reserved.")
      )
    ),

    tabPanel('Help',
             includeMarkdown("documentation.md")
    )
  # #===========================End fluid Page=================================
  )
)


