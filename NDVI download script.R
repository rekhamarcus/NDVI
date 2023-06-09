library('dplyr')
library('sf')             
library('MODIStsp') #for downloading NDVI rasters
library('sp')
library('rgdal')
library('rgeos')
library('spData')
library("tidyr")
library('raster')
library("mgcv")    #for wrangling data using gam
library('ggplot2') #for visualizing data

#import the shapefiles for the region to be observed
tweeds.spatial <- read_sf(dsn = 'Data/Tweeds_BGC_Zone/tepps_bec_zone.shp', layer = 'tepps_bec_zone') %>%
  st_transform(crs = '+proj=longlat')
bbox <- st_bbox(tweeds.spatial)

# download NDVI
MODIStsp(gui = FALSE, 
         out_folder = 'Data/NDVI', 
         selprod = 'Vegetation Indexes_16Days_250m (M*D13Q1)', 
         prod_version = '061', 
         bandsel = 'NDVI', 
         sensor = 'Terra', 
         user = 'USERNAME', 
         password = 'PASSWORD', #replace with user and password for earth geo  
         start_date = '2000.01.01', 
         end_date = '2023.05.04', 
         spatmeth = 'bbox',
         bbox = bbox, 
         out_projsel = 'User Defined', 
         output_proj = '+proj=longlat', 
         resampling = 'bilinear', 
         delete_hdf = TRUE, 
         scale_val = TRUE, 
         ts_format = 'R RasterStack', 
         out_format = 'GTiff', 
         n_retries = 10, 
         verbose = TRUE,
         parallel = TRUE) 


# check rasters ----
if(FALSE) {
  library('tweeds.raster') # to import and save rasters
  load('Data/NDVI/tweeds.raster')
  raster_ts %>%
    mask(map_boundary) %>%
    crop(map_boundary) %>%
    plot()
}

#create an object to save the rasters
rasters <-
  list.files(path = 'Data/NDVI/VI_16Days_250m_v61/NDVI/',
             pattern = '.tif', full.names = TRUE) %>%
  stack()


# save NDVI data as an rds file of a tibble (save as a data frame)
rasters %>%
  as.data.frame(xy = TRUE) %>%
  pivot_longer(-c(x, y)) %>%
  transmute(long = x,
            lat = y,
            date = substr(name, start = nchar('MOD13Q1_NDVI_x'), stop = nchar(name)) %>%
              as.Date(format = '%Y_%j'),
            ndvi = value) %>%
  saveRDS('Data/NDVI/tweeds.raster/tweeds.raster.rds')




