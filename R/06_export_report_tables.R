# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 06_export_report_tables.R
# PURPOSE: Gộp tất cả các bảng kết quả thành một file Excel (từng sheet riêng biệt)
#          để dễ dàng copy/paste định dạng vào báo cáo Word
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN & CẤU HÌNH ----------------------------------------------
source("R/00_config.R")
# Cài đặt thư viện openxlsx nếu chưa có
if (!requireNamespace("openxlsx", quietly = TRUE)) {
  install.packages("openxlsx")
}
library(openxlsx)

print("--- Khởi tạo quá trình tổng hợp báo cáo Excel ---")

# 2. ĐỌC TẤT CẢ CÁC BẢNG KẾT QUẢ ĐÃ ĐƯỢC LƯU -----------------------------------
path_missing <- file.path(TABLE_DIR, "missing_values.csv")
path_summary <- file.path(TABLE_DIR, "data_summary.csv")
path_garch <- file.path(TABLE_DIR, "garch_summary.csv")
path_compare <- file.path(TABLE_DIR, "model_comparison.csv")

# Kiểm tra đảm bảo các file đều tồn tại
files_to_check <- c(path_missing, path_summary, path_garch, path_compare)
if (!all(file.exists(files_to_check))) {
  stop("Thiếu file kết quả (CSV). Hãy đảm bảo bạn đã chạy đầy đủ từ script 01 đến 05.")
}

missing_vals <- read.csv(path_missing)
data_summary <- read.csv(path_summary)
garch_summary <- read.csv(path_garch)
model_compare <- read.csv(path_compare)

# 3. TẠO FILE EXCEL VÀ THÊM CÁC SHEET ------------------------------------------
wb <- createWorkbook()

# Style định dạng tiêu đề (Header): in đậm, chữ trắng, nền xanh học thuật
header_style <- createStyle(
  fontSize = 12, fontColour = "#FFFFFF", halign = "center", valign = "center",
  fgFill = "#4F81BD", border = "TopBottomLeftRight", textDecoration = "bold"
)

# Căn giữa cho toàn bộ dữ liệu trong bảng
body_style <- createStyle(halign = "center", valign = "center")

# Hàm hỗ trợ thêm sheet và tự động định dạng bảng đẹp mắt
add_formatted_sheet <- function(wb, sheet_name, data) {
  addWorksheet(wb, sheet_name)
  
  # Ghi dữ liệu vào sheet
  writeData(wb, sheet = sheet_name, x = data, borders = "all", borderColour = "#000000")
  
  # Tô màu xanh cho dòng Header
  addStyle(wb, sheet = sheet_name, style = header_style, rows = 1, cols = 1:ncol(data), gridExpand = TRUE)
  
  # Căn giữa cho phần thân bảng
  addStyle(wb, sheet = sheet_name, style = body_style, rows = 2:(nrow(data)+1), cols = 1:ncol(data), gridExpand = TRUE)
  
  # Tự động điều chỉnh độ rộng cột cho vừa chữ
  setColWidths(wb, sheet = sheet_name, cols = 1:ncol(data), widths = "auto")
}

# Thêm lần lượt từng bảng vào các sheet khác nhau
add_formatted_sheet(wb, "Thong_Ke_Mo_Ta", data_summary)
add_formatted_sheet(wb, "Missing_Values", missing_vals)
add_formatted_sheet(wb, "So_Sanh_Mo_Hinh", model_compare)
add_formatted_sheet(wb, "Tham_So_GARCH", garch_summary)

# 4. LƯU FILE EXCEL ------------------------------------------------------------
report_path <- file.path(TABLE_DIR, "report_tables.xlsx")
saveWorkbook(wb, report_path, overwrite = TRUE)

print("--- HOÀN THÀNH TẤT CẢ MODULE CODE! ---")
print(paste("Toàn bộ các bảng số liệu đã được gộp thành Excel tại:", report_path))
print("Giờ đây bạn chỉ cần mở file Excel này lên và bôi đen copy thẳng vào báo cáo Word cuối kỳ.")
