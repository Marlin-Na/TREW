fluidPage(
  titlePanel("TREW_BASIC"),
#Fluid Row 1#====================================================================================================================================================
  fluidRow(
    #Column 1#####################################
    column(3,
           selectInput("mod",
                       "Modifications:",
                       c("All",unique(Table3$Modification)))
    ),
    #Column 2#####################################
    column(3,
           selectInput("pro",
                       "Proteins:",
                       c("All","Regulator","Regulatee","Reader","Writer","Eraser",unique(Table3$Target)))
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
#Fluid row 2#====================================================================================================================================================
 fluidRow(
   #Column 1#####################################
   column(3,
     selectInput("rtyp",
                 "RNA types:",
                c("All","mRNA","lncRNA","sncRNA","tRNA","miRNA")
  )
),
  #Column 2#####################################
   column(3,
         selectInput("celline",
                     "Cell lines:",
                     c("All",unique(Table3$Cell_line))
         )
  ),
  #Column 3######################################
  column(3,
         selectInput("teq",
                    "Technique",
                     c("No",unique(Table3$Technique))
       )
),
   #Column 4######################################
column(3,
       selectInput("statsig",
                   "Statistical significance",
                   c("No filter","p < .05","p < .01","fdr < .05","fdr < .01")
       )
 )
)
,

#Fluid row 3#====================================================================================================================================================

fluidRow(
  #Column 1#####################################
  column(3,
         selectInput("consis",
                     "Consistency",
                     c("No filter","Consistent sites only")
         
  )
),
  #Column 2#####################################
  column(3,
         selectInput("rreg",
                     "RNA regions:",
                     c("All","UTR5","CDS","UTR3","miRNATS")
         )
),
  #Column 3######################################
  column(3,
         selectInput("motif",
                     "Motif restriction",
                     c("Yes","No")
         )
  ),
  #Column 4######################################
  column(3,textInput("gene", "Genes(GeneSymbol):", width = 600, placeholder = "All genes when input nothing"),
         actionButton("button", "Submit")
  )
),

br()
,
#Fluid row 3#====================================================================================================================================================
fluidRow(
  #Column 1#####################################
  column(6,
    DT::dataTableOutput("table")
  ),
  #Column 2#####################################
  column(6,
   DT::dataTableOutput("table2"),
   downloadButton('downloadData', 'Download complete specific table (by all rows on summary table)'))
)
# #==================================================End fluid Page===============================================================
)


