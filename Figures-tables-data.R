## Downloads data for Rmarkdown script
rm(list=ls()) # Clears workspace

PKG <- c("renv","googledrive","furrr") # https://rud.is/b/2016/02/14/making-faceted-heatmaps-with-ggplot2/

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {  
    install.packages(p)
    require(p,character.only = TRUE)}
}
renv::snapshot()

# Below function is needed to unzip large files in R. Doesn't work on MS Windows.
decompress_file <- function(file, directory, .file_cache = FALSE) {
  
  if (.file_cache == TRUE) {
    print("decompression skipped")
  } else {
    
    # Set working directory for decompression
    # simplifies unzip directory location behavior
    wd <- getwd()
    setwd(directory)
    
    # Run decompression
    decompression <-
      system2("unzip",
              args = c("-o", # include override flag
                       file),
              stdout = TRUE)
    
    # uncomment to delete archive once decompressed
    file.remove(file) 
    
    # Reset working directory
    setwd(wd); rm(wd)
    
    # Test for success criteria
    # change the search depending on 
    # your implementation
    if (grepl("Warning message", tail(decompression, 1))) {
      print(decompression)
    }
  }
}

# Downloading data
setwd("~/Github/OLU-flood-externalities")
dir.create(file.path('Data'), recursive = TRUE, showWarnings = FALSE)

# Population raster
setwd("./Data")
folder_url<-"https://drive.google.com/open?id=1gbCoWg3J2gUd34yzOiUwrtFdVvFJBROz"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))

# Assorted other files
# folder_url<-"https://drive.google.com/open?id=1SMKTp-TahovCgDrruz3-r6B0bLPJUfIG"
# files <- drive_get(as_id(folder_url))
# system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
# system.time(unzip("Data.zip",exdir = ".", files = "Roads_2015.gpkg"))
# file.remove("Data.zip")

folder_url<-"https://drive.google.com/open?id=1eLBOiF54WY8VClVgmWgzDE4IKyfCGuDW"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
system.time(unzip("Temp.zip",exdir = "."))
file.remove("Temp.zip")

# Flood rasters for OLU25/26 figure
dir.create(file.path('50'), recursive = TRUE, showWarnings = FALSE)
setwd("./50")
folder_url<-"https://drive.google.com/open?id=1J2iPVtkNbHUksg2TssASHrR3vMvxG5ep"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
folder_url<-"https://drive.google.com/open?id=1RMAWMK6c1XFG2G1xob3ibkvnjqApm9PK"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
rs<-list.files()
plan(multisession(workers = 3))
system.time(future_map(rs,decompress_file,".")) 
setwd("..")

dir.create(file.path('100'), recursive = TRUE, showWarnings = FALSE)
setwd("./100")
folder_url<-"https://drive.google.com/open?id=1wzf2587Oahyd8CyhtcdGzCh4dSi4ZFLO"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
folder_url<-"https://drive.google.com/open?id=1nRWnIG2RexLexC7mmUjKxatbbMfoTLVi"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
rs<-list.files()
plan(multisession(workers = 3))
system.time(future_map(rs,decompress_file,".")) 
setwd("..")

dir.create(file.path('150'), recursive = TRUE, showWarnings = FALSE)
setwd("./150")
folder_url<-"https://drive.google.com/open?id=1HpcwbCxM4T4tuxgCBkpfJitNNmxTXaeO"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
folder_url<-"https://drive.google.com/open?id=1Kz2eJsmu-rJYaqYUDG_2Ue85v-wNrJuS"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x), overwrite = TRUE)))
rs<-list.files()
plan(multisession(workers = 3))
system.time(future_map(rs,decompress_file,".")) 
setwd("./../..")



rm(files, folder_url, PKG, p)
