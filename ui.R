fluidPage(
  titlePanel("Basic DataTable"),
  fluidRow(
    column(4,
           selectInput("mod",
                       "Modifications:",
                       c("All","m6A","m5C"))
    ),
    column(4,
           selectInput("pro",
                       "Proteins:",
                       c("All","Regulator","Regulatee"))
    ),
    column(4,textInput("gene", "Genes:", width = 600, placeholder = "e.g cdk"),
           actionButton("button", "Submit")
    )
  ),
  fluidRow(
    DT::dataTableOutput("table")
  ),
  fluidRow(
    DT::dataTableOutput("table2")
  ),
  
  ## Jbrowse navigation
  fluidRow(
    h2('Genome Browser'),
    textOutput(outputId='outGene',inline = T),
    selectInput(inputId='inGenome',label='Genome Assembly',choices='Not Available')
  ),
  
  ## Jborwse iframe UI
  fluidRow(
    column(width = 12,
      uiOutput(outputId = 'outJbrowse')
    )
  )
)
