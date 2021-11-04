# Geocoding the incidents file
library(here)
library(tidyverse)
library(censusxy)
library(crayon)

# Get data without geocode
gva_renamed <- read_rds(here("data", "incidents_nogeocode.rds"))

# get benchmark
bench <- cxy_benchmarks()
bench_name <- bench$benchmarkName[1]

# Our geocoding settings
cxy_geocode_current <- function(data){
    cxy_geocode(data, 
                street = "address",
                city = "city_county",
                state = "state",
                return = "geographies",
                vintage = "Current_Current",
                parallel = 10)
}

# Add census tracts using censusxy::
incidents_geo_raw <- gva_renamed %>% 
    cxy_geocode_current() %>% 
    rename_with(~paste0(., "_raw"))

# Remove "block of" from addresses & add 1 to street starting with alphabetic
incidents_geo_clean <- gva_renamed %>% 
    mutate(address = str_remove(address, "block of ")) %>% 
    mutate(address = case_when(
        str_starts(address, "^\\p{Alphabetic}") ~ paste0("1 ", address),
        TRUE ~ address)) %>% 
    cxy_geocode_current()

# Test
# We want to test if (a) removing "block of" or (b) adding 1 to streets would 
# change the existing address estimation. It is fine if we add information.
cat(green("Running test to see if these modifications to address do not modify existing records."))

both <- incidents_geo_raw %>%
    bind_cols(incidents_geo_clean) %>%
    as_tibble() %>%
    select(starts_with("cxy_block_id"))

did_modify <- both %>% drop_na() %>%
    mutate(modified = cxy_block_id != cxy_block_id) %>%
    summarise(sum(modified)) %>% 
    as.logical()

# Show error message for the test
if(did_modify) cat(red("Modifications detected---check the combined dataset."))
if(!did_modify) cat(green("No modification detected---we are good to go"))

# Save incidents data
write_rds(incidents_geo_clean, here("data", "incidents.rds"))
