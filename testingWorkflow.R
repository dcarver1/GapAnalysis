############### SINGLE SPECIES WORKED EXAMPLE for README ##################################

# Load libraries
pacman::p_load(dplyr, terra, sf)

##Obtaining occurrences from example
load("data/CucurbitaData.rda")
##Obtaining Raster_list
load("data/CucurbitaRasts.rda")
##Obtaining protected areas raster
load("data/protectAreasRast.rda")
## ecoregions
load("data/ecoExample.rda")

# Prep for the function
taxon <- CucurbitaData$species[1]
sdm <- terra::unwrap(CucurbitaRasts)[[1]]
occurrence_Data <- CucurbitaData
ecoregions <- terra::vect(eco1)
source("R/generateGBuffers.R")
source("R/generateCounts.R")
gBuffer <- generateGBuffers(taxon = taxon,
                            occurrence_Data = occurrence_Data,
                            bufferDistM =  50000)

# Source individual functions
source("R/ERSex.R")
source("R/SRSex.R")
source("R/GRSex.R")
source("R/FCSex.R")

# Generate objects
srsex <- SRSex(taxon = taxon,
               occurrence_Data = occurrence_Data)
grsex <- GRSex(taxon = taxon,
               sdm = sdm,
               gBuffer = gBuffer)
ersex <- ERSex(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data, gBuffer = gBuffer,
               ecoregions = ecoregions, idColumn = "ECO_ID_U")
fcsex <- FCSex(taxon = taxon,
               srsex = srsex,
               grsex = grsex,
               ersex = ersex)

# In-situ
source("R/ERSin.R")
source("R/SRSin.R")
source("R/GRSin.R")

# Protect areas
protectAreasRast <- terra::unwrap(protectAreasRast)

ersin <- ERSin(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data,
               protected_Areas = protectAreasRast,
               ecoregions = ecoregions,
               idColumn = "ECO_ID_U")

# Print results
print(paste("Taxon:", taxon))
print(fcsex)
print(ersin)



####### VIGNETTE WITH MULTIPLE ITERATIONS ######################################

# Load libraries
pacman::p_load(dplyr, terra, sf)

## Obtaining occurrences from example
load("data/CucurbitaData.rda")
## Obtaining Raster_list
load("data/CucurbitaRasts.rda")
## Obtaining protected areas raster
load("data/protectAreasRast.rda")
## ecoregions
load("data/ecoExample.rda")

# Prep list of species
taxa <- unique(CucurbitaData$species)

###############################################################################
### Method 1: Pre-create a dataframe

# Create an empty dataframe to store results
results_df <- data.frame()

# Run using a for loop
for (i in seq_along(taxa)) {
  taxon <- taxa[i]

  # Assign the data for the selected taxon
  sdm <- terra::unwrap(CucurbitaRasts)[[i]]
  occurrence_Data <- CucurbitaData[CucurbitaData$species == taxon, ]
  ecoregions <- terra::vect(eco1)
  protectAreasRast <- terra::unwrap(protectAreasRast)

  # Generate gBuffer
  gBuffer <- generateGBuffers(taxon = taxon, occurrence_Data = occurrence_Data, bufferDistM = 50000)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon, occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon, sdm = sdm, gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, gBuffer = gBuffer, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  # Generate FCSex
  fcsex <- FCSex(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex)

  # In-situ analysis
  ersin <- ERSin(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, protected_Areas = protectAreasRast, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  # Store results in the dataframe
  results_df <- rbind(results_df, data.frame(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex, fcsex = fcsex, ersin = ersin))

  # Print results
  print(paste("Taxon:", taxon))
  print(srsex)
  print(grsex)
  print(ersex)
  print(fcsex)
  print(ersin)
}


###############################################################################
### Method 2: Conditional Binding

# Create an empty dataframe to store results
results_df <- NULL

# Run using a for loop
for (i in seq_along(taxa)) {
  taxon <- taxa[i]

  # Assign the data for the selected taxon
  sdm <- terra::unwrap(CucurbitaRasts)[[i]]
  occurrence_Data <- CucurbitaData[CucurbitaData$species == taxon, ]
  ecoregions <- terra::vect(eco1)
  protectAreasRast <- terra::unwrap(protectAreasRast)

  # Generate gBuffer
  gBuffer <- generateGBuffers(taxon = taxon, occurrence_Data = occurrence_Data, bufferDistM = 50000)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon, occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon, sdm = sdm, gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, gBuffer = gBuffer, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  # Generate FCSex
  fcsex <- FCSex(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex)

  # In-situ analysis
  ersin <- ERSin(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, protected_Areas = protectAreasRast, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  # Store results using conditional binding
  if (is.null(results_df)) {
    results_df <- data.frame(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex, fcsex = fcsex, ersin = ersin)
  } else {
    results_df <- bind_rows(results_df, data.frame(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex, fcsex = fcsex, ersin = ersin))
  }

  # Print results
  print(paste("Taxon:", taxon))
  print(srsex)
  print(grsex)
  print(ersex)
  print(fcsex)
  print(ersin)
}


###############################################################################
### Method 3: Named List

# Create an empty named list to store results
results_list <- list()

# Run using a for loop
for (i in seq_along(taxa)) {
  taxon <- taxa[i]

  # Assign the data for the selected taxon
  sdm <- terra::unwrap(CucurbitaRasts)[[i]]
  occurrence_Data <- CucurbitaData[CucurbitaData$species == taxon, ]
  ecoregions <- terra::vect(eco1)
  protectAreasRast <- terra::unwrap(protectAreasRast)

  # Generate gBuffer
  gBuffer <- generateGBuffers(taxon = taxon, occurrence_Data = occurrence_Data, bufferDistM = 50000)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon, occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon, sdm = sdm, gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, gBuffer = gBuffer, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  # Generate FCSex
  fcsex <- FCSex(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex)

  # In-situ analysis
  ersin <- ERSin(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, protected_Areas = protectAreasRast, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  # Store the results in the named list
  results_list[[taxon]] <- list(srsex = srsex, grsex = grsex, ersex = ersex, fcsex = fcsex, ersin = ersin)

  # Print results
  print(paste("Taxon:", taxon))
  print(srsex)
  print(grsex)
  print(ersex)
  print(fcsex)
  print(ersin)
}


###############################################################################
### Method 4: purrr::map2

# Load package
library(purrr)

# Prep list of species
speciesList <- unique(CucurbitaData$species)
sdms <- lapply(1:length(speciesList), function(i) terra::unwrap(CucurbitaRasts)[[i]])

# Run purrr::map2 function to generate metrics for all taxa
results <- purrr::map2(speciesList, sdms, ~ {
  taxon <- .x
  sdm <- .y

  # Assign the data for the selected taxon
  occurrence_Data <- CucurbitaData[CucurbitaData$species == taxon, ]
  ecoregions <- terra::vect(eco1)
  protectAreasRast <- terra::unwrap(protectAreasRast)

  # Generate gBuffer
  gBuffer <- generateGBuffers(taxon = taxon, occurrence_Data = occurrence_Data, bufferDistM = 50000)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon, occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon, sdm = sdm, gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, gBuffer = gBuffer, ecoregions = ecoregions, idColumn = "ECO_ID_U")
  fcsex <- FCSex(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex)
  ersin <- ERSin(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, protected_Areas = protectAreasRast, ecoregions = ecoregions, idColumn = "ECO_ID_U")

  list(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex, fcsex = fcsex, ersin = ersin)
})

# Display results
results






######## SG stopped here, 2025_02_21


##################### PART II : Run with Vitis data #########################


############ Vitis arizonica run

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

# Load protected areas raster data and set correct CRS for function
protected_area_raster_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/wdpa_rasterized_all.tif"
protected_Areas <- terra::rast(protected_area_raster_path)
crs_wgs84 <- "+proj=longlat +datum=WGS84 +no_defs"
terra::crs(protected_Areas) <- crs_wgs84

# Load the species distribution model (SDM)
sdm_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/results/prj_threshold.tif"
sdm <- terra::rast(sdm_path)
terra::crs(sdm) <- crs_wgs84

# Crop and resample the protected areas raster to match the extent of the sdm
protected_Areas <- terra::crop(protected_Areas, terra::ext(sdm))
protected_Areas <- terra::resample(protected_Areas, sdm, method = "bilinear")

# Load ecoregions data as sf object and set CRS
ecoregions_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/tnc_terr_ecoregions.gpkg"
ecoregions_Data_sf <- sf::st_read(ecoregions_data_path)
sf::st_crs(ecoregions_Data_sf) <- 4326
ecoregions_Data <- terra::vect(ecoregions_Data_sf)
terra::crs(ecoregions_Data) <- crs_wgs84
ecoregions_Data <- terra::makeValid(ecoregions_Data)

# Source functions
source("R/generateGBuffers.R")
source("R/ERSex.R")
source("R/SRSex.R")
source("R/GRSex.R")
source("R/FCSex.R")
source("R/ERSin.R")
source("R/SRSin.R")
source("R/GRSin.R")

# Define the list of species
taxa <- list("Vitis arizonica")  # Add more species as needed

# Create an empty dataframe to store results
results_df <- data.frame()

# Iterate over each species in the taxa list
for (i in seq_along(taxa)) {
  taxon <- taxa[[i]]

  # Filter for the species of interest
  filtered_occurrence_Data <- occurrence_Data |>
    dplyr::filter(species == taxon & type == "G")

  # Convert filtered occurrence data to SpatVector with CRS
  d1 <- terra::vect(filtered_occurrence_Data, geom=c("longitude", "latitude"), crs=crs_wgs84)
  d1 <- terra::makeValid(d1)

  # Generate buffer
  bufferDistM <- 50000
  gBuffer <- generateGBuffers(taxon = taxon,
                              occurrence_Data = filtered_occurrence_Data,
                              bufferDistM = bufferDistM)

  # Generate objects for each function
  srsex <- SRSex(taxon = taxon, occurrence_Data = occurrence_Data)
  grsex <- GRSex(taxon = taxon, sdm = sdm, gBuffer = gBuffer)
  ersex <- ERSex(taxon = taxon, sdm = sdm, occurrence_Data = occurrence_Data, gBuffer = gBuffer, ecoregions = ecoregions_Data, idColumn = "ECO_ID_U")

  # Generate final object for FCSex function
  fcsex <- FCSex(taxon = taxon, srsex = srsex, grsex = grsex, ersex = ersex)

  # Run the ERSin function
  ersin <- ERSin(taxon = taxon, sdm = sdm, occurrence_Data = filtered_occurrence_Data, protected_Areas = protected_Areas, ecoregions = ecoregions_Data, idColumn = "ECO_ID_U")

  # Store results in the dataframe
  results_df <- rbind(results_df, data.frame(taxon = taxon, fcsex = fcsex, ersin = ersin))

  # Print results
  print(paste("Taxon:", taxon))
  print(fcsex)
  print(ersin)
}



## SG: results differ from results in Vitis data folder
## taxon area of model is same

## G buffer area in model results differ
## scores differ

## example SG run results, print(fcsex)
# Taxon             SRS.exsitu    GRS.exsitu   ERS.exsitu      FCS.exsitu
# Vitis arizonica   11.10458       87.5        65.86035        54.82164
# FCS.existu.score    FCS existu score
# NA                  MP

## fcsex results from Vitis drive:
# ID	              SRS	         GRS	         ERS	    FCS	          FCS_Score
# Vitis arizonica	  5.951919349	 35.24125801	 68.75	  36.64772579	  HP



## noted that DC mentioned srsex results will differ with spatialData.gpkg input,
# but others should match results from shared drive
# (which SG results do not match so there is something to fix here)

print(head(filtered_occurrence_Data))
print(gBuffer)
print(srsex)
print(grsex)
print(ersex)
print(fcsex)
print(ersin)















##################### PART III: Run with different data sources #########################
# gather 2 ecoregion files and test results



