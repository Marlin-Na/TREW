## Predefined Arguments
jbrowse.url <- 'http://180.208.58.19/jbrowse'  # "./jbrowse"






function(input, output, session) {
  tb1 <- eventReactive(input$button,{Tb1(
    idx_3 = Into_var(paste(
      paste(input$mod,input$pro,input$spes,input$lift,input$celline,input$teq,sep = "_&")
      ,"_",sep = "")),
      idx_2 = Into_var(paste(
          paste(input$rtyp,input$rreg,input$motif,stat_tf(input$stat_sig),input$consis,input$stop,sep = "_&")
          ,"_",sep = "")),
    Gene_ID = input$gene
  )
}
)
  tb2 <- reactive({Tb2(tb1())})
  
  output$table <- DT::renderDataTable(Tb_DT(tb2(), 
                                            main = "Summary Table (select rows to show specific ones)",
                                      collab = c("Regulator","Target_Gene"," Type","Mark","Positive_#","Reliability"),
                                      responsive = NULL),
                                      server = TRUE)
   
  tb3 <- eventReactive(input$table_rows_selected,{Tb3(Tb1 = tb1(),
                                                      Tb2 = tb2(),
                                                      Select_Number = as.numeric(input$table_rows_selected))})
  output$table2 <- DT::renderDataTable(Tb_DT(tb3(), 
                                             main = "Specific Table with genomic location"), 
                                       server = TRUE)
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste(input$mod, '.csv', sep='') 
    },
    content = function(file) {
      write.csv(tb1(), file)
    }
  )


  DTinfo <- reactiveValues()

  observeEvent(input$table_rows_selected, {
    ## For test
    print(paste('T_rows_selected class:',class(input$table_rows_selected)))
    print(paste('T_rows_selected value:',input$table_rows_selected))
    
    DTinfo$RangeType <- 'gene'
    
    updateSelectInput(
      inputId = 'inGenome',
      label = 'Available Genomes',
      session = session,
      choices = getAvlGenomes(tb3()[,'Genome_assembly'])
    )
    
## TO Read the gene range from a preprocessed file    
#
#    DTinfo$Genome <- input$inGenome
#    DTinfo$Chromosome <- 
#    DTinfo$Start <- 
#    DTinfo$Width <- 
#    DTinfo$Tracks <- getTracks(
#      DataSets = tb3()[,'Source_ID'],
#      PrimaryTracks = 'gene_model'
#    )
  })

  ## When the table of sites is clicked
  observeEvent(input$table2_rows_selected, {
    ## For test
    print(paste('T2_rows_selected class:',class(input$table2_rows_selected)))
    print(paste('T2_rows_selected value:',input$table2_rows_selected))
      
    DTinfo$RangeType <- 'site'

    updateSelectInput(
      inputId = 'inGenome',
      label = 'Available Genomes',
      session = session,
      choices = getAvlGenomes(tb3()[input$table2_rows_selected,'Genome_assembly'])
    )
    
    DTinfo$Genome <- input$inGenome
    DTinfo$Chromosome <- tb3()[input$table2_rows_selected,'Chromosome']
    DTinfo$Start <- tb3()[input$table2_rows_selected,'Range_Start']
    DTinfo$Width <- tb3()[input$table2_rows_selected,'Range_Width']
    DTinfo$Tracks <- getTracks(
      DataSets = tb3()[input$table2_rows_selected,'Source_ID'],
      PrimaryTracks = 'DNA,gene_model'
    )
    
  })

  ## Jbrowse output UI
  output$outJbrowse <- renderUI({
    # TODO: validate status

    getLinkJbrowse (
      Genome = DTinfo$Genome,
      Chromosome = DTinfo$Chromosome,
      Range = getRange(Start = DTinfo$Start, 
                       Width = DTinfo$Width),
      HighLight = getHighLight(Start = DTinfo$Start,
                               Width = DTinfo$Width),
      Tracks = DTinfo$Tracks,
      BaseUrl = jbrowse.url
    ) %>%
    getIframeJbrowse ()
  })


}




