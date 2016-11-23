#setwd("/Users/weizhen/git/TREW/TREW")

# #================================================================================
# The variables below are essential for the function Tb1() to run properly.
# You cannot change the variable names of them, because the Tb1() is not self contained!
# #================================================================================


library(shiny)
library(DT)
library(readr)
Table1 <- read_tsv("Table1.txt")
Table2 <- read_tsv("Table2.txt")
Table3 <- read_tsv("Table3.txt")
idx_2to1 <- inverse.rle(read_rds("idx_2to1.rle.rds"))
idx_3to2 <- read_rds("idx_3to2.rds")
idx_3to1 <- read_rds("idx_3to1.rds")

# #================================================================================
# Tb1 is a function that input 5 things
# 1-3. The first 3 are indexes which are character vectors, and they must be string of codes that are ready to be evaluated and turn into real variables with their logical calculations.
# 4. GeneId is a character that is taken into the R match function of regular expression --- grepl.
# 5. Exact is an extra setting that controls wheather the GeneId should be matched exactly or allowing vague pattern match or not.
# Tb1 will return a subsetted table but in original formatting, it merges the data in table 1, 2, and 3.
# Also, it adds a column that is logical indicating wheather it should be filtered by the user defined statistical significance filter. 
# We should not filter statistical significance at first because the insignificant rows are still usefull when calculating tb2.
# 
# P.S. this function is not self-contained! it utilize variables that are not defined in its arguments.
# #================================================================================

Tb1 <- function(idx_3 = TRUE,
                idx_2 = TRUE,
                idx_stat = TRUE,
                Gene_ID = ".",
                exact = FALSE
                )
{ 
  # Generate idx3 & idx2 & idxstat
    idx3 <- eval(parse(text = idx_3))
    idx2 <- eval(parse(text = idx_2))
    idxstat = eval(parse(text = idx_stat))
    
  # length correction
    if (length(idx2) == 1) idx2 = rep(idx2,nrow(Table2))
    if (length(idx3) == 1) idx3 = rep(idx3,nrow(Table3))
    if (length(idxstat) == 1) idxstat = rep(idxstat,nrow(Table2))
    
  # Select Genes.
  
  if(exact){
  hit_idx <- grepl(paste("^",Gene_ID,"$",sep = ""), Table2$Gene_ID)
  }else{
  hit_idx <- grepl(Gene_ID, Table2$Gene_ID, ignore.case = TRUE)
  }
  
  idx2 <-  idx2 & hit_idx & rep(idx3,idx_3to2)
  
  # Merge the table.
  idx2[which(is.na(idx2))] <- FALSE
  
  idx1 <- rep(idx2,idx_2to1)
  
  if(sum(idx2) == 0){stop("Not found your required sites.")}
  
  idx_t1 = which(idx1)
  idx_t2 = rep(which(idx2),idx_2to1[which(idx2)])
  idx_t3 = rep(1:dim(Table3)[1],idx_3to1)[which(idx1)]
  
  Tb1 <- cbind(Table1[idx_t1,],
               Table2[idx_t2,],
               Table3[idx_t3,])
  
  Tb1$stat_idx <- idxstat[idx_t2]
  
  cat("Tb1 run once\n")
  cat(idx_3,"\n")
  cat(idx_2,"\n")
  Tb1[,c(2,1,39,33,34,35,31,6,5,3,4,32,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,36,37,38,40,41,42,43,45)]
}

# #================================================================================
# count.x 
# 1. The first argument is a tb1 "object"
# 2. The second argument is a tb2 "object"
# The function will return a vector that indicating how many hits collected by each row of tb2 (summary of tb1) upon the tb1 input.
# #================================================================================


count.x <- function(tb1.x,tb2.y){
  tb2.y <- tb2.y[,c(1,2)]
  tb <- table(tb1.x$Target,tb1.x$Gene_ID)
  idx <- which(tb2.y[,1]%in%rownames(tb) & tb2.y[,2]%in%colnames(tb))
  hits <- vector("numeric",nrow(tb2.y))
  hits[idx] <- tb[cbind(as.character(tb2.y[idx,1]),as.character(tb2.y[idx,2]))]
  hits
}


# #================================================================================
# Tb2
# 1. It only requires one input, a Tb1 "object".
# 2. The function will summarize Tb1, calculate positive record # and reliabilities, then return a Tb2 "object".
# #================================================================================


Tb2 <- function(Tb1){
  Tb1 <- Tb1[!duplicated(Tb1$Meth_Site_ID),]
  Tb2 <- unique(data.frame(Target = Tb1$Target,
                           Gene_ID = Tb1$Gene_ID, 
                           Target_type = Tb1$Target_type, 
                           Modification = Tb1$Modification,
                           stat_idx = Tb1$stat_idx))
  Record_num <- count.x(Tb1,Tb2)
  Tb2$Positive_num <- count.x(Tb1[which(Tb1$Diff_p_value < .05),],Tb2)
  Tb2$Positive_percent <- paste(round(100*(Tb2$Positive_num/Record_num),2),"%",sep = "")
  cat("Tb2 run once\n")
  Tb2 <- Tb2[which((Tb2$Positive_num != 0) & Tb2$stat_idx), -c(5)]
  rownames(Tb2) <- 1:nrow(Tb2)
  Tb2
}

# #================================================================================
# Tb2 takes 3 inputs
# 1. Tb1: the Tb1 "object".
# 2. Tb2: the Tb2 "object".
# 3. Select_Number: The selected row on Tb2 returned by the UI.
# Returning Tb3 which is the reduced table from particular row in Tb2 back to Tb1, it is essentially a subsetting on Tb1.
# #================================================================================

Tb3 <- function(Tb1,Tb2,Select_Number = 1:dim(Tb2)[1])
{
  Tb2_s <- Tb2[Select_Number,]
  
  Tb3 <- Tb1[which(Tb1$Target %in% Tb2_s$Target & 
                     Tb1$Modification %in% Tb2_s$Modification &
                     Tb1$Gene_ID %in% Tb2_s$Gene_ID), -c(40)]
  cat("Tb3 run once\n")
  rownames(Tb3) <- 1:nrow(Tb3)
  Tb3
}

# #================================================================================
# Tb_DT takes 4 inputs
# 1. Tb: A dataframe "object"
# 2. collab: The collumn labelings.
# 3. main: The table legends.
# 4. responsive: Wheather collapse things into the "+" button if there are no space, if so it is "Responsive", else NULL.
# 5. select_setting: Control the defaulted ways of selection in the table.
# #================================================================================


Tb_DT <- function(Tb, 
                   collab, 
                    main = NULL, 
                     responsive = "Responsive",
                       select_setting = list(mode = 'single', selected = 1, target = 'row'))
                  
{
  DT::datatable(Tb, 
                rownames = TRUE, 
                colnames = collab,
                caption = main,
                filter = list(position = "bottom",clear = FALSE),
                #style = 'bootstrap',
                #class = 'cell-border stripe',
                selection = select_setting,
                extensions = c("Scroller","ColReorder","Buttons","FixedHeader","FixedColumns",responsive),
                options = list(
                  searchHighlight = TRUE,
                  deferRender = TRUE,
                  scrollX = TRUE,
                  scroller = TRUE,
                  scrollY = 400,
                  dom = 'Brftip',
                  autoWidth= TRUE,
                  fixedHeader = TRUE,
                  lengthMenu = list(c(10, 50, -1), c('10', '50', 'All')),
                  ColReorder = TRUE,
                  buttons =
                    list(
                      list(
                        extend = 'collection',
                        buttons = c('csv', 'excel'),
                        text = 'Download'
                      ),
                      I('colvis')
                    )
                 ))
}

##### Functions to prepare index for filters ----------------
# #================================================================================
# Below are basically functions that transform the input selections returned by ui into variable names of the indexes that have build already.  
# #================================================================================


Into_var <- function(x) gsub(" ","_", x)
stat_tf <- function(x) {
 vec <- c("p < .05","p < .01","fdr < .05","fdr < .01","No filter")
 vec2 <- c("p_05_","p_01_","fdr_05_","fdr_01_","No_filter_")
 vec2[match(x,vec)]
}

rreg_tf <- function(x) {
 vec <- c("All","5'UTR","CDS","3'UTR","miRNA target sites")
 vec2 <- c("All","UTR5","CDS","UTR3","miRNATS")
 vec2[match(x,vec)]
}

# #================================================================================
# Below are indexes build upon the first load of the app. 
# #================================================================================


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
ALKBH3_ = Table3$Target == "ALKBH3"
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
Reader_ = Table3$Target_type == "reader"
Eraser_ = Table3$Target_type == "eraser"
Writer_ = Table3$Target_type == "writer"

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
p_05_ = Table2$Diff_p_value < .05
p_01_ = Table2$Diff_p_value < .01
fdr_05_ = Table2$Diff_fdr < .05
fdr_01_ = Table2$Diff_fdr < .01

# Consistency
Consistent_sites_only_ = Table2$Consistency > 0

# Motif
Motif_restriction_ = Table2$Distance_ConsensusMotif < 10

# Stop codon
Near_stop_codon_ = Table2$Distance_StopCodon < 10

# RNA region
UTR5_ = Table2$Overlap_UTR5
CDS_ = Table2$Overlap_CDS
UTR3_ = Table2$Overlap_UTR3
miRNATS_ = Table2$Overlap_miRNATS



##### Functions for generating Jbrowse UI  -------------------------------

addNamesForGenomes <- function (Genomes) { # vector
    genomes <- Genomes

    species <-
        ifelse(genomes == 'hg19', 'Homo sapiens (hg19)',
        ifelse(genomes == 'mm10', 'Mus musculus (mm10)',
        ifelse(genomes == 'dm6' , 'Drosophila melanogaster (dm6)', NA)))

    names(genomes) <- species

    return(genomes)
}

## The genome should be specified by user from available genomes.

getRange <- function (Start, Width,
                      resizeFactor = 1.5) {
    start <- Start %>% as.numeric
    width <- Width %>% as.numeric
    end <- start + width - 1

    rgstart <- start - round(((resizeFactor-1)/2)*width)
    rgend <- end + round(((resizeFactor-1)/2)*width)

    range <- paste0(rgstart,'..',rgend)
    return(range)
}

getHighLight <- function (Start, Width,
                          resizeFactor = 1.5) {
    start <- Start %>% as.numeric
    width <- Width %>% as.numeric
    end <- start + width - 1

    range <- paste0(start,'..',end)
    return(range)
}

getTracks <- function (DataSets,  # A vector
                       PrimaryTracks = 'gene_model')  # 'DNA,gene_model'
    DataSets %>%
        unique %>%
        paste(collapse = ',') %>%
        paste0(PrimaryTracks, ',', .) %>%
    return


# A sample url is "http://180.208.58.19/jbrowse/?data=data/hg19&loc=chr6:30309362..30310357&tracks=DNA,all_m6A,gene_model&highlight=chr6:30309513..30310230&nav=0&tracklist=0&overview=0"
getLinkJbrowse <-
    function (Genome,                      # e.g. 'hg19'
              Chromosome,                  # e.g. 'chr6'
              Range = '',                  # e.g. '30309362..30310357'
              HighLight = '',              # e.g. '30309513..30310230'
              Tracks = 'DNA,gene_model',   # e.g. 'DNA,gene_model,all_m6A'
              BaseUrl = './jbrowse')       # e.g. 'http://180.208.58.19/jbrowse'
{
    url <- paste0(
        BaseUrl, '/',
        '?data=data/', Genome,
        '&loc=', Chromosome,
        if (Range == '') '' else paste0(':', Range),
        '&tracks=', Tracks,
        if (HighLight == '') '' else paste0('&highlight=',Chromosome,':',HighLight)
    )

    return(url)
}


hide_navagation <- function(Link) paste0(Link, '&nav=0')
hide_tracklist  <- function(Link) paste0(Link, '&tracklist=0')
hide_overview   <- function(Link) paste0(Link, '&overview=0')



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

matchStrand <- function(candidates, justice) {
    # stopifnot(length(justice) == 1)

    if (justice == '*')
        return (rep(T, length(candidates)))

    return(candidates == justice)
}

getGenesInfo <- function(GeneDf) {
    names <- GeneDf$gene_id
    chromosomes <- GeneDf$seqnames
    strands <- ifelse(GeneDf$seqnames == '-','negative','positive')
    genomes <- GeneDf$genome_assembly

    sprintf('Gene %s on %s %s strand of %s genome assembly',
            names, chromosomes, strands, genomes)
}
