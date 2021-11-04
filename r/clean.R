# Cleaning
library(here)
library(tidyverse)

# read raw data
gva1 <- read_csv(here("data", "2013-02-11 - 2017-03-18.csv"),
                 col_types = list("Incident Date" = col_datetime(format = "%B %d, %Y")))
gva2 <- read_csv(here("data", "2017-03-12 - 2021-10-27.csv"),
                 col_types = list("Incident Date" = col_datetime(format = "%B %d, %Y")))

# combine two csv files
gva <- gva1 %>% bind_rows(gva2) %>% 
    arrange(`Incident Date`, `Incident ID`)

# Get unduplicated data (some incidents overlap because of the download procedure)
gva_unique <- gva %>% distinct()

# Rename columns
gva_renamed <- gva_unique %>% 
    rename(id = "Incident ID",
           date = "Incident Date",
           state = "State",
           city_county = "City Or County",
           address = "Address",
           killed = "# Killed",
           injured = "# Injured")

# Clean missing values in address: "N/A" to NA_character_
gva_renamed <- gva_renamed %>%
    mutate(address = str_replace(address, "N/A", NA_character_))

# Save the incidents data without geocode
write_rds(gva_renamed, here("data", "incidents_nogeocode.rds"))

# Check if we already have the geocoded rds file
geocoded_exists <- file.exists(here("data", "incidents.rds"))

# Run the geocode R file (takes time)
if(!geocoded_exists) source(here("r", "geocode.R"))
cat(green("The geocoded file already exists in the data folder.\n
          Not running the cleaning script."))


# Save the address file for python output
incidents %>%
    transmute(complete_address = paste(address, city_county, state, sep = ", ")) %>%
    write_csv(here("data", "address.csv"))

# Run python

# create a tibble from the output JSON file 
mgeo_out <- fromJSON(here("output_addresses_geocoded.json")) %>% 
    as_tibble()
