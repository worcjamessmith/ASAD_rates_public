# Open claims characterisation 

# Reads and cleans the patient characterisation information from IQVIA
# OpenClaims data

require(tidyverse)
require(readxl)

# Inputs -----
# input fuile
file_path <- "./Data/Importable data/CSAW_Characterization_OpenClaims.xls"

# output folder
output_path <- "./Output/"

output_file_name <- "Openclaims_patient_characteristics.csv"

# Import data -----
sheets <- excel_sheets(file_path)

# there are warnings because I had to insert "<5" in some cells and this makes
# it a mix of character and numeric

results <- suppressWarnings(lapply(sheets, function (x){
  read_xls(path = file_path, sheet = x)
}))

names(results) <- sheets

# Clean relevant data -----
# Sex (% female)
sex <- results$`Demographics Gender`
sex <- sex %>% 
  filter(`Covariate name`== "gender = FEMALE") %>% 
  select(`Cohort ID`, `Cohort name`, Percent) %>% 
  rename(`Gender (% female)` = Percent)

# Age (mean and SD)
age <- results$`Demographics Age`
age <- age %>% 
  mutate(`Age (SD)` = paste0(format(round(Avg,2), nsmall = 2),
                             " (", 
                             format(round(StdDev,2), nsmall = 2),
                             ")")) %>% 
  select(`Cohort ID`, `Cohort name`, `Age (SD)`)

# Charlson index
# for the charlson index, I used the mean because the median and IQRs are the
# same for all of the years. However, the mean might not be a good measure as
# the distribution is right skewed
charlson <- results$`Charlson Index` %>% 
  mutate(`Charlson index (SD)` = paste0(format(round(Avg,2), nsmall = 2),
                                        " (", 
                                        format(round(StdDev,2), nsmall = 2),
                                        ")")) %>% 
  select(`Cohort ID`, `Cohort name`, `Charlson index (SD)`)

# Number of medicines in the previous month
# note that I am assuming distinct ingredient count represents this
n_meds_month <- results$`Distinct Ingredient Count Short`
n_meds_month <- n_meds_month %>% 
  mutate(`Medicines previous month (IQR)` = paste0(Median,
                                                   " (",  P25, "-", 
                                                   P75, ")")) %>% 
  select(`Cohort ID`, `Cohort name`, `Medicines previous month (IQR)`)

# Output table ----- 
table <- left_join(age, sex) %>% 
  left_join(charlson) %>% 
  left_join(n_meds_month)

table$Year <- str_sub(table$`Cohort name`, -4, -1)
table$`Gender (% female)` <- format(round(table$`Gender (% female)`,2), 
                                    nsmall = 2)

table <- table %>% 
  select(Year, everything(), -`Cohort ID`, -`Cohort name`)

write_csv(table, paste0(output_path, output_file_name))

rm(age, charlson, n_meds_month, results, sex, table, file_path, 
   output_file_name, output_path, sheets)






