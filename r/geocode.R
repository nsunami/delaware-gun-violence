# Geocoding the incidents file
library(here)
library(tidyverse)
# ggmap 
if(!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("dkahle/ggmap")
library(ggmap) 
library(tigris)
library(tictoc) # measure time

# Get data without geocode
incidents_raw <- read_rds(here("data", "incidents_nogeocode.rds"))

# Google Map API to clean the address
# Register with google 
register_google(key = Sys.getenv("GOOGLE_GEO_KEY"))

# Create a string to feed to Google Map API
incidents_raw <- incidents_raw %>%
    mutate(full_address = paste(address, city_county, state, sep = ", "))

# Query Google Map API  zzzzzzzz (takes time) zzzzzzzz
tic()
incidents_raw <- incidents_raw %>%
    mutate(lon_lat = geocode(full_address)) %>% 
        unnest(lon_lat) # unnest since the data returned is df
cat("Google Map API Time:")
toc()

# Add census blocks via tigris:: zzzzzzzz (takes time) zzzzzzzz
tic()
incidents_clean <- incidents_raw %>% 
    mutate(census_block = map2_chr(lon, lat, 
                               .f = ~call_geolocator_latlon(lon = .x, lat = .y)))
cat("Google Map API Time:")
toc()

# Save incidents data
write_rds(incidents_clean, here("data", "incidents.rds"))
write_csv(incidents_clean, here("data", "incidents.csv"))
