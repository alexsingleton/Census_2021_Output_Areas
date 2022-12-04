# Census 2021 Output Areas
This repository contains code to download and clean all Output Area level data for the England and Wales 2021 Census.

The R code:

* Download the bulk census data from [Nomis](https://www.nomisweb.co.uk/sources/census_2021_bulk)
* Import the Output Area level data into R
* Create new variable names based on the sequential ordering of the variables and the table identification code
* Create a metadata lookup table providing the link between the new names and the original names
* Export the OA data as both CSV and Parquet files

The created CSV are available in the folder ["/output_data/csv"](/output_data/csv) and the parquet files in the folder ["/output_data/parquet"](/output_data/parquet)
