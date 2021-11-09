# delaware-gun-violence
Understanding gun violence incidents in Delaware using the Gun Violence Archive Data

## Folder Strucure

```
.
├── r                       # R scripts
│ ├── clean.R               # Merge and clean csv files, call geocode.r
│ ├── geocode.R             # Geocoding routine via Google Maps API
│ └── getCensus.R           # Pull Delaware census data from Census API
├── data                    # data files
│ ├── [csv files]           # Incidents data manually downloaded from https://www.gunviolencearchive.org/
│ └── incidents.rds         # Merged incidents data, output from clean.R
│ └── participants          # Participants data, manually downloaded from gunviolencearchive.org -- not able to link with the incidents
├── LICENSE
└── README.md
```
