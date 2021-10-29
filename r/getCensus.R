# Get census data
Sys.getenv("CENSUS_API_KEY")
Sys.setenv(CENSUS_KEY="YOURKEYHERE")
variables_acs <- load_variables(2019, "acs5", cache = TRUE) # to store the variables in R studio 
pop <- get_acs(geography = "tract", 
              variables=c(popWhi="C02003_003",
                          popTot="C02003_001",
                          popBla="C02003_004",
                          popHis="B03001_003",
                          rented="B25003_003",
                          owned="B25003_002",
                          w_rented="B25003A_003",
                          w_owned="B25003A_002",
                          pop_owner="B25008_002",
                          pop_renter="B25008_003",
                          pov="B17020_002",
                          median_income="B06011_001",
                          age="B01002_001",
                          capita_income="B19301_001",
                          households="B11011_001",
                          assistance="B19057_002",
                          mobility="B07001_017",
                          ownership_occ="B25003I_002",
                          povB="B17020B_002",
                          povH="B17020I_002",
                          ss="B19055_002",
                          snap="B99221_002",
                          cash_snap="B19058_002"
              ),
state = "DE",   
year = 2019,output = "wide")
