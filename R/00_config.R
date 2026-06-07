# 00_config.R
# File cấu hình chung cho toàn project

library(tidyverse)
library(lubridate)

# Đường dẫn dữ liệu
RAW_DATA_PATH <- "data/raw/FPT_stock_data.csv"
CLEAN_DATA_PATH <- "data/processed/fpt_clean.csv"

# Đường dẫn output
FIGURE_DIR <- "output/figures"
TABLE_DIR <- "output/tables"
MODEL_DIR <- "output/models"

# Tạo thư mục nếu chưa có
dir.create(FIGURE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TABLE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(MODEL_DIR, recursive = TRUE, showWarnings = FALSE)