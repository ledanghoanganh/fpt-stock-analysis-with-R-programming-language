library(readr)
library(dplyr)

# Read raw data
fpt <- read.csv("~/Downloads/FPT_stock_data.csv")

# Check structure
str(fpt)

# Convert date column
fpt$time <- as.Date(fpt$time)

# Check missing values
missing_values <- colSums(is.na(fpt))

# Remove duplicates
fpt_clean <- fpt %>%
  distinct()

# Create folders
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# Save cleaned data
write_csv(
  fpt_clean,
  "data/processed/fpt_clean.csv"
)

# Save missing value report
write_csv(
  data.frame(
    Variable = names(missing_values),
    Missing = missing_values
  ),
  "output/tables/missing_values.csv"
)
# Save missing value report
write_csv(
  data.frame(
    Variable = names(missing_values),
    Missing = missing_values
  ),
  "output/tables/missing_values.csv"
)