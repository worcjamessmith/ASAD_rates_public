This is the repo for the paper titled: "International impact of large multi-centre surgical trials of arthroscopic subacromial decompression". It contains the aggregated data, analysis scripts and executable manuscript file.

# Manuscript
Execute the `Paper-ASAD-rates.Rmd` file to generate the manuscript. You can choose to knit the file to word, pdf or HTML. Note that some minor aesthetic formatting was done in word after knitting. Note that this will work even though not all aggregated data could be shared, as intermediate files are used to generate tables etc in the manuscript. 

# Data 
Aggregated data are available in `Data/Importable_data/` or equivalently `Data/Original_data`. For descriptions of the datasets, see the manuscript text.

Note that some data is not provided publicly because it contains many
cells with too few cases. This includes the Belgium patient characterisation and the incidence files from IQVIA. CPRD patient characteristics and OpenClaims data were modified so that any cells with counts of <5 were replaced with "<5". 

# Scripts 
`R/` contains scripts to process the aggregated data and return summary datasets to `Output/`. These are called by `Paper-ASAD-rates.Rmd`

# Dependency management
This repo uses renv for package management. Use `renv::restore()` to install the relevant packages and the correct versions. More information can be found [here](https://rstudio.github.io/renv/articles/renv.html).

