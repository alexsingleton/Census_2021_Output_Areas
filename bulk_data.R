library(rvest) # load the rvest package
library(vroom)
library(stringr)
library(tidyverse)
library(magrittr)
library(arrow)

# Read the HTML page
html_page <- read_html("https://www.nomisweb.co.uk/sources/census_2021_bulk")

# Get census table zip file names
zip_urls <- html_page %>% 
            html_nodes("a[href$='.zip']") %>% 
            html_attr("href")

# Make zip file names into a full URL
zip_urls <- paste0("https://www.nomisweb.co.uk",zip_urls)




# Create an empty tibble with the following column names

meta_data_table <- tibble(
  Table_Name = character(),
  Variable_Name = character(),
  Type = character(),
  new_names = character(),
  Table_ID = character()
)


# census2021-ts010.zip", - OA / other csv are blank?

no_oa_tables <- c("https://www.nomisweb.co.uk/output/census/2021/census2021-ts007.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts009.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts010.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts012.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts013.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts071.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts072.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts073.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts074.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts022.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts024.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts028.zip",
"https://www.nomisweb.co.uk/output/census/2021/census2021-ts031.zip")

# Create output directories for the census tables

dir.create("./output_data/csv",recursive = TRUE)
dir.create("./output_data/parquet",recursive = TRUE)

zip_urls <-  result <- setdiff(zip_urls, no_oa_tables)  # Remove the tables without OA

for (url in zip_urls){

dir.create("./tmp",recursive = TRUE)#create a temporary directory for unzipping
f <- curl::curl_download(url, tempfile(fileext = ".zip")) # Download the specified zip file
unzip(f,  exdir="./tmp") # Unzip
t_tab_loc <- list.files("./tmp", pattern=".*-oa.csv") # Extract the OA csv location

t_name <- unlist(str_split(t_tab_loc,"-"))[2] # Extract the table name


assign(t_name,vroom(paste0("./tmp/",t_tab_loc),show_col_types = FALSE) %>% 
         select(-date,-geography) %>% 
         column_to_rownames("geography code")) #Move OA code to row names
 
old_names <- colnames(get(t_name)) # Get the column names
new_names <- paste0(t_name, "_", sprintf("%04d",seq_along(old_names)))  # Create some new column names with zero padding

# Create a list of the new and old names, plus Table ID
N_list <- list(
  old_names = old_names,
  new_names = new_names,
  Table_ID = t_name
)

# Creates the meta data table
N_list <- as_tibble(N_list)


# Keep the metadata
meta_data_table %<>%
  bind_rows(N_list)

# Change the column names for the data frame
env <- environment() # Have to be explicit about the env, as  %>% uses a temp environment
get(t_name) %>%
  rename_at(vars(old_names), ~new_names) %>%
  rownames_to_column("OA") %>%
  assign(t_name,., envir = env) # add a reference to the environment

# Write csv and parquet to the output folders
write_parquet(get(t_name), paste0("./output_data/parquet/",t_name,".parquet"))
write_csv(get(t_name), paste0("./output_data/csv/",t_name,".csv"))

#Remove tmp objects
rm(N_list, old_names, new_names, t_name, t_tab_loc)

#Remove all downloaded files for this table
unlink("./tmp",recursive = TRUE)


}


# Format the lookup table

meta_data_table2 <- meta_data_table %>%
  mutate(Table_Name = str_split_fixed(old_names, ":", 2)[,1]) %>% # Table Name
  mutate(Type = str_replace_all((str_extract(old_names, "; measures: \\w+")), "; measures: ", "")) %>% # Variable Type
  mutate(Variable_Name = str_replace_all(old_names, ";.*", "")) %>%
  mutate(Variable_Name = str_replace_all(Variable_Name, paste0(Table_Name,": "), ""))


  