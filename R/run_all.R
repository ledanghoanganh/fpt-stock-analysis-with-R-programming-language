
if (!file.exists("FPT_Stock_TimeSeries.Rproj")) {
  stop("Hãy chạy R/run_all.R từ thư mục gốc của dự án.")
}
source("R/00_config.R")
require_packages(c(
  "forecast", "tseries", "FinTS", "rugarch", "scales",
  "openxlsx", "knitr", "rmarkdown"
))

log_path <- file.path("output", "pipeline_log.txt")
log_lines <- character()
log_event <- function(...) {
  line <- paste0(...)
  log_lines <<- c(log_lines, line)
  cat(line, "\n", sep = "")
}
on.exit(writeLines(log_lines, log_path, useBytes = TRUE), add = TRUE)
options(warn = 1)
log_event("Pipeline started: ", format(Sys.time()))

scripts <- sprintf("R/%02d_%s.R", 1:6, c(
  "data_cleaning", "visualization", "stationarity_arima_ets",
  "garch_volatility", "model_comparison", "export_report_tables"
))
purrr::walk(scripts, function(script) {
  log_event("Running: ", script)
  sys.source(script, envir = new.env(parent = globalenv()))
})

if (!rmarkdown::pandoc_available()) {
  bundled_pandoc <- "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
  if (file.exists(file.path(bundled_pandoc, "pandoc.exe"))) {
    Sys.setenv(RSTUDIO_PANDOC = bundled_pandoc)
  }
}
if (!rmarkdown::pandoc_available()) stop("Không tìm thấy Pandoc để render Word.")

render_targets <- tribble(
  ~input, ~output,
  "report/report.Rmd", "report.docx",
  "presentation/khung_noi_dung_slide.Rmd", "khung_noi_dung_slide.docx"
)
purrr::pwalk(render_targets, function(input, output) {
  log_event("Rendering: ", output)
  rmarkdown::render(input, output_file = output,
                    knit_root_dir = normalizePath("."), quiet = TRUE)
})

log_event("Pipeline completed: ", format(Sys.time()))
writeLines(log_lines, log_path, useBytes = TRUE)
