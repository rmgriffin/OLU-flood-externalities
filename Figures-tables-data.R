## Downloads data for Rmarkdown script
rm(list=ls()) # Clears workspace

PKG <- c("renv","googledrive") # https://rud.is/b/2016/02/14/making-faceted-heatmaps-with-ggplot2/

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {  
    install.packages(p)
    require(p,character.only = TRUE)}
}
renv::snapshot()

# Downloading data
setwd("~/Github/OLU-flood-externalities")
dir.create(file.path('Data'), recursive = TRUE, showWarnings = FALSE)

# Population raster
setwd("./Data")
folder_url<-"https://drive.google.com/open?id=1gbCoWg3J2gUd34yzOiUwrtFdVvFJBROz"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))

# Assorted other files
folder_url<-"https://drive.google.com/open?id=1SMKTp-TahovCgDrruz3-r6B0bLPJUfIG"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
system.time(unzip("Data.zip",exdir = ".", files = "Roads_2015.gpkg"))
file.remove("Data.zip")

folder_url<-"https://drive.google.com/open?id=1eLBOiF54WY8VClVgmWgzDE4IKyfCGuDW"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
system.time(unzip("Temp.zip",exdir = "."))
file.remove("Temp.zip")

rm(files, folder_url, PKG, p)
