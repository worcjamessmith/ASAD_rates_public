# CPRD characterisation 

# Reads and cleans the patient characterisation information from CPRD. 

# Load packages 
require(tidyverse)
require(readxl)

# Inputs ----
# location of input files
file_path <- "./Data/Importable data/CPRD characterisation/"

# output folder
output_path <- "./Output/"

output_file_name <- "CPRD_patient_characteristics.csv"

# Create output folder
if(!dir.exists(output_path)) dir.create(output_path)

# Import data -----
file_list <- list.files(path = file_path,
                        pattern='*.xlsx')

results <- lapply(file_list, function (x){
  read_xlsx(path = paste0(file_path, x))
})

file_list <- str_sub(file_list, 1, -6)

names(results) <- file_list

# Clean relevant data -----
# socio-demographics, charlson index qnd short-term medicines use requested

# Sex (% female)
sex <- results$sex
sex <- sex %>% 
  filter(`Covariate name`== "gender = FEMALE") %>% 
  select(`Cohort ID`, `Cohort name`, Percent) %>% 
  rename(`Gender (% female)` = Percent)

# Age (mean and SD)
age <- results$age_continuous 
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
charlson <- results$charlsoncomorbidityindex %>% 
  mutate(`Charlson index (SD)` = paste0(format(round(Avg,2), nsmall = 2),
                             " (", 
                             format(round(StdDev,2), nsmall = 2),
                             ")")) %>% 
  select(`Cohort ID`, `Cohort name`, `Charlson index (SD)`)

# Number of medicines in the previous month
n_meds_month <- results$numberofmedicinespreviousmonth

n_meds_month <- n_meds_month %>% 
  mutate(`Medicines previous month (IQR)` = paste0(Median,
                                                          " (",  P25, "-", 
                                                          P75, ")")) %>% 
  select(`Cohort ID`, `Cohort name`, `Medicines previous month (IQR)`)

# Overall table -----
table <- left_join(age, sex) %>% 
  left_join(charlson) %>% 
  left_join(n_meds_month)

table$Year <- str_sub(table$`Cohort name`, -4, -1)
table$`Gender (% female)` <- format(round(table$`Gender (% female)`,2), 
                                    nsmall = 2)

table <- table %>% 
  select(Year, everything(), -`Cohort ID`, -`Cohort name`)

write_csv(table, paste0(output_path, output_file_name))

rm(age, charlson, n_meds_month, results, sex, table, file_list, file_path, 
   output_file_name, output_path)




