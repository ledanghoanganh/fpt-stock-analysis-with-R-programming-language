# Cấu hình dùng chung: mọi script đều source file này trước khi xử lý.

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

# Dừng sớm và báo đúng package thiếu thay vì lỗi mơ hồ ở giữa pipeline.
require_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Thiếu package: ", paste(missing, collapse = ", "))
  invisible(TRUE)
}

# Kiểm tra schema cho mọi bảng đầu vào.
assert_columns <- function(data, required, data_name = deparse(substitute(data))) {
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop(data_name, " thiếu cột: ", paste(missing, collapse = ", "))
  }
  invisible(TRUE)
}

# Ghi CSV theo cùng một chuẩn NA trong toàn dự án.
write_project_csv <- function(data, filename) {
  readr::write_csv(data, file.path(TABLE_DIR, filename), na = "NA")
}
