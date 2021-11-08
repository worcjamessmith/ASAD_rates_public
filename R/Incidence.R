# Incidence 
  # This script reads in and cleans IQVIA Open Claims, AmbEMR and Belgium raw 
  # data from a set of zipped files. CPRD data is then added. Both CPRD and 
  # other data are imported here because they have very similar folder 
  # structures and the same file structure so are sensible to combine.

  # The script produces two csv files, one including stratified data and one 
  # including overall data (i.e. totals per year)

# Note that this script will not work in the public version as the
# IQVIA-incidence folder was removed as it contains many instances of cells with
# <5 counts

require(tidyverse)

# Inputs ----- 
# locations of input files:
  # includes both belgium and US data
iqvia_file_path <- "./Data/Importable data/IQVIA-incidence/"
  # UK data
cprd_file_path <- "./Data/Importable data/CPRD-incidence/"

# output folder
output_path <- "./Output/"

# stratified data
strata_output_file_name <- "Incidence_stratified.csv" 

# summary data
sum_output_file_name <- "Incidence_summary.csv"

# Create output folder
if(!dir.exists(output_path)) dir.create(output_path)

# Import iqvia data -----
iqvia_folders <-list.files(iqvia_file_path)

# stratified data
results_strat <- lapply(iqvia_folders, function (x) {
  read_csv(unz(paste0(iqvia_file_path, x), "ir_strata.csv"))
})
names(results_strat) <- iqvia_folders

# summary data
results_sum <- lapply(iqvia_folders, function (x) {
  read_csv(unz(paste0(iqvia_file_path, x), "ir_summary.csv"))
})
names(results_sum) <- iqvia_folders

# Import cprd data -----
cprd_folders <-list.files(cprd_file_path)

# stratified data
cprd_results_strat <- lapply(cprd_folders, function (x) {
  read_csv(unz(paste0(cprd_file_path, x), "ir_strata.csv"))
})
names(cprd_results_strat) <- cprd_folders

# summary data
cprd_results_sum <- lapply(cprd_folders, function (x) {
  read_csv(unz(paste0(cprd_file_path, x), "ir_summary.csv"))
})
names(cprd_results_sum) <- cprd_folders

# Clean data -----
# add year from folder name as a column to have an ID for data
iqvia_year <- parse_number(iqvia_folders) %>% 
  str_sub(2, 5) %>% 
  as.numeric()
results_strat <- mapply(cbind, results_strat, "year" = iqvia_year, SIMPLIFY = F)
results_sum <- mapply(cbind, results_sum, "year" = iqvia_year, SIMPLIFY = F)

# same for cprd (could use the same vector but just in case differences in years are
# introduced with later data versions, more robust to repeat)
cprd_year <- str_sub(cprd_folders, -8, -5) %>% 
  as.numeric()
cprd_results_strat <- mapply(cbind, cprd_results_strat, 
                             "year" = cprd_year, SIMPLIFY = F)
cprd_results_sum <- mapply(cbind, cprd_results_sum, 
                           "year" = cprd_year, SIMPLIFY = F)

# Combine and filter data ----
# stratified
results_strat <- bind_rows(results_strat) 
cprd_results_strat <- bind_rows(cprd_results_strat)
results_strat <- bind_rows(results_strat, cprd_results_strat)

# summary 
results_sum <- bind_rows(results_sum)
cprd_results_sum <- bind_rows(cprd_results_sum)
results_sum <- bind_rows(results_sum, cprd_results_sum)

# select only databases with data 
results_strat <- results_strat %>% 
  filter(db_id == "AMBEMR202005" | db_id == "BELG202006" | 
           db_id == "cdmgold202007" | db_id == "OPEN202005") %>% 
  arrange(db_id)

results_sum <- results_sum %>% 
  filter(db_id == "AMBEMR202005" | db_id == "BELG202006" | 
           db_id == "cdmgold202007" | db_id == "OPEN202005") %>% 
  arrange(db_id)

results_strat[
  results_strat$cases > 0 & results_strat$cases < 5, "cases"] <- "<5"

# Save -----
write_csv(results_strat, paste0(output_path, strata_output_file_name))
write_csv(results_sum, paste0(output_path, sum_output_file_name))

rm(cprd_results_strat, cprd_results_sum, results_strat, results_sum, 
   cprd_file_path, cprd_folders, cprd_year,iqvia_file_path, iqvia_folders, 
   iqvia_year, output_path, strata_output_file_name, sum_output_file_name)



