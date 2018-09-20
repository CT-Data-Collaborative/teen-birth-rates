# install XLConnect if it isn't already
if(!require(XLConnect)) install.packages("XLConnect")

library(XLConnect)

# converts numeric data encoded as a string to numeric values
# it sanitises/removes dirty characters viz., ","
# and replaces NA values to be 0 (per spec.)
sanitise_to_num <- function (vector) {
  vector <- gsub(",", "", vector)
  vector <- gsub("-", "0", vector)
  return(as.numeric(vector))
}

# retrieves the entire teen birth rate data sheet
worksheet <- readWorksheetFromFile("raw/RR2015.xlsx", "Table 13 Town Teen Birth Rates")

# constraints that delimit the location of required data within the worksheet
first_observation_index <- which(worksheet[, 1] == "GEOGRAPHIC AREA") + 1
last_observation_index  <- which(worksheet[, 1] == "NOTES:") - 2
all_observations <- first_observation_index:last_observation_index

# retrieve pertinent variables and "sanitise" them of dirty characters, if necessary
geoArea    <- worksheet[all_observations, 1]
birthCount <- sanitise_to_num(worksheet[all_observations, 2])
femalePop  <- sanitise_to_num(worksheet[all_observations, 3])
birthRate  <- sanitise_to_num(worksheet[all_observations, 4])

# combine related data as a dataframe
teen_birth_df <- data.frame(geoArea, birthCount, femalePop, birthRate)
colnames(teen_birth_df) <-
  c(
    "Geographic Area",
    "Births to 15-19 y/o mothers",
    "15-19 y/o Female Population",
    "Birth Rate Per 1000 Population"
  )

# write the data frame to a csv-file
write.table(
  teen_birth_df,
  file = file.path(getwd(), "data", "teen_birth_data_2011-2015.csv"),
  sep = ",",
  row.names = FALSE
)
