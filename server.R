function(input, output) {
  tb1 <- eventReactive(input$button,{Tb1(Target = input$pro,
                                         Modification = input$mod,
                                         Species = input$spes,
                                         RNA_type = input$rtyp,
                                         RNA_region = input$rreg,
                                         Gene_ID = input$gene,
                                         Include_Liftover = input$lift,
                                         Motif_restriction = input$motif
                                         
  )
}
)
  tb2 <- reactive({Tb2(tb1())})
  
  output$table <- DT::renderDataTable(Tb_DT(tb2(), 
                                            main = "Summary Table(select rows to show specific)",
                                      collab = c("Target","Gene_ID"," Tagret_type","Modification", "Record_#","Consistent_#","Positive_#","Positive_%")),
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

