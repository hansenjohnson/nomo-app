## proc_noise ##
# process noise data from NOMO texts

# input -------------------------------------------------------------------

# data directory
ddir = 'data/raw/'

# output file
ofile = 'data/processed/noise.rds'

# setup -------------------------------------------------------------------

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))
odir = dirname(ofile)
if(!dir.exists(odir)){dir.create(odir, recursive = T)}

# process -----------------------------------------------------------------

# list raw data files
flist=list.files(path = ddir, pattern = "*.txt", full.names = T, recursive = T)

# read all data files
out=vector('list', length = length(flist))
for(ii in seq_along(flist)){
  if(file.size(flist[ii]) == 0){
    warning("Skipping empty file: ", flist[ii], "")
    out[[ii]]=tibble(V1=NA,V2=NA,V3=NA)
  } else {
    out[[ii]]=read.delim(flist[ii],sep = ",",header = F)  
  }
}

# flatten
dd = bind_rows(out)

# name columns
colnames(dd) = c('id', 'tstamp','dB')

# format
df = dd %>%
  dplyr::mutate(
    time_utc = as.POSIXct(tstamp, format = '%Y-%m-%d_%H%M%SZ', tz = 'UTC'),
    time_local = with_tz(time_utc, tzone = 'America/New_York'),
    dB = as.numeric(dB),
    dep_id = paste0(id, '_', str_split(flist, pattern = '/', simplify = T)[,5])) %>%
  drop_na() %>%
  dplyr::arrange(time_utc) %>%
  dplyr::select(-tstamp) %>%
  tibble()

# save
saveRDS(df, file = ofile)
