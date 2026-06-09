# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 01_data_cleaning.R
# PURPOSE: Đọc, kiểm tra và làm sạch dữ liệu thô cổ phiếu FPT
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN ---------------------------------------------------------
library(tidyverse)
# 2. THIẾT LẬP ĐƯỜNG DẪN FILE --------------------------------------------------
raw_data_path <- "~/Downloads/FPT_stock_data.csv"
clean_data_path <- "data/processed/fpt_clean.csv"

# Kiểm tra xem file thô đã được đặt đúng chỗ chưa
if (!file.exists(raw_data_path)) {
  stop("Không tìm thấy file FPT_stock_data.csv trong thư mục data/raw/! Vui lòng kiểm tra lại.")
}

# 3. ĐỌC VÀ KIỂM TRA ĐỊNH DẠNG DỮ LIỆU ----------------------------------------
df_raw <- read.csv(raw_data_path, stringsAsFactors = FALSE)

print("--- Cấu trúc bộ dữ liệu thô ban đầu: ---")
str(df_raw)

# 4. TIẾN HÀNH LÀM SẠCH DỮ LIỆU ------------------------------------------------
df_clean <- df_raw %>%
  # Chuyển đổi cột time từ dạng chữ (character) sang dạng ngày tháng chuẩn (Date)
  mutate(time = as.Date(time)) %>%
  # Sắp xếp dữ liệu theo thứ tự thời gian tăng dần (từ xa nhất đến gần nhất)
  arrange(time) %>%
  # Đảm bảo các cột giá và khối lượng ở dạng số (numeric)
  mutate(
    open   = as.numeric(open),
    high   = as.numeric(high),
    low    = as.numeric(low),
    close  = as.numeric(close),
    volume = as.numeric(volume)
  ) %>%
  # Loại bỏ các dòng bị trống hoàn toàn (nếu có)
  filter(!is.na(time) & !is.na(close))

# 5. XUẤT DỮ LIỆU ĐÃ LÀM SẠCH -------------------------------------------------
# Tạo thư mục processed nếu chưa có
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# Lưu file sạch
write.csv(df_clean, clean_data_path, row.names = FALSE)

print("--- Quá trình làm sạch hoàn tất! ---")
print(paste("Tổng số dòng dữ liệu thu được:", nrow(df_clean)))
print(paste("Giai đoạn dữ liệu: Từ ngày", min(df_clean$time), "đến ngày", max(df_clean$time)))
