#### #################################################################### ####
####  Create shapefiles of fossil-fuel production                         ####
###  --------------------------------------------------------------------  ###
###  --------------------------------------------------------------------  ###
###  Author: Rens Chazottes                                                ###
###  Date: 03/12/2024                                                      ###
##############################################################################

###########################################################################
# 0. Set up the working environment ---------------------------------------
###########################################################################
# 0.1. Remove existing files ----
rm(list = ls())
# 0.2. Load libraries ----
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, haven, panelr, data.table, readxl, terra, sf)
# 0.3. Upload data ----
### 0.3.1 Coal ----
df_coal_eeb <- read_excel("01_raw_data/EU-coal-mine-database-EEB-with-metadata.xlsx", sheet = 2)
df_coal_mines <- read_excel("01_raw_data/02_globalenergytracker/Global-Coal-Mine-Tracker-April-2024.xlsx", sheet = 2)
df_elec_coal <- read_csv("01_raw_data/01_worlddata/share-electricity-coal.csv")
### 0.3.2 Administrative boundaries ----
df_country <- st_read("01_raw_data/03_administrative_units/CNTR_RG_20M_2024_3035.geojson")
### 0.3.3 Oil and gas ----
df_oil_gas <- read_excel("01_raw_data/02_globalenergytracker/Global-Oil-and-Gas-Extraction-Tracker-March-2024.xlsx")
###########################################################################
# 1. Transform to shapefiles ---------------------------------------
###########################################################################
# 1.1 Coal ----
### 1.1.1 Coal power plants ----
df_coal_geom <- st_as_sf(df_coal_eeb%>%filter(!is.na(Longitude)&!is.na(Latitude)), coords = c("Longitude", "Latitude"), crs = 4326)
st_write(df_coal_geom%>%group_by(`EEB Mine ID`)%>%filter(`Data reported year` == max(`Data reported year`, na.rm=T))%>%ungroup(), "03_new_data/01_shp/coal_geom.geojson", append=FALSE)
### 1.1.2 Coal mines ----
df_coal_mines_geom <- st_as_sf(df_coal_mines%>%filter(!is.na(Longitude)&!is.na(Latitude)), coords = c("Longitude", "Latitude"), crs = 4326)
st_write(df_coal_mines_geom%>%filter(Status == "Operating"), "03_new_data/01_shp/coal_mines_geom.geojson", append=FALSE)
### 1.1.3 Coal production by country
df_elec_coal_geom <- merge(df_country, df_elec_coal%>%rename(ISO3_CODE=Code), by="ISO3_CODE")
st_write(df_elec_coal_geom%>%group_by(ISO3_CODE)%>%filter(Year==max(Year, na.rm=T)), "03_new_data/01_shp/coal_elec_geom.geojson", append=FALSE)
# 1.2 Oil and gas production ----
df_oil_gas_geom <- st_as_sf(df_oil_gas%>%filter(!is.na(Longitude)&!is.na(Latitude)), coords = c("Longitude", "Latitude"), crs = 4326)
if (file.exists("03_new_data/01_shp/oil_gas_geom.geojson")) file.remove("03_new_data/01_shp/oil_gas_geom.geojson")
st_write(df_oil_gas_geom%>%filter(Status == "operating"), "03_new_data/01_shp/oil_gas_geom.geojson", append=FALSE)


