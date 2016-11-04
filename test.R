Range_format <- function(start,width) {
  paste(start,'..',start + width -1,sep = "")
}

Get_URL <- function(tb3, tb3_selected,BaseUrl = './jbrowse') {
 info_vec <- as.character(tb3[tb3_selected ,c("Genome_assembly","Gene_ID","Chromosome","Range_start","Range_width","Source_ID")])
 paste(BaseUrl,'/','?data=data/',
                        info_vec[1],'&loc=',info_vec[3],
                          Range_format(as.numeric(info_vec[4]),as.numeric(info_vec[5])),
                            '&tracks=DNA,gene_mode,',info_vec[6], sep = "")
}

Get_URL(tb3, tb3_selected = 1)

"http://180.208.58.19/jbrowse/?data=data/hg19&loc=chr6:30309362..30310357&tracks=DNA,all_m6A,gene_model&highlight=chr6:30309513..30310230&nav=0&tracklist=0&overview=0"

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
