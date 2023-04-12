#Libraries
library(plm)
library(rgdal)
library(sf)
library(sp)
library(ggplot2)
library(dplyr)
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


#Load the shapefile from the pre-made .shp document
constJson <- readOGR("json_shapefile.shp")

#Turning UTM to lat long

coordinates_sp_no2_2010 <- SpatialPointsDataFrame(coords = no2_2010[, c("easting", "northing")], data = no2_2010)
proj4string(coordinates_sp_no2_2010) <- CRS("+init=epsg:27700")
coordinates_sp_no2_2010_coor <- spTransform(coordinates_sp_no2_2010, CRS("+init=epsg:4326"))
coordinates_sp_no2_2010_coor

proj4string(coordinates_sp_no2_2010_coor) <- CRS("+proj=longlat +datum=WGS84")
constJson <- spTransform(constJson, CRS(proj4string(coordinates_sp_no2_2010_coor)))
no2_2010 <- as.data.frame(coordinates_sp_no2_2010_coor)
colnames(no2_2010) <- c("grid", "easting", "northing", "no2", "lon", "lat")
no2_2010 <- no2_2010[, -c(1,2,3)]

coordinates(no2_2010) <- c("lon", "lat")
proj4string(no2_2010) <- CRS("+proj=longlat +datum=WGS84")
constJson <- spTransform(constJson, CRS(proj4string(no2_2010)))

#Match grids and constituencies
matched_no2_2010 <- over(no2_2010, constJson)

#Putting the data frame together
matched_no2_2010$no2 <- no2_2010$no2
matched_no2_2010$obs_lat <- no2_2010$lat
matched_no2_2010$obs_lon <- no2_2010$lon
matched_no2_2010_clean <- na.omit(matched_no2_2010)
unique(matched_no2_2010_clean$pcn20nm)


#AVERAGES
matched_no2_2010_clean$no2 <- as.numeric(matched_no2_2010_clean$no2)
avg_no2_2010 <- matched_no2_2010_clean %>% 
  group_by(pcn20cd) %>% 
  summarize(avg_value = mean(no2))
write.csv(avg_no2_2010, file = "avg_no2_2010.csv", row.names = FALSE)

