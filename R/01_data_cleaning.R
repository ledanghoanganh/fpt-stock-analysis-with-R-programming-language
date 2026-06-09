# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 01_data_cleaning.R
# PURPOSE: Đọc, kiểm tra và làm sạch dữ liệu thô cổ phiếu FPT
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN ---------------------------------------------------------
library(tidyverse)
library(lubridate) # Thêm lubridate để xử lý ngày tháng thông minh hơn

# 2. THIẾT LẬP ĐƯỜNG DẪN FILE --------------------------------------------------
raw_data_path <- "~/Downloads/FPT_stock_data.csv"
clean_data_path <- "data/processed/fpt_clean.csv"

# Kiểm tra xem file thô đã được đặt đúng chỗ chưa
if (!file.exists(raw_data_path)) {
  stop("Không tìm thấy file FPT_stock_data.csv trong đường dẫn Downloads! Vui lòng kiểm tra lại.")
}

# 3. ĐỌC VÀ KIỂM TRA ĐỊNH DẠNG DỮ LIỆU ----------------------------------------
df_raw <- read.csv(raw_data_path, stringsAsFactors = FALSE)

print("--- Cấu trúc bộ dữ liệu thô ban đầu: ---")
str(df_raw)

# 4. TIẾN HÀNH LÀM SẠCH DỮ LIỆU ------------------------------------------------
df_clean <- df_raw %>%
  # Đổi tên cột từ time thành date theo đúng file thô mới
  mutate(date = as.Date(parse_date_time(date, orders = c("Ymd", "Ymd HMS", "dmY", "dmY HMS")))) %>%
  
  # Sắp xếp dữ liệu theo thứ tự thời gian tăng dần
  arrange(date) %>%
  
  # Đảm bảo các cột giá và khối lượng ở dạng số (numeric)
  mutate(
    open   = as.numeric(open),
    high   = as.numeric(high),
    low    = as.numeric(low),
    close  = as.numeric(close),
    volume = as.numeric(volume)
  ) %>%
  
  # Loại bỏ các dòng bị trống hoàn toàn hoặc lỗi định dạng (kiểm tra theo cột date)
  filter(!is.na(date) & !is.na(close))

# 5. XUẤT DỮ LIỆU ĐÃ LÀM SẠCH -------------------------------------------------
# Tạo thư mục processed nếu chưa có
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# Lưu file sạch
write.csv(df_clean, clean_data_path, row.names = FALSE)

print("--- Quá trình làm sạch hoàn tất! ---")
print(paste("Tổng số dòng dữ liệu thu được:", nrow(df_clean)))
print(paste("Giai đoạn dữ liệu: Từ ngày", min(df_clean$date), "đến ngày", max(df_clean$date)))