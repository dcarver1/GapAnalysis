################## SG Gap R run
################## 01.18.2025, 1.24.2025


## install Gap R and run
## load variables and functions <<
## run until FSCsMean function
## then run example data from the repo


##Load package
library(raster)
#library(GapAnalysis)


# temp fix --- source the ersex,grsex,and gbuffer function from the library folder
# rather then the gapanalysis:: call. this  has a terra implimentation on the buffer process
# so it works
# adjust this path to where ever these files are realtive to your current wd()
source("R/ERSex.R")
source("R/GRSex.R")
source("R/Gbuffer.R")
source("R/FCSex.R")



##Obtaining occurrences from example
data(CucurbitaData)

##Obtaining species names from the data
speciesList <- unique(CucurbitaData$species)

##Obtaining raster_list
data(CucurbitaRasters)
CucurbitaRasters <- raster::unstack(CucurbitaRasters)

##Obtaining protected areas raster
data(ProtectedAreas)

##Obtaining ecoregions shapefile
data(ecoExample)

#Running all three ex situ gap analysis steps using FCSex function
FCSex_df <- FCSex( )

SRSex_df <- SRSex(taxon =

#Running all three in situ gap analysis steps using FCSin function
FCSin_df <- FCSin(Species_list=speciesList,
                  Occurrence_data=CucurbitaData,
                  Raster_list=CucurbitaRasters,
                  Ecoregions_shp=ecoregions,
                  Pro_areas=ProtectedAreas)

## Combine gap analysis metrics
FCSc_mean_df <- FCSc_mean(FCSex_df = FCSex_df,FCSin_df = FCSin_df)

##Running Conservation indicator across taxa
indicator_df  <- indicator(FCSc_mean_df)

## Generate summary HTML file with all result
GetDatasets()
summaryHTML_file <- SummaryHTML(Species_list=speciesList,
                                Occurrence_data = CucurbitaData,
                                Raster_list=CucurbitaRasters,
                                Buffer_distance=50000,
                                Ecoregions_shp=ecoregions,
                                Pro_areas=ProtectedAreas,
                                Output_Folder=".",
                                writeRasters=FALSE)



#################### Usage with different buffer distances for ex situ gap analysis ###############
#Buffer distances for 5, 10, and 20 km respectively

buffer_distances <- c(5000,10000,20000)

SRSex_df <- SRSex(Species_list = speciesList,
                  Occurrence_data = CucurbitaData)

FCSex_df_list <- list()


#Running all three ex situ gap analysis steps using FCSex function

#Choose if gap maps are calculated for ex situ gap analysis using diferent buffer size
Gap_Map=FALSE

for(i in 1:length(speciesList)){

  FCSex_df_list[[i]] <- FCSex(Species_list=speciesList[i],
                              Occurrence_data=CucurbitaData,
                              Raster_list=CucurbitaRasters[i],
                              Buffer_distance=buffer_distances[i],
                              Ecoregions_shp=ecoregions,
                              Gap_Map=Gap_Map)



};rm(i)

#Returning FCSex object
if(Gap_Map==TRUE){
  FCSex_df <- list(FCSex=do.call(rbind,lapply(FCSex_df_list, `[[`, 1)),
                   GRSex_maps=do.call(c,lapply(FCSex_df_list, `[[`, 2)),
                   ERSex_maps=do.call(c,lapply(FCSex_df_list, `[[`, 3))
  )
} else {
  FCSex_df <- do.call(rbind,FCSex_df_list)
}


#Running all three in situ gap analysis steps using FCSin function

FCSin_df <- FCSin(Species_list=speciesList,
                  Occurrence_data=CucurbitaData,
                  Raster_list=CucurbitaRasters,
                  Ecoregions_shp=ecoregions,
                  Pro_areas=ProtectedAreas,
                  Gap_Map = NULL)


## Combine gap analysis metrics
FCSc_mean_df <- FCSc_mean(FCSex_df = FCSex_df,FCSin_df = FCSin_df)


##Running Conservation indicator across taxa
indicator_df  <- indicator(FCSc_mean_df)




















