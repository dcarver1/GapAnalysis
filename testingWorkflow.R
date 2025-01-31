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

# Print or log results for validation
print(paste("Taxon:", taxon))
print(fcsex)
print(ersin)

   }




## test purrr implementation

# prep species list
speciesList <- list(CucurbitaData$species[1])  # Using the first species as an example
sdms <- list(terra::unwrap(CucurbitaRasts)[[1]])



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



# prep for the function
pacman::p_load(dplyr, terra, sf)


# Load all the vitis data
# Occurrence Data
# Distribution Model
# Counts Data
# All Model Data
# Variable Selection Data


# Load occurrence data
spatial_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/spatialData.gpkg"
occurrence_Data <- sf::st_read(spatial_data_path)

# Load distribution model
sdm_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/results/prj_threshold.tif"
sdm <- terra::rast(sdm_path)

# Load counts data
counts_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/counts.csv"
counts_Data <- read.csv(counts_data_path)

# Load all model data
allmodel_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/allmodelData.csv"
allmodel_Data <- read.csv(allmodel_data_path)

# Load variable selection data
variable_selection_data_path <- "C:/Users/sgora/Desktop/Agrobiodiversity/Vitis/Data/data/v.arizonica_run20241212_1k/run20241212_1k/occurances/variableSelectionData.csv"
variableSelection_Data <- readr::read_csv(variable_selection_data_path)
# error in read in

# no data on protected areas land rasters and ecoregions?


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


# Set buffer distance (in meters)
bufferDistM <- 50000  # 50 km
# Create buffers around the occurrence points
gBuffer <- sf::st_buffer(occurrence_Data, dist = bufferDistM)





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
ersex <- ERSex(taxon = taxon,
               sdm = sdm,
               occurrence_Data = occurrence_Data,
               gBuffer = gBuffer,
               ecoregions = NULL,  # No ecoregions file?
               idColumn = NULL)    # No ecoregion ID column bc no ecoregion file?














##################### PART III: Run with different data sources #########################
# gather 2 ecoregion files and test results
# column: ECO_ID_U


