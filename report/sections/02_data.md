# Dữ liệu

Dữ liệu sử dụng trong nghiên cứu là dữ liệu giá cổ phiếu FPT lấy từ Yahoo Finance với mã `FPT.VN`. Giai đoạn dữ liệu được tái lập từ ngày 2015-01-01 đến hết ngày 2026-06-08. File dữ liệu thô được lưu tại `data/raw/FPT_stock_data.csv`.

Notebook thu thập dữ liệu sử dụng tùy chọn `auto_adjust = TRUE`, vì vậy cột `close` được xem là giá đóng cửa đã điều chỉnh. Dữ liệu thô gồm 2,960 dòng và 6 biến: `date`, `open`, `high`, `low`, `close`, `volume`.

Quy trình làm sạch được thực hiện trong `R/01_data_cleaning.R`. Trước hết, nhóm chuẩn hóa tên cột, chuyển `date` về kiểu ngày và chuyển các biến giá, khối lượng về dạng số. Sau đó, dữ liệu được kiểm tra ngày lỗi, ngày trùng, giá trị thiếu, giá không dương, khối lượng âm và quan hệ OHLC.

Kết quả kiểm tra cho thấy dữ liệu thô không có ngày trùng, không có ngày lỗi, không có giá không dương và không có khối lượng âm. Tuy nhiên, dữ liệu có 173 dòng `volume = 0`. Các dòng này được loại khỏi dữ liệu sạch vì không đại diện cho phiên giao dịch hữu ích khi phân tích lợi suất.

Sau khi loại các dòng `volume = 0`, nhóm ghi nhận 18 dòng có quan hệ OHLC chưa nhất quán. Để dữ liệu sạch không vi phạm kiểm tra OHLC, nhóm chuẩn hóa `high` và `low` sao cho `high` không thấp hơn `open` hoặc `close`, đồng thời `low` không cao hơn `open` hoặc `close`.

Dữ liệu sạch được lưu tại `data/processed/fpt_clean.csv`, gồm 2,787 dòng trong giai đoạn từ 2015-01-05 đến 2026-06-08. Dữ liệu sạch có 8 biến: `date`, `open`, `high`, `low`, `close`, `volume`, `log_close`, `return`.

Biến `log_close` được tính bằng log tự nhiên của `close`. Biến lợi suất được thống nhất là lợi suất log hằng ngày:

`return_t = log(close_t) - log(close_{t-1})`

Dòng đầu tiên của `return` là `NA` vì không có quan sát trước đó để tính lợi suất. Các dòng còn lại không thiếu giá trị `return`.

Các bảng kiểm tra và thống kê mô tả được lưu trong thư mục `output/tables`, gồm `data_quality_report.csv`, `missing_values.csv` và `data_summary.csv`.

Một hạn chế của dữ liệu là nguồn Yahoo Finance có thể điều chỉnh dữ liệu lịch sử theo thời gian. Vì vậy, số quan sát có thể thay đổi nhẹ nếu dữ liệu được tải lại ở thời điểm khác.