pacman::p_load(dplyr, terra, sf)

##Obtaining occurrences from example
load("data/CucurbitaData.rda")
##Obtaining Raster_list
load("data/CucurbitaRasts.rda")
##Obtaining protected areas raster
load("data/protectAreasRast.rda")
## ecoregions
load("data/ecoExample.rda")


# prep for the function
taxon <- CucurbitaData$species[1]
sdm <- terra::unwrap(CucurbitaRasts)[[1]]
occurrence_Data <- CucurbitaData
ecoregions <- terra::vect(eco1)
source("R/generateGBuffers.R")
source("R/generateCounts.R")
gBuffer <- generateGBuffers(taxon = taxon,
                            occurrence_Data = occurrence_Data,
                            bufferDistM =  50000)
##DC  so this is potential a process that we can call inside of the functions. Keeping seperate
## means it's only ran once but it's anothing object for the users to manage



# source individual functions
source("R/ERSex.R")
source("R/SRSex.R")
source("R/GRSex.R")

# generate objects
srsex <- SRSex(taxon = taxon,
               occurrence_Data = occurrence_Data)
grsex <- GRSex(taxon = taxon,
               sdm = sdm,
               gBuffer = gBuffer)
ersex <- ERSex(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data, gBuffer = gBuffer,
               ecoregions = ecoregions, idColumn = "ECO_ID_U")
source("R/FCSex.R")

fcsex <- FCSex(taxon = taxon,
               srsex = srsex,
               grsex = grsex,
               ersex = ERSex(taxon = taxon,
                             sdm = sdm,
                             occurrence_Data = occurrence_Data, gBuffer = gBuffer,
                             ecoregions = ecoregions, idColumn = "ECO_ID_U"))

# insitu
source("R/ERSin.R")
source("R/SRSin.R")
source("R/GRSin.R")

# protect areas
protectAreasRast <- terra::unwrap(protectAreasRast)

ersin <- ERSin(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data,
               protected_Areas = protectAreasRast,
               ecoregions = ecoregions,
               idColumn = "ECO_ID_U")


# next steps for test  ----------------------------------------------------


##################### PART I : Run for 1 species #########################
## work up single species workflow


##### SG code below:

## test using a for loop

# prep list of species
taxa <- list(CucurbitaData$species[1])  # Using the first species as an example

## DC : this looks good but we need a place to store resutls. I general like
## creating a DF before and using indexing to assign values or
## having a codition that test if it's the first the binds values
## if(i = 1){
#   output <- df
# }else{
#   output <- bind_rows(output,df)
# }
## also named list could be really good here as well

## please build something out so that users can retrieve results after the runs


for (taxon in taxa) {
  # Assign the data for the selected taxon
  sdm <- terra::unwrap(CucurbitaRasts)[[1]]
  occurrence_Data <- CucurbitaData
  ecoregions <- terra::vect(eco1)
  protectAreasRast <- terra::unwrap(protectAreasRast)

  # Generate gBuffer
  gBuffer <- generateGBuffers(taxon = taxon,
                              occurrence_Data = occurrence_Data,
                              bufferDistM = 50000)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon,
                 occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon,
                 sdm = sdm,
                 gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon,
                 sdm = sdm,
                 occurrence_Data = occurrence_Data,
                 gBuffer = gBuffer,
                 ecoregions = ecoregions,
                 idColumn = "ECO_ID_U")

  # Generate FCSex
  fcsex <- FCSex(taxon = taxon,
                 srsex = srsex,
                 grsex = grsex,
                 ersex = ersex)

  # In-situ analysis
  ersin <- ERSin(taxon = taxon,
                 sdm = sdm,
                 occurrence_Data = occurrence_Data,
                 protected_Areas = protectAreasRast,
                 ecoregions = ecoregions,
                 idColumn = "ECO_ID_U")

  # Print results for validation
  print(paste("Taxon:", taxon))
  print(fcsex)
  print(ersin)

}

View(results_list)




## test purrr implementation

# prep species list
speciesList <- list(CucurbitaData$species[1])  # Using the first species as an example
sdms <- list(terra::unwrap(CucurbitaRasts)[[1]])

## DC
# we want some test, if possible to ensure that species names are alined with sdms
# this is tricky because we won't be able to control how people name thier objects. so
# maybe just as little as a print(names(specieslist))==names(sdms))
# this is more about the worked examples for the documentation then anything. applies to for loop as well.


## implement purr::map2 function

purrr::map2(
  .x = speciesList,
  .y = sdms,
  .f = function(taxon, sdm) {
    # Assign the data for the selected taxon
    occurrence_Data <- CucurbitaData
    ecoregions <- terra::vect(eco1)
    protectAreasRast <- terra::unwrap(protectAreasRast)

    # Generate gBuffer
    gBuffer <- generateGBuffers(taxon = taxon,
                                occurrence_Data = occurrence_Data,
                                bufferDistM = 50000)

    # Generate objects for each function
    srsex <- SRSex(taxon = taxon,
                   occurrence_Data = occurrence_Data)
    grsex <- GRSex(taxon = taxon,
                   sdm = sdm,
                   gBuffer = gBuffer)
    ersex <- ERSex(taxon = taxon,
                   sdm = sdm,
                   occurrence_Data = occurrence_Data,
                   gBuffer = gBuffer,
                   ecoregions = ecoregions,
                   idColumn = "ECO_ID_U")

    # Generate FCSex
    fcsex <- FCSex(taxon = taxon,
                   srsex = srsex,
                   grsex = grsex,
                   ersex = ersex)

    # In-situ analysis
    ersin <- ERSin(taxon = taxon,
                   sdm = sdm,
                   occurrence_Data = occurrence_Data,
                   protected_Areas = protectAreasRast,
                   ecoregions = ecoregions,
                   idColumn = "ECO_ID_U")

    # Print or log results for validation
    print(paste("Taxon:", taxon))
    print(fcsex)
    print(ersin)

    # here is where a list could be nice
    # output <- list(
    #   srsin = srsin,
    #   ersin - ersin,...
    # )
    # we just need to give them results as objects
  }
)

### SG notes:
# results do not differ for both implementations of example species 1: Cucurbita_cordata








##################### PART II : Run with Vitis data #########################

# D.Carver sent Vitis data, located in Drive

# D.Carver note from email:
# When you get to the Vitis evaluation, you can use the spatialData.gpkg  for the input occurrence data.
# This will not produce the same results for the srsex measure,
# but it should for all the other ones that require spatial data.
# The prj_threshold.tif is the distribution model for a given species.




##############################################################delete below
# prep for the function
pacman::p_load(dplyr, terra, sf)
# Load Vitis data
# Load occurrence data
# spatial_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/spatialData.gpkg"
# occurrence_Data <- sf::st_read(spatial_data_path)


# Load distribution model
sdm_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/results/prj_threshold.tif"
sdm <- terra::rast(sdm_path)

# Load counts data
# counts_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/counts.csv"
# counts_Data <- read.csv(counts_data_path)

# Load all model data
allmodel_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/allmodelData.csv"
allmodel_Data <- read.csv(allmodel_data_path)


## DC
# want should only require a csv of occurrence data and the sdms.

# Load variable selection data
# variable_selection_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/variableSelectionData.csv"
# variableSelection_Data <- readr::read_csv(variable_selection_data_path)
# error in read in

# no data on protected areas land rasters and ecoregions?

#DC  I'll share those files

##DC  first step is prepping the csv data to the required format for the library.
## the specific of this will differ from user to use so just showcase how to translate the data
## from the csv for arizonica in to a terra vect object with the correct col names

# prep for the function
taxon <- occurrence_Data$taxon[1]
# Generate buffers
source("R/generateGBuffers.R")
gBuffer <- generateGBuffers(taxon = taxon,
                            occurrence_Data = occurrence_Data,
                            bufferDistM = 50000)
# getting an error:
# Error in .local(x, ...) : unused argument (geom = c("longitude", "latitude"))
# SG ran manually?:

## DC this is type of error we want to resolve
## open uo the generateGBuffer files
## assing variable in console so you've got the in memeory
## then go line by line to see what's causing the errors.
## my guess in this case is that we reqiore a terra object not an sf


# Set buffer distance (in meters)
bufferDistM <- 50000  # 50 km
# Create buffers around the occurrence points             #<<<<<<<<<<<<<
gBuffer <- sf::st_buffer(occurrence_Data, dist = bufferDistM)  # <<<<<<<<<<<

## structure is fine here should be able to run once you pull datasets I'll provide

# Source individual functions
source("R/ERSex.R")
source("R/SRSex.R")
source("R/GRSex.R")

# Generate objects for each function
srsex <- SRSex(taxon = "Vitis arizonica",
               occurrence_Data = occurrence_Data)
grsex <- GRSex(taxon = "Vitis arizonica",
               sdm = sdm,
               gBuffer = gBuffer)
ersex <- ERSex(taxon = "Vitis arizonica",
               sdm = sdm,
               occurrence_Data = occurrence_Data,
               gBuffer = gBuffer,
               ecoregions = NULL,  # No ecoregions file?
               idColumn = NULL)    # No ecoregion ID column bc no ecoregion file?










#### try 2: ############################################# delete below
# D.Carver sent Vitis data, located in Drive

# D.Carver note from email:
# When you get to the Vitis evaluation, you can use the spatialData.gpkg for the input occurrence data.
# This will not produce the same results for the srsex measure,
# but it should for all the other ones that require spatial data.
# The prj_threshold.tif is the distribution model for a given species.

# Prep for the function
pacman::p_load(dplyr, terra, sf)

# Load all the Vitis data
# Occurrence Data
# Distribution Model
# Counts Data
# All Model Data
# Variable Selection Data


##DC  first step is prepping the csv data to the required format for the library.
## the specific of this will differ from user to use so just showcase how to translate the data
## from the csv for arizonica in to a terra vect object with the correct col names


# Load occurrence data as sf object
spatial_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/spatialData.gpkg"
occurrence_Data_sf <- sf::st_read(spatial_data_path)

# Convert to data frame and make longitude and latitude columns readable
occurrence_Data <- data.frame(occurrence_Data_sf)
occurrence_Data$longitude <- sf::st_coordinates(occurrence_Data_sf)[,1]
occurrence_Data$latitude <- sf::st_coordinates(occurrence_Data_sf)[,2]

# Rename column to match the function's requirements
occurrence_Data <- dplyr::rename(occurrence_Data,
                                 species = taxon, #contains the data we want, full taxon name
                                 Species = species #rename actual species column name
                                  )
# Load distribution model
sdm_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/results/prj_threshold.tif"
sdm <- terra::rast(sdm_path)

# Load protected areas land raster data
protected_area_raster_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/wdpa_rasterized_all.tif"
protectedAreaRaster <- terra::rast(protected_area_raster_path)



# Load ecoregions data as sf object
ecoregions_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/tnc_terr_ecoregions.gpkg"
ecoregions_Data_sf <- sf::st_read(ecoregions_data_path)

# Drop the geometry column and convert to data frame
ecoregions_Data <- sf::st_drop_geometry(ecoregions_Data_sf)

# Check the conversion
str(ecoregions_Data)
head(ecoregions_Data)

# Ensure proper data types for relevant columns
ecoregions_Data$ECO_ID_U <- as.character(ecoregions_Data$ECO_ID_U)

# Convert to data.table for efficient processing
ecoregions_Data <- as.data.table(ecoregions_Data)



# Prep for function
# filter for the species we want and for the type, G
taxon <- "Vitis arizonica"
filtered_occurrence_Data <- occurrence_Data |>
  dplyr::filter(species == taxon & type == "G")
bufferDistM <- 50000

# source gBuffer function and run
source("R/generateGBuffers.R")
gBuffer <- generateGBuffers(taxon = taxon,
                            occurrence_Data = filtered_occurrence_Data,
                            bufferDistM = bufferDistM)


# Source individual functions
source("R/ERSex.R")
source("R/SRSex.R")
source("R/GRSex.R")

# Generate objects for each function
srsex <- SRSex(taxon = taxon,
               occurrence_Data = occurrence_Data)
grsex <- GRSex(taxon = taxon,
               sdm = sdm,
               gBuffer = gBuffer)
ersex <- ERSex(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data,
               gBuffer = gBuffer,
               ecoregions = ecoregions_Data,
               idColumn = "ECO_ID_U")


source("R/FCSex.R")

fcsex <- FCSex(taxon = taxon,
               srsex = srsex,
               grsex = grsex,
               ersex = ERSex(taxon = taxon,
                             sdm = sdm,
                             occurrence_Data = occurrence_Data, gBuffer = gBuffer,
                             ecoregions = ecoregions_Data, idColumn = "ECO_ID_U"))








# Convert ecoregions_Data_sf to a data frame and ensure geometry is intact
ecoregions_Data <- st_drop_geometry(ecoregions_Data_sf)

# Check the structure and column names
str(ecoregions_Data)
colnames(ecoregions_Data)

# Ensure proper data types for relevant columns
ecoregions_Data$ECO_ID_U <- as.character(ecoregions_Data$ECO_ID_U)



# Ensure CRS for ecoregions_Data and occurrence_Data match
crs_ecoregions <- st_crs(ecoregions_Data_sf)
crs_occurrence <- st_crs(occurrence_Data_sf)

# Print CRS to verify
print(crs_ecoregions)
print(crs_occurrence)

# Explicitly set the CRS for ecoregions_Data to WGS 84 (EPSG 4326)
sf::st_crs(ecoregions_Data_sf) <- 4326

# Verify the CRS is now set correctly
print(sf::st_crs(ecoregions_Data_sf))


# Ensure geometries of ecoregions_Data_sf are valid
ecoregions_Data_sf <- sf::st_make_valid(ecoregions_Data_sf)

# Ensure geometries of filtered_occurrence_Data are valid
filtered_occurrence_Data <- terra::makeValid(terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=sf::st_crs(ecoregions_Data_sf)$proj4string))

# Re-run the intersection with matching CRS
d1 <- filtered_occurrence_Data
inter <- terra::intersect(x = d1, y = ecoregions_Data_sf) |> terra::as.data.frame()

# Print the structure and column names to verify
str(inter)
colnames(inter)





### try 3:
# Load necessary libraries
pacman::p_load(dplyr, terra, sf, data.table)

# Load occurrence data as sf object
spatial_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/spatialData.gpkg"
occurrence_Data_sf <- sf::st_read(spatial_data_path)

# Convert to data frame and make longitude and latitude columns readable
occurrence_Data <- data.frame(occurrence_Data_sf)
occurrence_Data$longitude <- sf::st_coordinates(occurrence_Data_sf)[, 1]
occurrence_Data$latitude <- sf::st_coordinates(occurrence_Data_sf)[, 2]

# Rename columns to match the function's requirements
occurrence_Data <- dplyr::rename(occurrence_Data, species = taxon, Species = species)


taxon <- "Vitis arizonica"
filtered_occurrence_Data <- occurrence_Data |>
  dplyr::filter(species == taxon & type == "G")

# Load protected areas raster data
protected_area_raster_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/wdpa_rasterized_all.tif"
protectAreasRast <- terra::rast(protected_area_raster_path)


# Load ecoregions data as sf object
ecoregions_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/tnc_terr_ecoregions.gpkg"
ecoregions_Data_sf <- sf::st_read(ecoregions_data_path)

# Explicitly set the CRS for ecoregions_Data_sf to WGS 84 (EPSG 4326)
sf::st_crs(ecoregions_Data_sf) <- 4326

ecoregions_Data_sf$ECO_ID_U <- as.character(ecoregions_Data_sf$ECO_ID_U)

ecoregions_Data <- terra::vect(ecoregions_Data_sf)
ecoregions_Data <- terra::makeValid(ecoregions_Data)

crs_wgs84 <- "+proj=longlat +datum=WGS84 +no_defs"
d1 <- terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=crs_wgs84)

# Ensure valid geometries
d1 <- terra::makeValid(d1)

# Load distribution model
sdm_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/results/prj_threshold.tif"
sdm <- terra::rast(sdm_path)


# Prep for function
# filter for the species we want and for the type, G
taxon <- "Vitis arizonica"
filtered_occurrence_Data <- occurrence_Data |>
  dplyr::filter(species == taxon & type == "G")
bufferDistM <- 50000

# source gBuffer function and run
source("R/generateGBuffers.R")
gBuffer <- generateGBuffers(taxon = taxon,
                            occurrence_Data = filtered_occurrence_Data,
                            bufferDistM = bufferDistM)
print(gBuffer)

# Source individual functions
source("R/ERSex.R")
source("R/SRSex.R")
source("R/GRSex.R")

# Generate objects for each function
srsex <- SRSex(taxon = taxon,
               occurrence_Data = occurrence_Data)
print(srsex)
grsex <- GRSex(taxon = taxon,
               sdm = sdm,
               gBuffer = gBuffer)
print(grsex)
ersex <- ERSex(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data,
               gBuffer = gBuffer,
               ecoregions = ecoregions_Data,
               idColumn = "ECO_ID_U")
print(ersex)

source("R/FCSex.R")
fcsex <- FCSex(taxon = taxon,
               srsex = srsex,
               grsex = grsex,
               ersex = ERSex(taxon = taxon,
                             sdm = sdm,
                             occurrence_Data = occurrence_Data,
                             gBuffer = gBuffer,
                             ecoregions = ecoregions_Data,
                             idColumn = "ECO_ID_U"))

print(fcsex)



# insitu
source("R/ERSin.R")
source("R/SRSin.R")
source("R/GRSin.R")














# Crop the protected areas raster to match the extent of the sdm
protected_Areas <- terra::crop(protected_Areas, terra::ext(sdm))

# Ensure the CRS for all datasets is consistent
crs_wgs84 <- "+proj=longlat +datum=WGS84 +no_defs"
terra::crs(protected_Areas) <- crs_wgs84
terra::crs(ecoregions_Data) <- crs_wgs84
terra::crs(sdm) <- crs_wgs84

# Print the extents again to verify alignment
print(terra::ext(sdm))
print(terra::ext(protected_Areas))
print(terra::ext(ecoregions_Data))

# Filter the occurrence data for the species of interest
filtered_occurrence_Data <- occurrence_Data |>
  dplyr::filter(species == taxon & type == "G")

# Convert to SpatVector with CRS
d1 <- terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=crs_wgs84)
d1 <- terra::makeValid(d1)





#started here 110:50am
# Load necessary libraries
pacman::p_load(dplyr, terra, sf, data.table)

# Load occurrence data as sf object
spatial_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/spatialData.gpkg"
occurrence_Data_sf <- sf::st_read(spatial_data_path)

# Convert to data frame and make longitude and latitude columns readable
occurrence_Data <- data.frame(occurrence_Data_sf)
occurrence_Data$longitude <- sf::st_coordinates(occurrence_Data_sf)[, 1]
occurrence_Data$latitude <- sf::st_coordinates(occurrence_Data_sf)[, 2]

# Rename columns to match the function's requirements
occurrence_Data <- dplyr::rename(occurrence_Data, species = taxon, Species = species)

# Filter for the species of interest
taxon <- "Vitis arizonica"
filtered_occurrence_Data <- occurrence_Data |>
  dplyr::filter(species == taxon & type == "G")

# Convert filtered occurrence data to SpatVector with CRS
crs_wgs84 <- "+proj=longlat +datum=WGS84 +no_defs"
d1 <- terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=crs_wgs84)
d1 <- terra::makeValid(d1)

# Check the structure and summary of d1
print(d1)


# Load protected areas raster and ensure CRS
protected_Areas <- terra::rast("C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/wdpa_rasterized_all.tif")
terra::crs(protected_Areas) <- crs_wgs84

# Load the species distribution model (SDM)
sdm_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/results/prj_threshold.tif"
sdm <- terra::rast(sdm_path)
terra::crs(sdm) <- crs_wgs84

# Crop the protected areas raster to match the extent of the sdm
protected_Areas <- terra::crop(protected_Areas, terra::ext(sdm))

# Load ecoregions data as sf object and ensure CRS
ecoregions_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/tnc_terr_ecoregions.gpkg"
ecoregions_Data_sf <- sf::st_read(ecoregions_data_path)
sf::st_crs(ecoregions_Data_sf) <- 4326
ecoregions_Data <- terra::vect(ecoregions_Data_sf)
terra::crs(ecoregions_Data) <- crs_wgs84

# Crop the protected areas raster to match the extent of the sdm
protected_Areas <- terra::crop(protected_Areas, terra::ext(sdm))

# Resample protected_Areas to match sdm
protected_Areas <- terra::resample(protected_Areas, sdm, method = "bilinear")

# Print the extents again to verify alignment
print(terra::ext(sdm))
print(terra::ext(protected_Areas))
print(terra::ext(ecoregions_Data))
print(terra::ext(d1))      # smaller

# Run the ERSin function
ersin <- ERSin(taxon = taxon,
               sdm = sdm,
               occurrence_Data = d1,
               protected_Areas = protected_Areas,
               ecoregions = ecoregions_Data,
               idColumn = "ECO_ID_U")

# Print the result
print(ersin)







# Filter for the species of interest as a data frame ##############################
taxon <- "Vitis arizonica"
filtered_occurrence_Data <- occurrence_Data |>
  dplyr::filter(species == taxon & type == "G")

# Convert filtered occurrence data to SpatVector with CRS
crs_wgs84 <- "+proj=longlat +datum=WGS84 +no_defs"
d1 <- terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=crs_wgs84)
d1 <- terra::makeValid(d1)

# Check the structure and summary of d1
print(d1)


# Align the extent of protected_Areas to match the exact extent of sdm
protected_Areas <- terra::crop(protected_Areas, terra::ext(sdm))
protected_Areas <- terra::resample(protected_Areas, sdm, method = "bilinear")

# Ensure CRS for all datasets is consistent
terra::crs(protected_Areas) <- crs_wgs84
terra::crs(ecoregions_Data) <- crs_wgs84
terra::crs(sdm) <- crs_wgs84
terra::crs(d1) <- crs_wgs84

# Print the extents to verify alignment
print(terra::ext(sdm))
print(terra::ext(protected_Areas))
print(terra::ext(ecoregions_Data))
print(terra::ext(d1))

# Run the ERSin function
ersin <- ERSin(taxon = taxon,
               sdm = sdm,
               occurrence_Data = filtered_occurrence_Data,  # Use the filtered data frame
               protected_Areas = protected_Areas,
               ecoregions = ecoregions_Data,
               idColumn = "ECO_ID_U")

# Print the result
print(ersin)



###################### test using a for loop
# prep list of species
taxa <- list("Vitis arizonica")

for (taxon in taxa) {
  # Load occurrence data for the specific taxon
  occurrence_Data_sf <- sf::st_read(occurrence_data_path)
  occurrence_Data <- data.frame(occurrence_Data_sf)
  occurrence_Data$longitude <- sf::st_coordinates(occurrence_Data_sf)[, 1]
  occurrence_Data$latitude <- sf::st_coordinates(occurrence_Data_sf)[, 2]
  occurrence_Data <- dplyr::rename(occurrence_Data, species = taxon, Species = species)

  # Filter data for the taxon
  filtered_occurrence_Data <- occurrence_Data |>
    dplyr::filter(species == taxon & type == "G")

  # Ensure valid geometries
  crs_wgs84 <- "+proj=longlat +datum=WGS84 +no_defs"
  d1 <- terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=crs_wgs84)
  d1 <- terra::makeValid(d1)

  # Load distribution model
  sdm <- terra::rast(sdm_path)

  # Generate gBuffer
  bufferDistM <- 50000
  gBuffer <- generateGBuffers(taxon = taxon,
                              occurrence_Data = filtered_occurrence_Data,
                              bufferDistM = bufferDistM)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon,
                 occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon,
                 sdm = sdm,
                 gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon,
                 sdm = sdm,
                 occurrence_Data = occurrence_Data,
                 gBuffer = gBuffer,
                 ecoregions = ecoregions_Data,
                 idColumn = "ECO_ID_U")

  # Generate FCSex
  fcsex <- FCSex(taxon = taxon,
                 srsex = srsex,
                 grsex = grsex,
                 ersex = ersex)

  # In-situ analysis
  ersin <- ERSin(taxon = taxon,
                 sdm = sdm,
                 occurrence_Data = filtered_occurrence_Data,
                 protected_Areas = protectAreasRast,
                 ecoregions = ecoregions_Data,
                 idColumn = "ECO_ID_U")

  # Print or log results for validation
  print(paste("Taxon:", taxon))
  print(fcsex)
  print(ersin)

}





##################### PART III: Run with different data sources #########################
# gather 2 ecoregion files and test results
# column: ECO_ID_U
