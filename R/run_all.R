# Run the complete reproducible analysis from the project root.

project_file <- "FPT_Stock_TimeSeries.Rproj"
if (!file.exists(project_file)) {
  stop("Run R/run_all.R from the project root containing ", project_file)
}

required_packages <- c(
  "tidyverse", "lubridate", "forecast", "tseries", "FinTS", "rugarch",
  "scales", "openxlsx", "knitr", "rmarkdown"
)
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop("Missing packages: ", paste(missing_packages, collapse = ", "))
}

dir.create("output", recursive = TRUE, showWarnings = FALSE)
log_path <- file.path("output", "pipeline_log.txt")
log_connection <- file(log_path, open = "wt", encoding = "UTF-8")
sink(log_connection, type = "output", split = TRUE)
sink(log_connection, type = "message")

on.exit({
  sink(type = "message")
  sink(type = "output")
  close(log_connection)
}, add = TRUE)

options(warn = 1)
cat("Pipeline started:", format(Sys.time()), "\n")

scripts <- c(
  "R/01_data_cleaning.R",
  "R/02_visualization.R",
  "R/03_stationarity_arima_ets.R",
  "R/04_garch_volatility.R",
  "R/05_model_comparison.R",
  "R/06_export_report_tables.R"
)

for (script in scripts) {
  cat("\n=== Running", script, "===\n")
  sys.source(script, envir = new.env(parent = globalenv()))
}

if (!rmarkdown::pandoc_available()) {
  rstudio_pandoc <- "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
  if (file.exists(file.path(rstudio_pandoc, "pandoc.exe"))) {
    Sys.setenv(RSTUDIO_PANDOC = rstudio_pandoc)
  }
}
if (!rmarkdown::pandoc_available()) {
  stop("Pandoc was not found; install RStudio/Quarto or configure RSTUDIO_PANDOC")
}

cat("\n=== Rendering report/report.docx ===\n")
rmarkdown::render(
  "report/report.Rmd",
  output_file = "report.docx",
  knit_root_dir = normalizePath("."),
  quiet = TRUE
)

cat("Pipeline completed:", format(Sys.time()), "\n")
