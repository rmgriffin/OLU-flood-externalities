# OLU-flood-externalities
Expected damage function analysis and figures for "Economic evaluation of sea-level rise adaptation strongly influenced by hydrodynamic feedbacks" in Proceedings of the National Academy of Sciences DOI: 10.1073/pnas.2025961118

Steps to run analysis:

1. Run R script "Damage-volume-analysis.R" - this script downloads flood rasters and other data (see below) for all four sea level rise scenarios, and then produces dataframes of flood volumes and flood damages for protecting operational landscape units in San Francisco Bay. Results can be summarized by census block or operational landscape unit. The downloading process relies on Google Drive and the package googledrive in R. As the flood rasters altogether are over 500GB, this poses some challenges. First, a fast broadband connection is recommended. Second, I cannot confirm if this is an issue with the googledrive package, or an issue with google, but after a certain amount of downloading the script runs into an error. This means that you cannot leave it to automatically download all required files, but will need to check in on it from time to time and restart downloading for the uncompleted downloads. An option to speed this process up is to move to a different google drive folder and start downloading those (i.e. if you were downloading rasters for 50cm of sea level rise and an error occurred, move ahead to 100cm and then return to 50cm =). You may also download data from the two Dryad repositories associated with the paper verus using the google drive approach, just make sure to store them in an appropriately named folder for the script to find them. 
https://doi.org/10.5061/dryad.2z34tmpmb
https://doi.org/10.5061/dryad.g79cnp5pt
2. Run Figures-tables.Rmd - this will draw in the results of "Damage-volume-analysis" and other supplementary data from "Figures-tables-data.R" (using googledrive R package, though here it should be automatic as the size of the files are reasonable), and will produce analysis and figures that are in the paper. 

Files:

- 000cm folder: Flood depth raster for current conditions
- 050cm folder: Flood depth rasters for 50cm of sea level rise
- 100cm folder: Flood depth rasters for 100cm of sea level rise
- 150cm folder: Flood depth rasters for 150cm of sea level rise
- 200cm folder: Flood depth rasters for 200cm of sea level rise
- Contents_damage.csv: Damage functions for different building types' contents, from US Army Corps of Engineers
- Exposure4OLU3.gpkg: Geopackage with area (sq ft) of different building types per census block
- hzMeansCountyLocationFactor.csv: List of cost adjustment factors for repair costs by FIPS code, FEMA HAZUS
- NLCD_2016_Land_Cover_L48_20190424.tif: 2016 National Land Cover Database raster 
- NLCD_Colour_Classification_Update.jpg: Legend to interpret NLCD_2016_Land_Cover_L48_20190424.tif
- olu_dem90m.tif: Digital elevation raster within OLUs, 90m resolution http://purl.stanford.edu/vq725mh7108
- olu_NAD83_10N.gpkg: Vector layer with Operational Landscape Unit polygons
- Replacement_cost.csv: Replacement costs per sq ft for different building classifications, from FEMA HAZUS
- Shoreline.gpkg: Global vector layer that classifies nearshore coastal systems, from Electronic Supplementary Material of https://dx.doi.org/10.1007/s12237-011-9381-y
- Structures_damage.csv: Damage functions for different building types, from US Army Corps of Engineers 
- srtmv4_30s.tif: Global DEM from Shuttle Radar Topography Mission version 4 from CGIAR
- ppp_2020_1km_Aggregated.tif: WorldPop global population raster 2020 DOI: 10.5258/SOTON/WP00647
- dasymetric_us_20160208.tif: US dasymetric population from EPA EnviroAtlas
- Roads_2015.gpkg: US Census TIGER/Line Roads

Each SLR scenario folder contains 31 simulations (no protection + 30 OLUs protected individually). The naming convention is: olu_10000-0-0-000-000000-00000-00-00000-00_depth.tif, where the indices start with OLU 1 (Richardson), see Fig. 1 in the paper for reference, and move clockwise around the Bay (0=not protected, 1=protected). The dashes separate the OLUs into the 9 counties. olu_00000-0-0-000-000000-00000-00-00000-00_depth.tif represents no OLU protected.

Contact Michelle Hummel at her contact email in the paper for code that generated the flood depth rasters.
