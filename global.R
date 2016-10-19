
library(dplyr)

library(shiny)
library(DT)
library(readr)
Table1 <- read_tsv("Table1.txt")
Table2 <- read_tsv("Table2.txt")
Table3 <- read_tsv("Table3.txt")
idx_2to1 <- inverse.rle(read_rds("idx_2to1.rle.rds"))
idx_3to2 <- read_rds("idx_3to2.rds")
idx_3to1 <- read_rds("idx_3to1.rds")

Tb1 <- function(Species = "All", 
                Target = "All", 
                Modification = "All", 
                Gene_ID = ".",
                Include_Liftover = "Yes")
{ 
  # Initialize indexes
  idx2 = !vector(length = dim(Table2)[1])
  idx3 = !vector(length = dim(Table3)[1])
  # Select species
  if (Species != "All") {
    idx3 <- Table3$Species == Species
  }else{}
  # Select regulators
  if (Target == "Regulator") {
    idx3 <- idx3 & !Table3$Target %in% c("YTHDF1","YTHDF2","YTHDC1")
  }else{
    if (Target == "Regulatee") {
      idx3 <- idx3 & Table3$Target %in% c("YTHDF1","YTHDF2","YTHDC1")
    }else{}
  }
  # Select Modifications.
  if (Modification != "All") {
    idx3 <- idx3 & (Table3$Modification == Modification)
  }else{}
  
  # Select LiftOvers.
  if (Include_Liftover != "Yes") {
    idx3 <- idx3 & is.na(Table3$LiftOver)
  }else{}
  
  # Select Genes.
  hit_idx <- grepl(Gene_ID, Table2$Gene_ID, ignore.case = TRUE)
  if(sum(hit_idx) == 0){stop("Not found your gene, please input Gene Symbol....")}
  idx2 <-  hit_idx & rep(idx3,idx_3to2)
  
  # Merge the table.
  idx2[which(is.na(idx2))] <- FALSE
  
  idx1 <- rep(idx2,idx_2to1)
  
  Tb1 <- cbind(Table1[which(idx1),],
               Table2[rep(which(idx2),
                          idx_2to1[which(idx2)]),],
               Table3[rep(1:dim(Table3)[1],
                          idx_3to1)[which(idx1)],])
  cat("Tb1 run once\n")
  Tb1
}


count.x <- function(tb1.x,tb2.y){
  tb2.y <- tb2.y[,c(1,2)]
  tb <- table(tb1.x$Target,tb1.x$Gene_ID)
  idx <- which(tb2.y[,1]%in%rownames(tb) & tb2.y[,2]%in%colnames(tb))
  hits <- vector("numeric",nrow(tb2.y))
  hits[idx] <- tb[cbind(as.character(tb2.y[idx,1]),as.character(tb2.y[idx,2]))]
  hits
}

Tb2 <- function(Tb1,Test = FALSE){
  Tb2 <- unique(data.frame(Target = Tb1$Target,
                           Gene_ID = Tb1$Gene_ID, 
                           Target_type = Tb1$Target_type, 
                           Modification = Tb1$Modification))
  Tb2$Record_num <- count.x(Tb1,Tb2)
  Tb2$Consistent_num <- count.x(Tb1[which(Tb1$Consistency > 0),],Tb2)
  Tb2$Positive_num <- count.x(Tb1[which(Tb1$Diff_p_value < .05),],Tb2)
  Tb2$Positive_percent <- paste(round(100*(Tb2$Positive_num/Tb2$Record_num),2),"%",sep = "")
  if(Test){
    binom_list <- apply(Tb2[,c("Positive_num","Record_num")],1,function(x) binom.test(x[1],x[2],p = 0.2654169))
    Tb2$binom_p <- sapply(binom_list,function(x) x$p.value)
    Tb2$binom_CI <- sapply(binom_list,function(x) paste("[",round(x$conf.int[1],3),",",round(x$conf.int[2],3),"]", sep = ""))
  }else{}
  cat("Tb2 run once\n")
  Tb2
}

###Table 3 is the specific table that must be inferred from tb1 and tb2

Tb3 <- function(Tb1,Tb2,Select_Number = 1:dim(Tb2)[1],Return_All = "No")
{
  Tb2_s <- Tb2[Select_Number,]
  
  Tb3 <- Tb1[which(Tb1$Target %in% Tb2_s$Target & 
                     Tb1$Modification %in% Tb2_s$Modification &
                     Tb1$Gene_ID %in% Tb2_s$Gene_ID),]
  
if (Return_All != "Yes") {
    Tb3 <- Tb3[,c(32,2,31,41,39,34,33,14,12,13)]
  } else {
    Tb3 <- Tb3[,c(32,2,31,12,1,6,5,3,4,13,41,33,34,35,36,39,40,42,9,10,15,16,11,14,17,18,19,20,21,22,23,24,25,26,27,28,38,43,37)]
  }
  cat("Tb3 run once\n")
  Tb3
}

Tb3_DT <- function(Tb3)
{
  DT::datatable(Tb3, rownames= FALSE, filter = "top",
                extensions = list("ColReorder" = NULL,
                                  "Buttons" = NULL,
                                  "FixedHeader" = NULL,
                                  "Scroller" = NULL),
                options = list(
                  scrollX = TRUE,
                  deferRender = TRUE,
                  scrollY = 400,
                  scroller = TRUE,
                  dom = 'BRrlftpi',
                  autoWidth=TRUE,
                  fixedHeader = TRUE,
                  lengthMenu = list(c(10, 50, -1), c('10', '50', 'All')),
                  ColReorder = TRUE,
                  buttons =
                    list(
                      'copy',
                      'print',
                      list(
                        extend = 'collection',
                        buttons = c('csv', 'excel'),
                        text = 'Download'
                      ),
                      I('colvis')
                    )
                ))
}

Tb2_DT <- function(Tb2){ 
  DT::datatable(Tb2,
                rownames = FALSE,
                options = list(
                  scrollX = TRUE,
                  deferRender = TRUE,
                  scrollY = 340,
                  dom = 'lrtip',
                  autoWidth = TRUE,
                  ColReorder = TRUE)
  )
}






##### Functions for generating Jbrowse UI  -------------------------------

# df.genes <- readRDS('dataframe_genes.Rds')

getAvlGenomesFromGene <- function (GeneID, DfGenes = df.genes) {
    avl.genomes <- DfGenes %>%
        dplyr::filter(gene_id == GeneID) %>%
        dplyr::select(genome_assembly) %>%
        as.character

    species <-
        ifelse(avl.genomes == 'hg19', 'Homo sapiens (hg19)',
        ifelse(avl.genomes == 'mm10', 'Mus musculus (mm10)',
        ifelse(avl.genomes == 'dm6' , 'Drosophila melanogaster (dm6)', NA)))

    names(avl.genomes) <- species

    return(avl.genomes)
}

## The genome should be specified by user from available genomes.

getDfGene <- function (GeneID, Genome, DfGenes = df.genes) {
    df.gene <- DfGenes %>%
        dplyr::filter(gene_id == GeneID & genome_assembly == Genome) 

    return(df.gene) # Should be of length one
}

getChromosome <- function (DfGene) {
    chr.gene <- DfGene$seqnames
    return(chr.gene)
}

getRange <- function (DfGene, resizeFactor = 1.5) {
    width <- DfGene$width
    start <- DfGene$start - round(((resizeFactor-1)/2)*width)
    end <- DfGene$end + round(((resizeFactor-1)/2)*width)
    range <- paste0(start,'..',end)
    return(range)
}

getHighLight <- function (DfGene) {
    start <- DfGene$start
    end <- DfGene$end
    range <- paste0(start,'..',end)
    return(range)
}

getTracks <- function (Datasets, PrimaryTracks = 'gene_model') { # 'DNA,gene_model'
    Datasets %>%
        unique %>%
        paste(collapse = ',') %>%
        paste0(',', PrimaryTracks) %>%
    return
}

# A sample url is "http://180.208.58.19/jbrowse/?data=data/hg19&loc=chr6:30309362..30310357&tracks=DNA,all_m6A,gene_model&highlight=chr6:30309513..30310230&nav=0&tracklist=0&overview=0"
getLinkJbrowse <-
    function (Genome,                      # e.g. 'hg19'
              Chromosome,                  # e.g. 'chr6'
              Range = '',                  # e.g. '30309362..30310357'
              Tracks = 'DNA,gene_model',   # e.g. 'DNA,gene_model,all_m6A'
              HighLight = '',              # e.g. '30309513..30310230'
              BaseUrl = './jbrowse',       # e.g. 'http://180.208.58.19/jbrowse'
              showNav = F,
              showTracklist = F,
              showOverview = F)
{
    url <- paste0(
        BaseUrl, '/',
        '?data=data/', Genome,
        '&loc=', Chromosome,
        if (Range == '') '' else paste0(':', Range),
        '&tracks=', Tracks,
        if (HighLight == '') '' else paste0('&highlight=',Chromosome,':',HighLight),
        if (showNav == T) '' else '&nav=0',
        if (showTracklist == T) '' else '&tracklist=0',
        if (showOverview == T) '' else '&overview=0'
    )

    return(url)
}


getIframeJbrowse <-
    function(LinkJbrowse, style = 'border: 1px solid black',
             div_id = 'resizable', div_style = 'width: 100%; height: 500px;')
{
    tags$iframe(
        src = LinkJbrowse,
        style = style,
        width = '100%',
        height = '100%',
        "Sorry, your browser does not support iframe."
    ) %>%
    tags$div(
        id = div_id,
        style = div_style
    )
}


