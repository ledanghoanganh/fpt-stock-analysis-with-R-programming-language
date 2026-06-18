# Tổng quan Dữ liệu Cổ phiếu FPT (FPT Stock Data Overview)

Thư mục này chứa dữ liệu thô và dữ liệu đã qua làm sạch của cổ phiếu FPT, phục vụ cho quá trình phân tích và mô hình hóa chuỗi thời gian.

## 1. Thông tin chung (General Information)
- **Nguồn:** Dữ liệu được thu thập (crawl) thông qua thư viện `vnstock` bằng Python/Colab.
- **Mã cổ phiếu:** FPT (Công ty Cổ phần FPT - Sàn HOSE).
- **Giai đoạn:** Từ ngày **01/01/2015** đến ngày **08/06/2026** (hơn 11 năm dữ liệu lịch sử).
- **Tổng số quan sát:** 2.960 dòng dữ liệu (tương ứng với số phiên giao dịch).

## 2. Cấu trúc các file dữ liệu

### 2.1. Dữ liệu thô (`raw/FPT_stock_data.csv`)
Chứa các cột cơ bản chuẩn từ API:
- `date`: Ngày giao dịch.
- `close`: Giá đóng cửa (đã điều chỉnh).
- `high`: Giá cao nhất trong phiên.
- `low`: Giá thấp nhất trong phiên.
- `open`: Giá mở cửa.
- `volume`: Khối lượng giao dịch.

### 2.2. Dữ liệu sạch (`processed/fpt_clean.csv`)
Được sinh ra tự động sau khi chạy kịch bản `R/01_data_cleaning.R`, kế thừa toàn bộ cột của dữ liệu thô và bổ sung thêm 3 cột phục vụ phân tích:
- `time`: Định dạng chuẩn hóa Date hỗ trợ cho script vẽ biểu đồ.
- `log_close`: Logarit tự nhiên của giá đóng cửa ($ln(close)$) giúp làm mượt chuỗi dữ liệu.
- `return`: Tỷ suất sinh lời log hằng ngày ($log\_close_t - log\_close_{t-1}$), là đầu vào bắt buộc cho mô hình GARCH.

## 3. Những điểm đáng chú ý & Ghi chú phân tích (Important Insights & Notes)

1. **Sự tăng trưởng dài hạn ấn tượng:** Dữ liệu cho thấy giá đóng cửa (đã điều chỉnh) khởi điểm ở mức xấp xỉ **7.118 VNĐ** vào đầu năm 2015 và đạt mức trên **76.000 VNĐ** vào đầu tháng 06/2026. Chuỗi giá trị gốc có **xu hướng (trend)** tăng trưởng dài hạn cực kỳ mạnh mẽ, minh chứng rõ ràng cho việc chuỗi là **chuỗi không dừng (Non-stationary)**.
2. **Khối lượng giao dịch bằng 0:** Một số dòng dữ liệu ở những ngày đầu tiên (như `01/01/2015`, `02/01/2015`) có cột `volume = 0`. Điều này thường đại diện cho các ngày nghỉ lễ (như Tết Dương Lịch) khi thị trường đóng cửa nhưng hệ thống dữ liệu vẫn lưu lại mức giá của ngày liền kề trước đó. Không nên dùng `volume` trực tiếp để tính các chỉ số như VWAP vào những ngày này.
3. **Giá trị NA bắt buộc (Missing Value):** Vì công thức tính `return` là độ lệch giữa ngày hiện tại và ngày hôm trước, do đó cột `return` của ngày đầu tiên (`01/01/2015`) luôn mang giá trị `NA`. Khi huấn luyện mô hình (ARIMA, GARCH) bắt buộc phải có bước loại bỏ dòng `NA` này (ví dụ: `filter(!is.na(return))`) để mô hình không báo lỗi.
4. **Tính nhất quán:** Số lượng dòng (lines) của dữ liệu thô và dữ liệu sạch hoàn toàn khớp nhau (đều có 2961 dòng bao gồm header). Dữ liệu không bị khuyết tật (corrupted) và đã sẵn sàng 100% cho các bước phân tích chuỗi thời gian chuyên sâu.
