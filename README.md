# Census 2021 Output Areas
This repository contains code to download and clean all Output Area level data for the England and Wales 2021 Census.

The R code:

* Downloads the bulk census data from [Nomis](https://www.nomisweb.co.uk/sources/census_2021_bulk)
* Imports the Output Area level data into R
* Creates new variable names based on the sequential ordering of the variables and the table identification code
* Creates a meta data lookup table between the new names and the old names
* Export the OA data as both CSV and Parquet files

The created CSV are available in the folder ["/output_data/csv"](/output_data/csv) and the parquet files in the folder ["/output_data/parquet"](/output_data/parquet)
