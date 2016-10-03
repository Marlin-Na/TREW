function(input, output) {
    
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
    
}