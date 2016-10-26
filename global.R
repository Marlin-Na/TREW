<<<<<<< HEAD
#setwd("/Users/weizhen/Desktop/Research/RNA\ methylation\ Target\ Database/5.\ Shiny_complete")
=======
# setwd("/Users/weizhen/Desktop/Research/RNA\ methylation\ Target\ Database/5.\ Shiny_complete")
>>>>>>> origin/master
library(shiny)
library(DT)
library(readr)
library(dplyr)
Table1 <- read_tsv("Table1.txt")
Table2 <- read_tsv("Table2.txt")
Table3 <- read_tsv("Table3.txt")
idx_2to1 <- inverse.rle(read_rds("idx_2to1.rle.rds"))
idx_3to2 <- read_rds("idx_3to2.rds")
idx_3to1 <- read_rds("idx_3to1.rds")

Tb1 <- function(idx_3 = TRUE,
                idx_2 = TRUE,
                Gene_ID = "."
                )
{
  # Generate idx3 & idx2
    idx3 <- eval(parse(text = idx_3))
    idx2 <- eval(parse(text = idx_2))

  # length correction
    if (length(idx2) == 1) idx2 = rep(idx2,nrow(Table2))
    if (length(idx3) == 1) idx3 = rep(idx3,nrow(Table3))

  # Select Genes.
  hit_idx <- grepl(Gene_ID, Table2$Gene_ID, ignore.case = TRUE)

  idx2 <-  idx2 & hit_idx & rep(idx3,idx_3to2)

  # Merge the table.
  idx2[which(is.na(idx2))] <- FALSE

  idx1 <- rep(idx2,idx_2to1)

  if(sum(idx2) == 0){stop("Not found your required sites.")}

  Tb1 <- cbind(Table1[which(idx1),],
               Table2[rep(which(idx2),
                          idx_2to1[which(idx2)]),],
               Table3[rep(1:dim(Table3)[1],
                          idx_3to1)[which(idx1)],])
  cat("Tb1 run once\n")
  Tb1[,c(2,1,39,33,34,35,31,6,5,3,4,32,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,36,37,38,40,41,42,43)]
  }

count.x <- function(tb1.x,tb2.y){
  tb2.y <- tb2.y[,c(1,2)]
  tb <- table(tb1.x$Target,tb1.x$Gene_ID)
  idx <- which(tb2.y[,1]%in%rownames(tb) & tb2.y[,2]%in%colnames(tb))
  hits <- vector("numeric",nrow(tb2.y))
  hits[idx] <- tb[cbind(as.character(tb2.y[idx,1]),as.character(tb2.y[idx,2]))]
  hits
}

Tb2 <- function(Tb1){
  Tb1 <- Tb1[!duplicated(Tb1$Meth_Site_ID),]
  Tb2 <- unique(data.frame(Target = Tb1$Target,
                           Gene_ID = Tb1$Gene_ID,
                           Target_type = Tb1$Target_type,
                           Modification = Tb1$Modification))
  Record_num <- count.x(Tb1,Tb2)
  Tb2$Positive_num <- count.x(Tb1[which(Tb1$Diff_p_value < .05),],Tb2)
  Tb2$Positive_percent <- paste(round(100*(Tb2$Positive_num/Record_num),2),"%",sep = "")
  cat("Tb2 run once\n")
  rownames(Tb2) <- 1:nrow(Tb2)
  Tb2
}

###Table 3 is the specific table that must be inferred from tb1 and tb2

Tb3 <- function(Tb1,Tb2,Select_Number = 1:dim(Tb2)[1],Return_All = "No")
{
  Tb2_s <- Tb2[Select_Number,]

  Tb3 <- Tb1[which(Tb1$Target %in% Tb2_s$Target &
                     Tb1$Modification %in% Tb2_s$Modification &
                     Tb1$Gene_ID %in% Tb2_s$Gene_ID),]
  cat("Tb3 run once\n")
  rownames(Tb3) <- 1:nrow(Tb3)
  Tb3
}

Tb_DT <- function(Tb,collab,main = NULL,responsive = "Responsive")
{
<<<<<<< HEAD
  DT::datatable(Tb, 
                rownames = TRUE, 
=======
  DT::datatable(Tb,
                rownames= FALSE,
>>>>>>> origin/master
                colnames = collab,
                caption = main,
                filter = list(position = "bottom",clear = FALSE),
                #style = 'bootstrap',
                #class = 'cell-border stripe',
                selection = list(mode = 'single', selected = c(1), target = 'row') ,
                extensions = c("Scroller","ColReorder","Buttons","FixedHeader","FixedColumns",responsive),
                options = list(
                  searchHighlight = TRUE,
                  deferRender = TRUE,
                  scrollX = TRUE,
                  scroller = TRUE,
                  scrollY = 400,
                  dom = 'Brftip',
                  autoWidth=TRUE,
                  fixedHeader = TRUE,
                  lengthMenu = list(c(10, 50, -1), c('10', '50', 'All')),
                  ColReorder = TRUE,
                  buttons = list(
                      I('colvis'),
                      'copy'
                    )
                ))
}

##### Functions to prepare index for filters ----------------

Into_var <- function(x) gsub(" ","_", x)
stat_tf <- function(x) gsub("< .","less",x)

#Variable enumeration
#Table3_length
All_ = TRUE

#Modification
hmrC_ = Table3$Modification == "hmrC"
m1A_ = Table3$Modification == "m1A"
m6A_ = Table3$Modification == "m6A"
Psi_ = Table3$Modification == "Psi"
m5C_ = Table3$Modification == "m5C"

#Factors
dTet_ = Table3$Target == "dTet"
ALKBH_ = Table3$Target == "ALKBH"
KIAA1429_ = Table3$Target == "KIAA1429"
METTL14_ = Table3$Target == "METTL14"
METTL3_ = Table3$Target == "METTL3"
WTAP_ = Table3$Target == "WTAP"
YTHDF2_ = Table3$Target == "YTHDF2"
hPUS1_ = Table3$Target == "hPUS1"
HNRNPC_ = Table3$Target == "HNRNPC"
YTHDC1_ = Table3$Target == "YTHDC1"
YTHDF1_ = Table3$Target == "YTHDF1"
DNMT2_ = Table3$Target == "DNMT2"
NSUN2_ = Table3$Target == "NSUN2"
Fto_ = Table3$Target == "Fto"
Reader_ = YTHDF1_&YTHDF2_&YTHDC1_
Eraser_ = ALKBH_&Fto_
Writer_ = !(Reader_|Eraser_)

#Species
Drosophila_melanogaster_ = Table3$Species == "Drosophila melanogaster"
Homo_sapiens_ = Table3$Species == "Homo sapiens"
Mus_musculus_ = Table3$Species == "Mus musculus"
Yes_ = TRUE
No_ = is.na(Table3$LiftOver)

#Cell line
S2_ = Table3$Cell_line == "S2"
Hek293T_ = Table3$Cell_line == "Hek293T"
MEF_ = Table3$Cell_line == "MEF"
Mouse_3T3L1_ = Table3$Cell_line == "3T3L1"
Mouse_Mid_Brain_ = Table3$Cell_line == "Mouse Mid Brain"
A549_ = Table3$Cell_line == "A549"
Hela_Cell_ = Table3$Cell_line == "Hela Cell"
MouseESC_ = Table3$Cell_line == "Mouse ESC"
HEF_ = Table3$Cell_line == "HEF"

#Technique
MeRIP_ = Table3$Technique == "MeRIP"
ParCLIP_ = Table3$Technique == "ParCLIP"
AzaIP_ = Table3$Technique == "AzaIP"
Bisulfite_ = Table3$Technique == "Bisulfite"

# #Table 2 large vectors
# RNA types
mRNA_ = Table2$Overlap_mRNA > 0
lncRNA_ = Table2$Overlap_lncRNA > 0
sncRNA_ = Table2$Overlap_sncRNA > 0
tRNA_ = Table2$Overlap_tRNA > 0
miRNA_ = Table2$Overlap_miRNA > 0

# Stat significance
No_filter_ = TRUE
p_less05_ = Table2$Diff_p_value < .05
p_less01_ = Table2$Diff_p_value < .01
fdr_less05_ = Table2$Diff_fdr < .05
fdr_less01_ = Table2$Diff_fdr < .01

# Consistency
Consistent_sites_only_ = Table2$Consistency > 0

# Motif
Motif_restriction_ = Table2$Distance_ConsensusMotif < 10

# Stop codon
On_top_stop_codon_ = Table2$Distance_StopCodon < 10

# RNA region
UTR5_ = Table2$Overlap_UTR5
CDS_ = Table2$Overlap_CDS
UTR3_ = Table2$Overlap_UTR3
miRNATS_ = Table2$Overlap_miRNATS



##### Functions for generating Jbrowse UI  -------------------------------

getAvlGenomes <- function (Df, genomeCol = 'Genome_assembly') {
    avl.genomes <- Df[,genomeCol] %>%
        unique %>%    # Exclude NA values here??
        as.character

    species <-
        ifelse(avl.genomes == 'hg19', 'Homo sapiens (hg19)',
        ifelse(avl.genomes == 'mm10', 'Mus musculus (mm10)',
        ifelse(avl.genomes == 'dm6' , 'Drosophila melanogaster (dm6)', NA)))

    names(avl.genomes) <- species

    return(avl.genomes)
}

## The genome should be specified by user from available genomes.

getSelectedRow <- function(whichrow, Df) {
    Df[whichrow, ] %>%  # DT return names when the table have rownames
    return
}

getGenome <- function(SelectedRow, genomeCol = 'Genome_assembly') {
    genome <- SelectedRow[ ,genomeCol] %>%
        as.character %>%
    return
}

getGene <- function (SelectedRow, geneCol = 'Gene_ID') {
    gene <- SelectedRow[ ,geneCol] %>%
        as.character %>%
    return
}

getChromosome <- function (SelectedRow, chromosomeCol = 'Chromosome') {
    chromosome <- SelectedRow[ ,chromosomeCol] %>%
        as.character %>%
    return
}

getRange <- function (SelectedRow,
                      resizeFactor = 1.5,
                      startCol = 'Range_start', widthCol = 'Range_width') {
    start <- SelectedRow[ ,startCol] %>% as.numeric
    width <- SelectedRow[ ,widthCol] %>% as.numeric
    end <- start + end - 1

    rgstart <- start - round(((resizeFactor-1)/2)*width)
    rgend <- end + round(((resizeFactor-1)/2)*width)

    range <- paste0(start,'..',end)
    return(range)
}

getHighLight <- function (SelectedRow,
                          resizeFactor = 1.5,
                          startCol = 'Range_start', widthCol = 'Range_width') {
    start <- SelectedRow[ ,startCol] %>% as.numeric
    width <- SelectedRow[ ,widthCol] %>% as.numeric
    end <- start + end - 1

    range <- paste0(start,'..',end)
    return(range)
}


getTracks <- function (DforSelectedRow,
                       PrimaryTracks = 'gene_model' # 'DNA,gene_model'
                       datasetCol = 'Source_ID') {
    DforSelectedRow[ ,datasetCol] %>%
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
    ) %>%
    return
}


