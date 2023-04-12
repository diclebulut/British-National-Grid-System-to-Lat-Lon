#Libraries
install.packages('sp')
install.packages('rgdal')
install.packages('sf')
install.packages('dplyr')
install.packages('plm')
install.packages('ggplot2')
install.packages('geojsonio')
library(sp)
library(rgdal)
library(sf)
library(dplyr)
library(plm)
library(ggplot2)
library(geojsonio)
#Libraries end

#NO2 2010
no2_2010 <- read.csv("mapno22010.csv")

#removing unnecessary descriptive rows
no2_2010 <- no2_2010[-c(1, 2, 3, 4, 5), ]

#some grids are in the sea and doesn't have observations attached to them
#we delete them
no2_2010 <- no2_2010[no2_2010$X.2 != "MISSING", ]

#rename columns
colnames(no2_2010) <- c("grid", "easting", "northing", "no2")

#transforming variables to numeric, not compulsory if data is already numeric
no2_2010$easting <- as.numeric(no2_2010$easting)
no2_2010$northing<- as.numeric(no2_2010$northing)


#Turning UTM to lat long
coordinates_sp_no2_2010 <- SpatialPointsDataFrame(coords = no2_2010[, c("easting", "northing")], data = no2_2010)
proj4string(coordinates_sp_no2_2010) <- CRS("+init=epsg:27700")
coordinates_sp_no2_2010_coor <- spTransform(coordinates_sp_no2_2010, CRS("+init=epsg:4326"))
coordinates_sp_no2_2010_coor

proj4string(coordinates_sp_no2_2010_coor) <- CRS("+proj=longlat +datum=WGS84")
no2_2010 <- as.data.frame(coordinates_sp_no2_2010_coor)
colnames(no2_2010) <- c("grid", "easting", "northing", "no2", "lon", "lat")
no2_2010 <- no2_2010[, -c(1,2,3)]





