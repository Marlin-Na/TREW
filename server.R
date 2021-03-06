## Predefined Arguments
jbrowse.url <- 'http://180.208.58.19/jbrowse'  # "./jbrowse"
df.genes <- readRDS('all.dataframe_genes.Rds')


function(input, output,session) {
  tb1 <- eventReactive(input$button,{Tb1(
    idx_3 = Into_var(paste(
      paste(input$mod,input$pro,input$spes,input$lift,input$celline,input$teq,sep = "_&")
      ,"_",sep = "")),
      idx_2 = Into_var(paste(
          paste(input$rtyp,rreg_tf(input$rreg),input$motif,input$consis,input$stop,sep = "_&")
          ,"_",sep = "")),
    idx_stat = stat_tf(input$stat_sig),
    Gene_ID = input$gene,
    exact = input$exact
  )
}
)
  
  message1 <- eventReactive(input$button,{message_generate1(input$gene,input$exact)})
  
  output$Message1 <- renderUI(message1())
  
  tb2 <- reactive({Tb2(tb1())})
  
  output$table <- DT::renderDataTable(Tb_DT(tb2(), 
                                            main = "Summary Table (select rows to show specific ones)",
                                      collab = c("Regulator","Target_Gene"," Regulator_Type","Mark","Species","Cellline","Technique","Positive_#","Reliability"),
                                      dom = '<"well well-sm"t><Bf>',
                                      class = "compact",
                                      responsive = NULL),
                                      server = TRUE)
  
  message2 <- eventReactive(input$table_rows_selected,{message_generate2(tb2(),input$table_rows_selected)})
  
  output$Message2 <- renderUI(message2())
  
   
  tb3 <- eventReactive(input$table_rows_selected,{Tb3(Tb1 = tb1(),
                                                      Tb2 = tb2(),
                                                      Select_Number = as.numeric(input$table_rows_selected))})
  
  output$table2 <- DT::renderDataTable(Tb_DT(tb3(), 
                                             main = "Specific Table with genomic location, if you want to highlight a particular range, please select the rows below.",
                                             select_setting = list(mode = 'single', target = 'row'),
                                             height = 220,
                                             dom = '<"well well-sm"t><Bf>',
                                             style = "semanticui",
                                             class = "compact"),
                                       server = TRUE)
  
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste(input$mod, '.csv', sep='') 
    },
    content = function(file) {
      write.csv(tb1()[,-c(40)], file)
    }
  )

  observeEvent(input$download.page,{
    updateNavbarPage(session, inputId = 'top.navbar',selected = 'dld')
  })

  #===== Reset all the select Input to default! =================#
  
  observeEvent(input$reset.default,{
  updateSelectInput(session, "mod",
                    label = "Marks:",
                    choices = c("All",unique(Table3$Modification)),
                    selected = "All")
  
    updateSelectInput(session, "pro",
                      label = "Regulators:",
                      c("All","Reader","Writer","Eraser",unique(Table3$Target)),
                      selected = "All")
    
    updateSelectInput(session, "spes",
                      label = "Species:",
                      choices = c("All",unique(Table3$Species)),
                      selected = "All")
  
    updateSelectInput(session, "lift",
                      label = "Include liftover",
                      choices = c("Yes","No"),
                      selected = "Yes")
  
    updateSelectInput(session, "rtyp",
                      label = "RNA types:",
                      choices = c("All","mRNA","lncRNA","sncRNA","tRNA","miRNA"),
                      selected = "All")
  
    updateSelectInput(session, "rreg",
                      label = "RNA regions:",
                      choices = c("All","5'UTR","CDS","3'UTR","miRNA target sites"),
                      selected = "All")
  
    updateSelectInput(session, "celline",
                      label = "Cell lines:",
                      choices = c("All","S2","Hek293T","MEF","Mouse 3T3L1","Mouse Mid Brain","A549","Hela Cell","Mouse ESC", "HEF"),
                      selected = "All")
  
    updateSelectInput(session, "teq",
                      label = "Technique",
                      choices = c("All",unique(Table3$Technique)),
                      selected = "All")
  
    updateSelectInput(session, "stat_sig",
                      label = "Statistical significance",
                      choices = c("p < .05","p < .01","fdr < .05","fdr < .01","No filter"),
                      selected = "p < .05")
  
    updateSelectInput(session, "consis",
                      label = "Consistency",
                      choices = c("No filter","Consistent sites only"),
                      selected = "No filter")
  
    updateSelectInput(session, "motif",
                      label = "Motif restriction",
                      choices = c("No filter","Motif restriction"),
                      selected = "No filter")

    updateSelectInput(session, "stop",
                      label = "Stop codon restriction",
                      choices = c("No filter","On top stop codon"),
                      selected = "No filter")
  })


  DTinfo <- reactiveValues(Status = 0)

  ## When the table of grouped sites is clicked
  observeEvent(input$table_rows_selected, {
    ## For testing purpose
    print(paste('T_rows_selected class:',class(input$table_rows_selected)))
    print(paste('T_rows_selected value:',input$table_rows_selected))
    
    geneDfRows <- df.genes[which(df.genes$gene_id == tb2()$Gene_ID[input$table_rows_selected] &
                                df.genes$genome_assembly == unique(tb3()[ ,'Genome_assembly'])),
                         ]
    DTinfo$GeneDf <- geneDfRows
    
    DTinfo$Genome <- unique(tb3()[,'Genome_assembly']) %>% addNamesForGenomes
    DTinfo$Chromosome <- geneDfRows$seqnames %>% as.character
    DTinfo$GeneStart <- DTinfo$Start <- geneDfRows$start
    DTinfo$GeneWidth <- DTinfo$Width <- geneDfRows$width
    DTinfo$Tracks <- getTracks(
      DataSets = tb3()[,'Source_ID'],
      PrimaryTracks = 'gene_model'
    )
    
    DTinfo$RangeType <- 'gene'
    DTinfo$Status <- DTinfo$Status + 1
  })


  ## When the table of ranges is clicked
  observeEvent(input$table2_rows_selected, {
    ## For testing purpose
    print(paste('T2_rows_selected class:',class(input$table2_rows_selected)))
    print(paste('T2_rows_selected value:',input$table2_rows_selected))

    geneDfRow <- df.genes[which(df.genes$gene_id == tb2()$Gene_ID[input$table_rows_selected] &
                                df.genes$genome_assembly == unique(tb3()[ ,'Genome_assembly']) &
                                matchStrand(df.genes$strand, tb3()[ ,'Strand'])),
                          ]   ## TODO  Note that it is still not guaranteed to be a unique row for gene!
    DTinfo$GeneDf <- geneDfRow
    DTinfo$GeneStart <- geneDfRow$start
    DTinfo$GeneWidth <- geneDfRow$width

    DTinfo$Genome <- unique(tb3()[,'Genome_assembly']) %>% addNamesForGenomes
    DTinfo$Chromosome <- tb3()[input$table2_rows_selected,'Chromosome']
    DTinfo$Start <- tb3()[input$table2_rows_selected,'Range_start']
    DTinfo$Width <- tb3()[input$table2_rows_selected,'Range_width']
    DTinfo$Tracks <- getTracks(
      DataSets = tb3()[input$table2_rows_selected,'Source_ID'],
      PrimaryTracks = 'gene_model'
    )
    
    DTinfo$RangeType <- 'site'
    DTinfo$Status <- DTinfo$Status + 1
  })
  
  
  reJbrowseUI <- eventReactive(DTinfo$Status,{
      getLinkJbrowse(
          Genome = DTinfo$Genome,
          Chromosome = DTinfo$Chromosome,
          Range = getRange(Start = DTinfo$GeneStart, Width = DTinfo$GeneWidth),
          HighLight = getHighLight(Start = DTinfo$Start, Width = DTinfo$Width),
          Tracks = DTinfo$Tracks,
          BaseUrl = jbrowse.url
      ) %>%
      hide_tracklist() %>%
      hide_overview() %>%
      getIframeJbrowse()
  })

  ## Jbrowse output status and navagation
  output$navJbrowse <- renderUI({

      validate(need(DTinfo$GeneDf, 'No corresponding gene.'))

      GeneDf <- DTinfo$GeneDf

      if (nrow(GeneDf) == 1) {
          return(div(
              p(getGenesInfo(GeneDf))
          ))
      } else {
          return(div(
              p(getGenesInfo(GeneDf)[1, ]),
              h4("Other Locations:"),
              p(
                  paste(getGenesInfo(GeneDf)[2:nrow(GeneDf)], collapse = '\n')
              )
          ))
      }

  })

  ## Jbrowse output UI
  output$outJbrowse <- renderUI({
    # TODO: validate status
    
    reJbrowseUI()
  })


}



