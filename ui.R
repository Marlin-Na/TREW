fluidPage(
    titlePanel("Basic DataTable"),
    fluidRow(
        column(width = 4,
            selectInput(
                "mod",
                "Modifications:",
                c("All", "m6A", "m5C")
            )
        ),
        column(width = 4,
            selectInput(
                "pro",
                "Proteins:",
                c("All", "Regulator", "Regulatee")
            )
        ),
        column(width = 4,
            textInput("gene", "Genes:", width = 600, placeholder = "e.g cdk"),
            actionButton("submitQuery", "Submit")
        )
    ),
    fluidRow(DT::dataTableOutput("table")),
    
    navlistPanel(widths = c(2,10),
        
        tabPanel(title = "Table",
            ## Table output of sites
            fluidRow(DT::dataTableOutput("table2"))
        ),
        
        tabPanel(title = "Browser",
                 
            ## Jbrowse navigation
            fluidRow(
                h2('Genome Browser'),
                textOutput(outputId = 'outGene', inline = T),
                selectInput(
                    inputId = 'inGenome',
                    label = 'Genome Assembly',
                    choices = 'Not Available'
                )
            ),
            
            ## Jborwse iframe UI
            fluidRow(
                column(width = 12,
                    uiOutput(outputId = 'outJbrowse')
                )
            )       
        )
    )
    
)
