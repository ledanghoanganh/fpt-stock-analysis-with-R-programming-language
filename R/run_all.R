# Entry point: chạy toàn bộ phân tích và render hai tài liệu Word từ project root.

# Project file là dấu hiệu đơn giản nhất rằng working directory đang đúng.
if (!file.exists("FPT_Stock_TimeSeries.Rproj")) {
  stop("Hãy chạy R/run_all.R từ thư mục gốc của dự án.")
}
source("R/00_config.R")
require_packages(c(
  "forecast", "tseries", "FinTS", "rugarch", "scales",
  "openxlsx", "knitr", "rmarkdown"
))

# Ghi cả console output và message vào log để audit lần chạy cuối.
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
cat("Pipeline started: ", format(Sys.time()), "\n", sep = "")

# Thứ tự là dependency graph: mỗi script dùng output của script đứng trước.
scripts <- sprintf("R/%02d_%s.R", 1:6, c(
  "data_cleaning", "visualization", "stationarity_arima_ets",
  "garch_volatility", "model_comparison", "export_report_tables"
))
purrr::walk(scripts, function(script) {
  cat("\n=== Running", script, "===\n")
  sys.source(script, envir = new.env(parent = globalenv()))
})

# RStudio đi kèm Pandoc; fallback này hỗ trợ terminal Windows chưa có PATH.
if (!rmarkdown::pandoc_available()) {
  bundled_pandoc <- "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
  if (file.exists(file.path(bundled_pandoc, "pandoc.exe"))) {
    Sys.setenv(RSTUDIO_PANDOC = bundled_pandoc)
  }
}
if (!rmarkdown::pandoc_available()) stop("Không tìm thấy Pandoc để render Word.")

# Render từ source Rmd để Word luôn đồng bộ với CSV/hình của lần chạy này.
render_targets <- tribble(
  ~input, ~output,
  "report/report.Rmd", "report.docx",
  "presentation/khung_noi_dung_slide.Rmd", "khung_noi_dung_slide.docx"
)
purrr::pwalk(render_targets, function(input, output) {
  cat("\n=== Rendering", output, "===\n")
  rmarkdown::render(input, output_file = output,
                    knit_root_dir = normalizePath("."), quiet = TRUE)
})

cat("Pipeline completed: ", format(Sys.time()), "\n", sep = "")
