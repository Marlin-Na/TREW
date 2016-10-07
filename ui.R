fluidPage(

  tags$head(

#      ## Jquery: resizable of Jbrowse iframe
#      HTML('<script src="http://code.jquery.com/jquery-1.12.4.min.js" integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ=" crossorigin="anonymous"></script>'),
#      HTML('<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=" crossorigin="anonymous"></script>'),
#      HTML('<script> $( function() { $( "#resizable" ).resizable(); } ); </script>'),
#  
#      ## Reload the shiny js in order to solve the masked function by jquery??
#      HTML('<script src="shared/shiny.min.js"></script>')

    includeHTML('www/resizable.js') ## Still need JQuery?

  ),


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
           actionButton("submitQuery", "Submit")
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
  ),
  ## test
  fluidRow(
    HTML("<div class='resizable' style='width: 200px; height: 200px;'><iframe src='http://www.example.com/'></iframe></div>")
  )
)
