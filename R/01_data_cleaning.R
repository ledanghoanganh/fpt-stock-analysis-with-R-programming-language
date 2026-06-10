# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 01_data_cleaning.R
# PURPOSE: Đọc, kiểm tra và làm sạch dữ liệu thô cổ phiếu FPT
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN & CẤU HÌNH ----------------------------------------------
source("R/00_config.R")

# 2. KIỂM TRA ĐƯỜNG DẪN FILE --------------------------------------------------
if (!file.exists(RAW_DATA_PATH)) {
  stop(paste("Không tìm thấy file thô tại:", RAW_DATA_PATH))
}

# 3. ĐỌC VÀ KIỂM TRA ĐỊNH DẠNG DỮ LIỆU ----------------------------------------
df_raw <- read.csv(RAW_DATA_PATH, stringsAsFactors = FALSE)

print("--- Cấu trúc bộ dữ liệu thô ban đầu: ---")
str(df_raw)

# 4. TIẾN HÀNH LÀM SẠCH DỮ LIỆU ------------------------------------------------
df_clean <- df_raw %>%
  # Định dạng lại cột date
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
  
  # Loại bỏ các dòng bị trống hoặc lỗi định dạng
  filter(!is.na(date) & !is.na(close)) %>%
  
  # Tạo thêm các cột biến phục vụ phân tích theo yêu cầu
  mutate(
    time = date,               # Hỗ trợ script visualization cũ
    log_close = log(close),    # Log của giá đóng cửa
    return = log_close - lag(log_close) # Lợi suất log hằng ngày
  )

# 5. XUẤT DỮ LIỆU ĐÃ LÀM SẠCH -------------------------------------------------
# Lưu file sạch
write.csv(df_clean, CLEAN_DATA_PATH, row.names = FALSE)

print("--- Quá trình làm sạch hoàn tất! ---")
print(paste("Tổng số dòng dữ liệu thu được:", nrow(df_clean)))
print(paste("Giai đoạn dữ liệu: Từ ngày", min(df_clean$date), "đến ngày", max(df_clean$date)))