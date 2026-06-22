# CẤU HÌNH DÙNG CHUNG
# File này định nghĩa package, đường dẫn và ba helper được mọi module sử dụng.
# Không đặt logic phân tích tại đây để tránh side effect khi source nhiều lần.

# Nạp tidyverse cho thao tác bảng/đồ thị và lubridate cho ngày tháng.
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
})

# Gom đường dẫn vào một nơi để tránh mỗi script tự ghi chuỗi khác nhau.
RAW_DATA_PATH <- "data/raw/FPT_stock_data.csv"
CLEAN_DATA_PATH <- "data/processed/fpt_clean.csv"
FIGURE_DIR <- "output/figures"
TABLE_DIR <- "output/tables"
MODEL_DIR <- "output/models"

# Tạo sẵn thư mục output; recursive = TRUE cũng tạo thư mục cha nếu còn thiếu.
purrr::walk(
  c(FIGURE_DIR, TABLE_DIR, MODEL_DIR),
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
)

#' Kiểm tra các package bắt buộc trước khi chạy module
#'
#' @param packages Character vector chứa tên package cần có.
#' @return Trả về `TRUE` vô hình khi đủ package; dừng bằng `stop()` nếu thiếu.
#' @details Hàm chỉ kiểm tra namespace, không tự cài package trong lúc chạy.
require_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Thiếu package: ", paste(missing, collapse = ", "))
  invisible(TRUE)
}

#' Xác nhận bảng đầu vào có đủ các cột bắt buộc
#'
#' @param data Data frame hoặc tibble cần kiểm tra.
#' @param required Character vector chứa tên cột bắt buộc.
#' @param data_name Tên dùng trong thông báo lỗi.
#' @return Trả về `TRUE` vô hình; dừng nếu thiếu ít nhất một cột.
assert_columns <- function(data, required, data_name = deparse(substitute(data))) {
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop(data_name, " thiếu cột: ", paste(missing, collapse = ", "))
  }
  invisible(TRUE)
}

#' Ghi một bảng vào thư mục output/tables
#'
#' @param data Data frame hoặc tibble cần ghi.
#' @param filename Tên file CSV, không gồm đường dẫn thư mục.
#' @return Kết quả vô hình từ `readr::write_csv()`.
#' @details Side effect: ghi đè file cùng tên và biểu diễn missing value bằng `NA`.
write_project_csv <- function(data, filename) {
  readr::write_csv(data, file.path(TABLE_DIR, filename), na = "NA")
}
