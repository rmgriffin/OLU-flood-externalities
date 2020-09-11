# Setup -------------------------------------------------------------------
rm(list=ls()) # Clears workspace

#system("sudo apt install libgeos-dev libproj-dev libgdal-dev libudunits2-dev -y") # Install linux geospatial dependencies 



# Install/call libraries
PKG <- c("googledrive","tidyverse", "rgdal","raster","exactextractr", "sf", "furrr","data.table","filesstrings")

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {  
    install.packages(p)
    require(p,character.only = TRUE)}
}
rm(PKG,p)

# Unzip code function -----------------------------------------------------
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


# Non-raster inputs -------------------------------------------------------
# https://community.rstudio.com/t/how-to-download-a-google-drives-contents-based-on-drive-id-or-url/16896/6

setwd("~/Github/OLU-flood-externalities")
folder_url<-"https://drive.google.com/open?id=1eLBOiF54WY8VClVgmWgzDE4IKyfCGuDW"
files <- drive_get(as_id(folder_url))
system.time(walk(files$id, ~ drive_download(as_id(.x))))
system.time(decompress_file("Temp.zip","."))

# Loading polygons of OLUs in gpkg format (shapefile)
tOLU<-st_read("olu_NAD83_10N.gpkg")
# Reprojecting to projection of rasters
tOLU<-st_transform(tOLU, crs = "+proj=utm +zone=10 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") # Reprojecting

# Preparing exposure data
Exposure<-st_read("Exposure4OLU3.gpkg") # Census polygons wholly WITHIN raster extent
Exposure<-st_transform(Exposure, crs = "+proj=utm +zone=10 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") # Reprojecting
## Replacement cost values for structures
# Import replacement costs
RC<-read.csv("Replacement_cost.csv")
# Create structure values by census block
Exposure$V_RES1<-as.numeric(subset(RC,RC$Occup.Types == "RES1", select = "St_val")) * Exposure$RES1
Exposure$V_RES2<-as.numeric(subset(RC,RC$Occup.Types == "RES2", select = "St_val")) * Exposure$RES2
Exposure$V_RES3A<-as.numeric(subset(RC,RC$Occup.Types == "RES3A", select = "St_val")) * Exposure$RES3A
Exposure$V_RES3B<-as.numeric(subset(RC,RC$Occup.Types == "RES3B", select = "St_val")) * Exposure$RES3B
Exposure$V_RES3C<-as.numeric(subset(RC,RC$Occup.Types == "RES3C", select = "St_val")) * Exposure$RES3C
Exposure$V_RES3D<-as.numeric(subset(RC,RC$Occup.Types == "RES3D", select = "St_val")) * Exposure$RES3D
Exposure$V_RES3E<-as.numeric(subset(RC,RC$Occup.Types == "RES3E", select = "St_val")) * Exposure$RES3E
Exposure$V_RES3F<-as.numeric(subset(RC,RC$Occup.Types == "RES3F", select = "St_val")) * Exposure$RES3F
Exposure$V_RES4<-as.numeric(subset(RC,RC$Occup.Types == "RES4", select = "St_val")) * Exposure$RES4
Exposure$V_RES5<-as.numeric(subset(RC,RC$Occup.Types == "RES5", select = "St_val")) * Exposure$RES5
Exposure$V_RES6<-as.numeric(subset(RC,RC$Occup.Types == "RES6", select = "St_val")) * Exposure$RES6
Exposure$V_COM1<-as.numeric(subset(RC,RC$Occup.Types == "COM1", select = "St_val")) * Exposure$COM1
Exposure$V_COM2<-as.numeric(subset(RC,RC$Occup.Types == "COM2", select = "St_val")) * Exposure$COM2
Exposure$V_COM3<-as.numeric(subset(RC,RC$Occup.Types == "COM3", select = "St_val")) * Exposure$COM3
Exposure$V_COM4<-as.numeric(subset(RC,RC$Occup.Types == "COM4", select = "St_val")) * Exposure$COM4
Exposure$V_COM5<-as.numeric(subset(RC,RC$Occup.Types == "COM5", select = "St_val")) * Exposure$COM5
Exposure$V_COM6<-as.numeric(subset(RC,RC$Occup.Types == "COM6", select = "St_val")) * Exposure$COM6
Exposure$V_COM7<-as.numeric(subset(RC,RC$Occup.Types == "COM7", select = "St_val")) * Exposure$COM7
Exposure$V_COM8<-as.numeric(subset(RC,RC$Occup.Types == "COM8", select = "St_val")) * Exposure$COM8
Exposure$V_COM9<-as.numeric(subset(RC,RC$Occup.Types == "COM9", select = "St_val")) * Exposure$COM9
Exposure$V_COM10<-as.numeric(subset(RC,RC$Occup.Types == "COM10", select = "St_val")) * Exposure$COM10
Exposure$V_IND1<-as.numeric(subset(RC,RC$Occup.Types == "IND1", select = "St_val")) * Exposure$IND1
Exposure$V_IND2<-as.numeric(subset(RC,RC$Occup.Types == "IND2", select = "St_val")) * Exposure$IND2
Exposure$V_IND3<-as.numeric(subset(RC,RC$Occup.Types == "IND3", select = "St_val")) * Exposure$IND3
Exposure$V_IND4<-as.numeric(subset(RC,RC$Occup.Types == "IND4", select = "St_val")) * Exposure$IND4
Exposure$V_IND5<-as.numeric(subset(RC,RC$Occup.Types == "IND5", select = "St_val")) * Exposure$IND5
Exposure$V_IND6<-as.numeric(subset(RC,RC$Occup.Types == "IND6", select = "St_val")) * Exposure$IND6
Exposure$V_AGR1<-as.numeric(subset(RC,RC$Occup.Types == "AGR1", select = "St_val")) * Exposure$AGR1
Exposure$V_GOV1<-as.numeric(subset(RC,RC$Occup.Types == "GOV1", select = "St_val")) * Exposure$GOV1
Exposure$V_GOV2<-as.numeric(subset(RC,RC$Occup.Types == "GOV2", select = "St_val")) * Exposure$GOV2
Exposure$V_REL1<-as.numeric(subset(RC,RC$Occup.Types == "REL1", select = "St_val")) * Exposure$REL1
Exposure$V_EDU1<-as.numeric(subset(RC,RC$Occup.Types == "EDU1", select = "St_val")) * Exposure$EDU1
Exposure$V_EDU2<-as.numeric(subset(RC,RC$Occup.Types == "EDU2", select = "St_val")) * Exposure$EDU2
# County level cost adjustments https://stackoverflow.com/questions/38750535/extract-the-first-2-characters-in-a-string
Exposure$FIPS<-substr(Exposure$CnssBlc,start=1,stop=5)
CA<-read.csv("hzMeansCountyLocationFactor.csv", header = TRUE, colClasses=c("CountyFIPS"="character"))
Exposure$CostAdj<-(CA[match(Exposure$FIPS,CA$CountyFIPS),3])
# Import depth damage curves for structures and contents
Co<-read.csv("Contents_damage.csv")
St<-read.csv("Structures_damage.csv")
# Removing unneeded columns 
Exposure<-subset(Exposure, select = -c(Join_Count, TARGET_FID, Join_Cou_1, TARGET_F_1, Join_Cou_2, TARGET_F_2, Join_Cou_3, TARGET_F_3, Join_Cou_4, TARGET_F_4, RES1, RES2, RES3A, RES3B, RES3C, RES3D, RES3E, RES3F, RES4, RES5, RES6, COM1, COM2, COM3, COM4, COM5, COM6, COM7, COM8, COM9, COM10, IND1, IND2, IND3, IND4, IND5, IND6, AGR1, REL1, GOV1, GOV2, EDU1, EDU2))
# Removing unneeded variables
rm(CA, RC)
# Merge id (for water depth extraction)
Exposure$merge_id<-seq(1:nrow(Exposure))

# Damage function ---------------------------------------------------------
# "a_tif" is directory location of a raster (doesn't need to be tif), "n" is number of samples per polygon
# could amend sampling to be a fraction of obs per polygon, versus a fixed number, using "sample_frac"
damage<-function(a_tif, n){
  
  ## Flood raster
  r<-raster(a_tif)
  
  ## Extracting all cells using exact_extract
  system.time(test<-exact_extract(r,Exposure)) # 350-401s 11.7GB
  # Creating large dataframe and sampling
  #system.time(test2<-as.data.frame(rbindlist(test,idcol = TRUE))) # 29s
  system.time(test<-bind_rows(test, .id = "column_label")) # print(object.size(test), units = 'MB') 21s 9.4GB
  test$coverage_fraction<-NULL
  system.time(test<-test %>% group_by(column_label) %>% sample_n(size = n, replace = TRUE)) # 46s for 10%, 36s for 100/polygon (min # of cells is 85, so replace is needed for > 85)
  # Merge with Exposure data
  test$column_label<-as.numeric(test$column_label)
  system.time(test<-left_join(test,Exposure, by = c("column_label" = "merge_id"))) # 88s for 1%, 36s for 100/polygon
  # Replace all NaN with zero and switch from sf object to dataframe
  test[is.na(test)] <- 0  
  test$geometry<-NULL
  # Depth to feet
  test$depth<-test$value*3.28084
  # Rounding value of depth to nearest foot
  test$depth<-round(test$depth,0)
  test$value<-NULL
  
  ### Damage assessment
  ## General notes on damage calculations for structures and contents below
  # Blocks with zero depth are not given a damage value 
  # Following damage assessment methods found here for HAZUS https://www.fema.gov/media-library-data/1486406911383-78d7d706bc7995a20babc59d7976d692/Hazus_3.2_User_Release_Notes.pdf
  # Content value is set as a percentage of structure value. See hzPctContentOfStructureValue table from HAZUS for reference values
  # Refer to St and Co csv's for col num and DELData_HAZUS.xlsx for assignment of damage functions
  # Calculations include county level cost adjustments (can extract FIPS from the first five digits of the census block number)
  # Calculations do NOT include special adjustments for RES1 structure type
  # Calculations do NOT include adjustments for raised structures
  
  # Structure damage calculation https://stackoverflow.com/questions/11530184/match-values-in-data-frame-with-values-in-another-data-frame-and-replace-former
  test$DSt_RES1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),26]/100)*test$V_RES1*test$CostAdj)
  test$DSt_RES2<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),83]/100)*test$V_RES2*test$CostAdj)
  test$DSt_RES3A<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),98]/100)*test$V_RES3A*test$CostAdj)
  test$DSt_RES3B<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),98]/100)*test$V_RES3B*test$CostAdj)
  test$DSt_RES3C<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),98]/100)*test$V_RES3C*test$CostAdj)
  test$DSt_RES3D<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),98]/100)*test$V_RES3D*test$CostAdj)
  test$DSt_RES3E<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),98]/100)*test$V_RES3E*test$CostAdj)
  test$DSt_RES3F<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),98]/100)*test$V_RES3F*test$CostAdj)
  test$DSt_RES4<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),103]/100)*test$V_RES4*test$CostAdj)
  test$DSt_RES5<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),108]/100)*test$V_RES5*test$CostAdj)
  test$DSt_RES6<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),109]/100)*test$V_RES6*test$CostAdj)
  test$DSt_COM1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),111]/100)*test$V_COM1*test$CostAdj)
  test$DSt_COM2<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),235]/100)*test$V_COM2*test$CostAdj)
  test$DSt_COM3<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),269]/100)*test$V_COM3*test$CostAdj)
  test$DSt_COM4<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),325]/100)*test$V_COM4*test$CostAdj)
  test$DSt_COM5<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),361]/100)*test$V_COM5*test$CostAdj)
  test$DSt_COM6<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),368]/100)*test$V_COM6*test$CostAdj)
  test$DSt_COM7<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),369]/100)*test$V_COM7*test$CostAdj)
  test$DSt_COM8<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),387]/100)*test$V_COM8*test$CostAdj)
  test$DSt_COM9<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),426]/100)*test$V_COM9*test$CostAdj)
  test$DSt_COM10<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),437]/100)*test$V_COM10*test$CostAdj)
  test$DSt_IND1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),439]/100)*test$V_IND1*test$CostAdj)
  test$DSt_IND2<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),453]/100)*test$V_IND2*test$CostAdj)
  test$DSt_IND3<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),469]/100)*test$V_IND3*test$CostAdj)
  test$DSt_IND4<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),480]/100)*test$V_IND4*test$CostAdj)
  test$DSt_IND5<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),485]/100)*test$V_IND5*test$CostAdj)
  test$DSt_IND6<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),486]/100)*test$V_IND6*test$CostAdj)
  test$DSt_AGR1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),510]/100)*test$V_AGR1*test$CostAdj)
  test$DSt_GOV1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),525]/100)*test$V_GOV1*test$CostAdj)
  test$DSt_GOV2<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),534]/100)*test$V_GOV2*test$CostAdj)
  test$DSt_REL1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),518]/100)*test$V_REL1*test$CostAdj)
  test$DSt_EDU1<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),537]/100)*test$V_EDU1*test$CostAdj)
  test$DSt_EDU2<-ifelse(test$depth==0,0,(St[match(test$depth,St$depth),546]/100)*test$V_EDU2*test$CostAdj)
  
  # Content damage calculation (ref csv for col num and DELData_HAZUS.xlsx for assignment) https://stackoverflow.com/questions/11530184/match-values-in-data-frame-with-values-in-another-data-frame-and-replace-former
  test$DCo_RES1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),18]/100)*test$V_RES1*.5)
  test$DCo_RES2<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),47]/100)*test$V_RES2*.5)
  test$DCo_RES3A<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),54]/100)*test$V_RES3A*.5)
  test$DCo_RES3B<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),54]/100)*test$V_RES3B*.5)
  test$DCo_RES3C<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),54]/100)*test$V_RES3C*.5)
  test$DCo_RES3D<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),54]/100)*test$V_RES3D*.5)
  test$DCo_RES3E<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),54]/100)*test$V_RES3E*.5)
  test$DCo_RES3F<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),54]/100)*test$V_RES3F*.5)
  test$DCo_RES4<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),58]/100)*test$V_RES4*.5)
  test$DCo_RES5<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),61]/100)*test$V_RES5*.5)
  test$DCo_RES6<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),62]/100)*test$V_RES6*.5)
  test$DCo_COM1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),63]/100)*test$V_COM1)
  test$DCo_COM2<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),168]/100)*test$V_COM2)
  test$DCo_COM3<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),213]/100)*test$V_COM3)
  test$DCo_COM4<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),253]/100)*test$V_COM4)
  test$DCo_COM5<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),277]/100)*test$V_COM5)
  test$DCo_COM6<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),282]/100)*test$V_COM6*1.5)
  test$DCo_COM7<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),285]/100)*test$V_COM7*1.5)
  test$DCo_COM8<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),295]/100)*test$V_COM8)
  test$DCo_COM9<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),325]/100)*test$V_COM9)
  test$DCo_COM10<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),330]/100)*test$V_COM10*.5)
  test$DCo_IND1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),331]/100)*test$V_IND1*1.5)
  test$DCo_IND2<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),357]/100)*test$V_IND2*1.5)
  test$DCo_IND3<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),381]/100)*test$V_IND3*1.5)
  test$DCo_IND4<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),406]/100)*test$V_IND4*1.5)
  test$DCo_IND5<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),415]/100)*test$V_IND5*1.5)
  test$DCo_IND6<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),416]/100)*test$V_IND6)
  test$DCo_AGR1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),433]/100)*test$V_AGR1)
  test$DCo_GOV1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),445]/100)*test$V_GOV1)
  test$DCo_GOV2<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),450]/100)*test$V_GOV2*1.5)
  test$DCo_REL1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),440]/100)*test$V_REL1)
  test$DCo_EDU1<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),453]/100)*test$V_EDU1)
  test$DCo_EDU2<-ifelse(test$depth==0,0,(Co[match(test$depth,Co$depth),458]/100)*test$V_EDU2)
  
  # Total damage calculations for structures and contents
  test$TSt<-test$DSt_RES1+test$DSt_RES2+test$DSt_RES3A+test$DSt_RES3B+test$DSt_RES3C+test$DSt_RES3D+test$DSt_RES3E+test$DSt_RES3F+test$DSt_RES4+test$DSt_RES5+test$DSt_RES6+test$DSt_COM1+test$DSt_COM2+test$DSt_COM3+test$DSt_COM4+test$DSt_COM5+test$DSt_COM6+test$DSt_COM7+test$DSt_COM8+test$DSt_COM9+test$DSt_COM10+test$DSt_IND1+test$DSt_IND2+test$DSt_IND3+test$DSt_IND4+test$DSt_IND5+test$DSt_IND6+test$DSt_AGR1+test$DSt_EDU1+test$DSt_EDU2+test$DSt_GOV1+test$DSt_GOV2+test$DSt_REL1
  test$TCo<-test$DCo_RES1+test$DCo_RES2+test$DCo_RES3A+test$DCo_RES3B+test$DCo_RES3C+test$DCo_RES3D+test$DCo_RES3E+test$DCo_RES3F+test$DCo_RES4+test$DCo_RES5+test$DCo_RES6+test$DCo_COM1+test$DCo_COM2+test$DCo_COM3+test$DCo_COM4+test$DCo_COM5+test$DCo_COM6+test$DCo_COM7+test$DCo_COM8+test$DCo_COM9+test$DCo_COM10+test$DCo_IND1+test$DCo_IND2+test$DCo_IND3+test$DCo_IND4+test$DCo_IND5+test$DCo_IND6+test$DCo_AGR1+test$DCo_EDU1+test$DCo_EDU2+test$DCo_GOV1+test$DCo_GOV2+test$DCo_REL1
  test$Tot<-test$TCo+test$TSt
  test[is.na(test)]<-0 
  
  # Sample location within census block impacted?
  test$impact<-ifelse(test$depth>0,1,0) # Indicator if impacted (depth > 0)
  
  # Return damages and impacted census blocks by OLU
  DmgCB<-test %>%
    group_by(CnssBlc, Name) %>%
    summarise_at(vars(Tot), list(mean = mean, var = var, sd = sd))
  
  DmgOLU<-DmgCB %>%
    group_by(Name) %>%
    summarize_at(vars(mean,var), sum) # Variance of an independent sum is sum of variances
  
  DmgOLU$sd<-sqrt(DmgOLU$var) # SD is square root of variance
  
  # What to do with impacted census blocks? Max value of impact to get an estimate of number of census blocks impacted
  ImpCBCB<-test %>%
    group_by(CnssBlc, Name) %>%
    summarise_at(vars(impact), list(impact = max))
  ImpCBOLU<-ImpCBCB %>%
    group_by(Name) %>%
    summarise_at(vars(impact), list(impact = sum))
  
  DmgCB<-merge(DmgCB,ImpCBCB,by = c("CnssBlc","Name"))
  DmgOLU<-merge(DmgOLU,ImpCBOLU,"Name")
  # Getting scenario name
  DmgCB$scen<-r@data@names
  DmgOLU$scen<-r@data@names
  
  return(DmgOLU) # Can set to DmgCB if interested in census block level damages
}

## Flood function
# Function extracts cell count and summed cell values from raster using the polygon overlay defined above
# Returns dataframe with cell count and summed cell values for each OLU
flood<-function(ras){
  # Input raster
  a<-raster(ras)
  # Flood calculation (extracting cell count and summed cell values)
  tOLU[,c("count","sum")]<-exact_extract(a, tOLU, c('count', 'sum')) 
  # Extracting and returning only necessary info
  res<-st_drop_geometry(tOLU[,c("Name","count","sum")])
  return(res)
}

# DL rasters -------------------------------------------------------

## SLR 050
dir.create(file.path('050'), recursive = TRUE)
setwd("./050")
folder_url<-"https://drive.google.com/open?id=1d9l_sRsA5b0PGDwkOCPLfljnb2Ej4vnf"
folder <- drive_get(as_id(folder_url))
files <- drive_ls(folder) # ", n_max = 2" Only two rasters for testing purposes
plan(sequential)
plan(multisession(workers = 8))
dl<-function(files){
  walk(files, ~ drive_download(as_id(.x), overwrite = TRUE))
}
system.time(future_map(files$id,dl))
# Code to edit if GD doesn't get all files, some missing
rs<-list.files()
files <- files[ !files$name %in% rs, ]
system.time(future_map(files$id,dl))
# Code to edit if GD doesn't get all the files, not finished downloading
rs<-list.files()
rs<-rs[sapply(rs, file.size) < 3000000000]
files <- drive_ls(folder)
files <- files[ files$name %in% rs, ]
system.time(future_map(files$id,dl))
# Unzip
rs<-list.files()
plan(multisession(workers = 1))
system.time(future_map(rs,decompress_file,".")) 
# Move tifs to 050 base dir
rs<-list.files(".",recursive = TRUE)
map(rs,file.move,".",overwrite = TRUE)
unlink("global/", recursive = TRUE) # Remove unneeded directory
# # Overwrite with updated tifs with new shoreline
# folder_url<-"https://drive.google.com/open?id=1Qa3Q78bkbtUqKH-d1mqYePjA2JYG244z"
# folder <- drive_get(as_id(folder_url))
# files <- drive_ls(folder) # ", n_max = 2" Only two rasters for testing purposes
# plan(sequential)
# plan(multisession(workers = 8))
# dl<-function(files){
#   walk(files, ~ drive_download(as_id(.x), overwrite = TRUE))
# }
# system.time(future_map(files$id,dl))
# Damage assessment
tifs050<-list.files(".",pattern = "*.tif",recursive = TRUE)
#plan(multisession(workers = 2)) # Uses too much memory
#system.time(res050.t<-future_map(tifs050,damage, n = 100))
plan(sequential)
system.time(res050<-lapply(tifs050,damage, n = 100))
# Flood assessment
system.time(result.050<-map_df(tifs050,flood, .id = "tifs050"))
setwd("..")
unlink("./050", recursive = TRUE) # Delete tif directory


## SLR 100
dir.create(file.path('100'), recursive = TRUE)
setwd("./100")
folder_url<-"https://drive.google.com/open?id=1V30z87t-2iIyqWHHnD-cVsP0y31YNay8"
folder <- drive_get(as_id(folder_url))
files <- drive_ls(folder) # ", n_max = 2" Only two rasters for testing purposes
plan(sequential)
plan(multisession(workers = 8))
dl<-function(files){
  walk(files, ~ drive_download(as_id(.x), overwrite = TRUE))
}
system.time(future_map(files$id,dl)) 
rs<-list.files()
plan(multisession(workers = 1))
system.time(future_map(rs,decompress_file,"."))  
# Move tifs to 100 base dir
rs<-list.files(".",recursive = TRUE)
map(rs,file.move,".",overwrite = TRUE)
unlink("global/", recursive = TRUE) # Remove unneeded directory
# Damage assessment
tifs100<-list.files(".",pattern = "*.tif",recursive = TRUE)
system.time(res100<-lapply(tifs100,damage, n = 100))
# Flood assessment
system.time(result.100<-map_df(tifs100,flood, .id = "tifs100"))
setwd("..")
unlink("./100", recursive = TRUE) # Delete tif directory

## SLR 150
dir.create(file.path('150'), recursive = TRUE)
setwd("./150")
folder_url<-"https://drive.google.com/open?id=1robC3-8H9Sy_DILHgY7iOD-xBVB2fw8r"
folder <- drive_get(as_id(folder_url))
files <- drive_ls(folder) # ", n_max = 2" Only two rasters for testing purposes
plan(sequential)
plan(multisession(workers = 8))
dl<-function(files){
  walk(files, ~ drive_download(as_id(.x), overwrite = TRUE))
}
system.time(future_map(files$id,dl))
rs<-list.files()
plan(multisession(workers = 1))
system.time(future_map(rs,decompress_file,"."))
# Move tifs to 150 base dir
rs<-list.files(".",recursive = TRUE)
map(rs,file.move,".",overwrite = TRUE)
unlink("global/", recursive = TRUE) # Remove unneeded directory
# Damage assessment
tifs150<-list.files(".",pattern = "*.tif",recursive = TRUE)
system.time(res150<-lapply(tifs150,damage, n = 100))
# Flood assessment
system.time(result.150<-map_df(tifs150,flood, .id = "tifs150"))
setwd("..")
unlink("./150", recursive = TRUE) # Delete tif directory

## SLR 200
dir.create(file.path('200'), recursive = TRUE)
setwd("./200")
folder_url<-"https://drive.google.com/open?id=1E5VvxescjuYPuQk9y5OPPYlMW1fVBxUh"
folder <- drive_get(as_id(folder_url))
files <- drive_ls(folder) # ", n_max = 2" Only two rasters for testing purposes
plan(sequential)
plan(multisession(workers = 8))
dl<-function(files){
  walk(files, ~ drive_download(as_id(.x), overwrite = TRUE))
}
system.time(future_map(files$id,dl)) 
rs<-list.files()
plan(multisession(workers = 1))
system.time(future_map(rs,decompress_file,".")) 
# Move tifs to 200 base dir
rs<-list.files(".",recursive = TRUE)
map(rs,file.move,".",overwrite = TRUE)
unlink("global/", recursive = TRUE) # Remove unneeded directory
# Damage assessment
tifs200<-list.files(".",pattern = "*.tif",recursive = TRUE)
system.time(res200<-lapply(tifs200,damage, n = 100))
# Flood assessment
system.time(result.200<-map_df(tifs200,flood, .id = "tifs200"))
setwd("..")
unlink("./200", recursive = TRUE) # Delete tif directory

## Postprocessing damage results --------------------------------------------------
# Getting large dataframe with ids

r050<-bind_rows(res050)
r100<-bind_rows(res100)
r150<-bind_rows(res150)
r200<-bind_rows(res200)

r050$SLR<-050
r100$SLR<-100
r150$SLR<-150
r200$SLR<-200

result<-rbind(r050,r100,r150,r200)

rm(r050,r100,r150,r200)

# Calculating net flood levels by OLU protection and SLR scenario across OLUs
# Base flood levels (1 non-protection scenario x 30 OLUs x 4 SLR scenarios)
base<-result[which(result$scen == "olu_00000.0.0.000.000000.00000.00.00000.00_depth"), ]
# Flood levels for 30 protection scenarios across 30 OLUs by 4 SLR scenarios
change<-result[which(result$scen != "olu_00000.0.0.000.000000.00000.00.00000.00_depth"), ]
# Merge on SLR scenario and OLU
tresult<-merge(change, base, c("SLR","Name"))
# Net calculations, protection scenario vs baseline
tresult$net.damage<-(tresult$mean.x-tresult$mean.y) 
tresult$net.damage.var<-(tresult$var.x+tresult$var.y) # When subtracting two random variables, add their variances
tresult$net.damage.sd<-sqrt(tresult$net.damage.var) 
tresult$net.impact<-(tresult$impact.x-tresult$impact.y) 

# Removing unneccesary vars
rm(base, change)

# Renaming scenarios to relevant OLUs
tresult$scen.x<-as.character(tresult$scen.x) # Does weird things as a factor
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.00000.01_depth",30,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.00000.10_depth",29,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.00001.00_depth",28,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.00010.00_depth",27,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.00100.00_depth",26,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.01000.00_depth",25,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.00.10000.00_depth",24,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.01.00000.00_depth",23,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00000.10.00000.00_depth",22,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00001.00.00000.00_depth",21,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00010.00.00000.00_depth",20,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.00100.00.00000.00_depth",19,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.01000.00.00000.00_depth",18,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000000.10000.00.00000.00_depth",17,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000001.00000.00.00000.00_depth",16,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000010.00000.00.00000.00_depth",15,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.000100.00000.00.00000.00_depth",14,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.001000.00000.00.00000.00_depth",13,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.010000.00000.00.00000.00_depth",12,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.000.100000.00000.00.00000.00_depth",11,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.001.000000.00000.00.00000.00_depth",10,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.010.000000.00000.00.00000.00_depth",9,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.0.100.000000.00000.00.00000.00_depth",8,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.0.1.000.000000.00000.00.00000.00_depth",7,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00000.1.0.000.000000.00000.00.00000.00_depth",6,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00001.0.0.000.000000.00000.00.00000.00_depth",5,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00010.0.0.000.000000.00000.00.00000.00_depth",4,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_00100.0.0.000.000000.00000.00.00000.00_depth",3,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_01000.0.0.000.000000.00000.00.00000.00_depth",2,tresult$scen.x)
tresult$scen.x<-ifelse(tresult$scen.x == "olu_10000.0.0.000.000000.00000.00.00000.00_depth",1,tresult$scen.x) 
tresult$scen.x<-as.numeric(tresult$scen.x)

# Renaming OLUs using scenario naming convention
tresult$Name<-as.character(tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Golden Gate",30,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Mission - Islais",29,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Yosemite - Visitacion",28,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Colma - San Bruno",27,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "San Mateo",26,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Belmont - Redwood",25,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "San Francisquito",24,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Stevens",23,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Santa Clara Valley",22,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Mowry",21,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Alameda",20,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "San Lorenzo",19,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "San Leandro",18,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "East Bay Crescent",17,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Point Richmond",16,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Wildcat",15,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Pinole",14,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Carquinez South",13,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Walnut",12,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Port Chicago",11,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Montezuma Slough",10,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Suisun Slough",9,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Carquinez North",8,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Napa - Sonoma",7,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Petaluma",6,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Novato",5,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Gallinas",4,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "San Rafael",3,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Corte Madera",2,tresult$Name)
tresult$Name<-ifelse(tresult$Name == "Richardson",1,tresult$Name)
tresult$Name<-as.numeric(tresult$Name)

write.csv(tresult,"tresult.csv")

## Postprocessing flood results --------------------------------------------
# Appending SLR info
result.050$SLR<-50
result.100$SLR<-100
result.150$SLR<-150
result.200$SLR<-200

# Appending scenarios
ras.list.050<-as.data.frame(cbind(tifs050,seq(1:length(tifs050))))
ras.list.100<-as.data.frame(cbind(tifs100,seq(1:length(tifs100))))
ras.list.150<-as.data.frame(cbind(tifs150,seq(1:length(tifs150))))
ras.list.200<-as.data.frame(cbind(tifs200,seq(1:length(tifs200))))
result.050<-merge(result.050,ras.list.050,by.x = "tifs050",by.y = "V2")
result.100<-merge(result.100,ras.list.100,by.x = "tifs100",by.y = "V2")
result.150<-merge(result.150,ras.list.150,by.x = "tifs150",by.y = "V2")
result.200<-merge(result.200,ras.list.200,by.x = "tifs200",by.y = "V2")
colnames(result.050)<-c("scen.index","OLU","count","sum","SLR","scen")
colnames(result.100)<-c("scen.index","OLU","count","sum","SLR","scen")
colnames(result.150)<-c("scen.index","OLU","count","sum","SLR","scen")
colnames(result.200)<-c("scen.index","OLU","count","sum","SLR","scen")

# Merging results
resultf<-rbind(result.050,result.100,result.150,result.200)
rm(ras.list.050,ras.list.100,ras.list.150,ras.list.200,result.050,result.100,result.150,result.200)
resultf$scen.index<-NULL

## Calculating net flood levels by OLU protection and SLR scenario across OLUs
# Base flood levels (1 non-protection scenario x 30 OLUs x 4 SLR scenarios)
base<-resultf[which(resultf$scen == "olu_00000-0-0-000-000000-00000-00-00000-00_depth.tif"), ]
# Flood levels for 30 protection scenarios across 30 OLUs by 4 SLR scenarios
change<-resultf[which(resultf$scen != "olu_00000-0-0-000-000000-00000-00-00000-00_depth.tif"), ]
# Merge on SLR scenario and OLU
fresult<-merge(change, base, c("SLR","OLU"))
# Net calculations
fresult$net.area<-(fresult$count.x-fresult$count.y)*4 # Protection scenario vs baseline, represented as square m (4m2 cells)
fresult$net.volume<-(fresult$sum.x-fresult$sum.y)*4 # Protection scenario vs baseline, represented as cubic meters
# Removing unneccesary vars
rm(base, change)

# Renaming scenarios to relevant OLUs
fresult$scen.x<-as.character(fresult$scen.x) # Does weird things as a factor
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-00000-01_depth.tif",30,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-00000-10_depth.tif",29,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-00001-00_depth.tif",28,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-00010-00_depth.tif",27,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-00100-00_depth.tif",26,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-01000-00_depth.tif",25,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-00-10000-00_depth.tif",24,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-01-00000-00_depth.tif",23,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00000-10-00000-00_depth.tif",22,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00001-00-00000-00_depth.tif",21,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00010-00-00000-00_depth.tif",20,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-00100-00-00000-00_depth.tif",19,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-01000-00-00000-00_depth.tif",18,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000000-10000-00-00000-00_depth.tif",17,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000001-00000-00-00000-00_depth.tif",16,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000010-00000-00-00000-00_depth.tif",15,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-000100-00000-00-00000-00_depth.tif",14,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-001000-00000-00-00000-00_depth.tif",13,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-010000-00000-00-00000-00_depth.tif",12,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-000-100000-00000-00-00000-00_depth.tif",11,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-001-000000-00000-00-00000-00_depth.tif",10,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-010-000000-00000-00-00000-00_depth.tif",9,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-0-100-000000-00000-00-00000-00_depth.tif",8,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-0-1-000-000000-00000-00-00000-00_depth.tif",7,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00000-1-0-000-000000-00000-00-00000-00_depth.tif",6,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00001-0-0-000-000000-00000-00-00000-00_depth.tif",5,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00010-0-0-000-000000-00000-00-00000-00_depth.tif",4,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_00100-0-0-000-000000-00000-00-00000-00_depth.tif",3,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_01000-0-0-000-000000-00000-00-00000-00_depth.tif",2,fresult$scen.x)
fresult$scen.x<-ifelse(fresult$scen.x == "olu_10000-0-0-000-000000-00000-00-00000-00_depth.tif",1,fresult$scen.x) 
fresult$scen.x<-as.numeric(fresult$scen.x)

# Renaming OLUs using scenario naming convention
fresult$OLU<-as.character(fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Golden Gate",30,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Mission - Islais",29,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Yosemite - Visitacion",28,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Colma - San Bruno",27,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "San Mateo",26,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Belmont - Redwood",25,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "San Francisquito",24,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Stevens",23,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Santa Clara Valley",22,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Mowry",21,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Alameda",20,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "San Lorenzo",19,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "San Leandro",18,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "East Bay Crescent",17,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Point Richmond",16,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Wildcat",15,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Pinole",14,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Carquinez South",13,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Walnut",12,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Port Chicago",11,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Montezuma Slough",10,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Suisun Slough",9,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Carquinez North",8,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Napa - Sonoma",7,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Petaluma",6,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Novato",5,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Gallinas",4,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "San Rafael",3,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Corte Madera",2,fresult$OLU)
fresult$OLU<-ifelse(fresult$OLU == "Richardson",1,fresult$OLU)
fresult$OLU<-as.numeric(fresult$OLU)

write.csv(fresult,"fresult.csv")

