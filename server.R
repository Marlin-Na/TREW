##---------------------------------
## Defined arguments
df.genes <- readRDS('dataframe_genes.Rds') # the object is used for generate jbrowse link
jbrowse.url <- 'http://180.208.58.19/jbrowse' # If the jbrowse is within the www directory, try './jbrowse'



function(input, output,session) {
    
    tb1 <- eventReactive(input$button, {
        Tb1(
            Target = input$pro,
            Modification = input$mod,
            Gene_ID = input$gene
        )
    })
    
    tb2 <- reactive({
        Tb2(tb1())
    })
    
    output$table <- DT::renderDataTable(Tb2_DT(tb2()), server = TRUE)
    
    tb3 <- eventReactive(input$table_rows_selected, {
        Tb3(
            Tb1 = tb1(),
            Tb2 = tb2(),
            Select_Number = as.numeric(input$table_rows_selected)
        )
    })
    
    output$table2 <- DT::renderDataTable(Tb3_DT(tb3()), server = TRUE)
    
    
    
    
    reGeneID <- reactive({
        which_row <- as.numeric(input$table_row_last_clicked)
        gene <- as.character(tb2()[which_row,]$Gene_ID)
        gene
    })
    
    output$outGene <- renderText(reGeneID())
    
    reModification <- reactive({
        which_row <- as.numeric(input$table_row_last_clicked)
        modification <- as.character(tb2()[which_row,]$Modification)
        modification
    })
    
    # TODO!!
    # Note that in the database the gene name have different letter cases (e.g. CDK9 & Cdk9)
    # This will cause some of the genes have no coorsbonding entry in the stored dataframe
    # from txdb, consider rebuild the database or include the entries
    #
    # Also, some genes do not exist in txdb because the gtf does not have 'transcript' entry
    # of the gene (only has 'exon' entries). Try to fix this.
    
    # Update selectInput of genome assembly (as there might be multiple ones for a gene)
    observeEvent(input$table_row_last_clicked,{
        gene <- reGeneID()
        updateSelectInput(inputId = 'inGenome',label = 'Genome Assembly', session = session,
                          choices = getAvlGenomesFromGene(gene,df.genes))
    })
    
    output$outJbrowse <- renderUI({
        validate(need(reGeneID(),'Click the corresbonding row in the table.'),
                 need(input$inGenome, 'Error: invalid genome assembly'))
        
        getLinkJbrowse(
            Genome = input$inGenome,
            Chromosome = getChromosome(getDfGene(reGeneID(),Genome = input$inGenome,DfGenes = df.genes)),
            Range = getRange(getDfGene(reGeneID(),Genome = input$inGenome,DfGenes = df.genes)),
            Tracks = getTracks(),
            HighLight = getHighLight(getDfGene(reGeneID(),Genome = input$inGenome,DfGenes = df.genes)),
            BaseUrl = jbrowse.url,
            showNav = F,
            showTracklist = F,
            showOverview = F
        ) %>%
        getIframeJbrowse()
    })
}
