function(input, output) {
  tb1 <- eventReactive(input$button,{Tb1(
    idx_3 = Into_var(paste(
      paste(input$mod,input$pro,input$spes,input$lift,input$celline,input$teq,sep = "_&")
      ,"_",sep = "")),
      idx_2 = Into_var(paste(
          paste(input$rtyp,input$rreg,input$motif,stat_tf(input$stat_sig),input$consis,sep = "_&")
          ,"_",sep = "")),
    Gene_ID = input$gene
  )
}
)
  tb2 <- reactive({Tb2(tb1())})
  
  output$table <- DT::renderDataTable(Tb_DT(tb2(), 
                                            main = "Summary Table (select rows to show specific ones)",
                                      collab = c("Regulator","Target_Gene"," Type","Mark","Positive_#","Reliability")),
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
}

