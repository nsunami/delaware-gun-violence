# Cleaning
library(here)
library(tidyverse)

# read raw data
gva1 <- read_csv(here("data", "2013-02-11 - 2017-03-18.csv"),
                 col_types = list("Incident Date" = col_datetime(format = "%B %d, %Y")))
gva2 <- read_csv(here("data", "2017-03-12 - 2021-10-27.csv"),
                 col_types = list("Incident Date" = col_datetime(format = "%B %d, %Y")))

# combine two csvs
gva <- gva1 %>% bind_rows(gva2) %>% 
    arrange(`Incident Date`, `Incident ID`)

# Get unduplicated data
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
