
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
})

RAW_DATA_PATH <- "data/raw/FPT_stock_data.csv"
CLEAN_DATA_PATH <- "data/processed/fpt_clean.csv"
FIGURE_DIR <- "output/figures"
TABLE_DIR <- "output/tables"
MODEL_DIR <- "output/models"

purrr::walk(
  c(FIGURE_DIR, TABLE_DIR, MODEL_DIR),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
)

require_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Thiếu package: ", paste(missing, collapse = ", "))
  invisible(TRUE)
}

assert_columns <- function(data, required, data_name = deparse(substitute(data))) {
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop(data_name, " thiếu cột: ", paste(missing, collapse = ", "))
  }
  invisible(TRUE)
}

write_project_csv <- function(data, filename) {
  readr::write_csv(data, file.path(TABLE_DIR, filename), na = "NA")
}
