# README dữ liệu

## Nguồn dữ liệu

Dữ liệu được lấy từ Yahoo Finance với mã cổ phiếu FPT.VN. Dữ liệu được tái lập cho giai đoạn từ 2015-01-01 đến hết 2026-06-08 bằng notebook `notebooks/01_scrape_fpt_colab.ipynb`.

Notebook sử dụng tùy chọn `auto_adjust = TRUE`, vì vậy cột `close` trong dữ liệu được hiểu là giá đóng cửa đã điều chỉnh.

## Dữ liệu thô

File dữ liệu thô nằm tại:

`data/raw/FPT_stock_data.csv`

Dữ liệu thô có 2,960 dòng và 6 cột:

- `date`: ngày giao dịch
- `open`: giá mở cửa
- `high`: giá cao nhất
- `low`: giá thấp nhất
- `close`: giá đóng cửa đã điều chỉnh
- `volume`: khối lượng giao dịch

## Dữ liệu sạch

File dữ liệu sạch nằm tại:

`data/processed/fpt_clean.csv`

Sau khi làm sạch, dữ liệu còn 2,787 dòng trong giai đoạn từ 2015-01-05 đến 2026-06-08.

Dữ liệu sạch có 8 cột:

- `date`: ngày giao dịch
- `open`: giá mở cửa
- `high`: giá cao nhất sau kiểm tra và chuẩn hóa OHLC
- `low`: giá thấp nhất sau kiểm tra và chuẩn hóa OHLC
- `close`: giá đóng cửa đã điều chỉnh
- `volume`: khối lượng giao dịch
- `log_close`: log tự nhiên của giá đóng cửa
- `return`: lợi suất log hằng ngày

Công thức sử dụng:

`log_close = log(close)`

`return = log(close_t) - log(close_{t-1})`

Dòng đầu tiên của `return` là `NA` vì không có ngày trước đó để tính lợi suất.

## Kiểm tra chất lượng dữ liệu

Quy trình làm sạch được thực hiện trong `R/01_data_cleaning.R`. Báo cáo chất lượng dữ liệu được lưu tại:

`output/tables/data_quality_report.csv`

Kết quả chính:

- Dữ liệu thô có 2,960 dòng.
- Không có ngày trùng.
- Không có ngày bị thiếu hoặc lỗi định dạng.
- Không có giá không dương.
- Có 173 dòng có `volume = 0`; các dòng này được loại khỏi dữ liệu sạch.
- Sau khi loại `volume = 0`, có 18 dòng có quan hệ OHLC chưa nhất quán; nhóm chuẩn hóa lại `high` và `low` để bảo đảm dữ liệu sạch không vi phạm quan hệ OHLC.
- Dữ liệu sạch cuối cùng có 2,787 dòng.

## Ghi chú xử lý `volume = 0`

Các dòng có `volume = 0` được loại bỏ vì không đại diện cho phiên giao dịch hữu ích khi phân tích lợi suất. Việc giữ các dòng này có thể tạo ra các quan sát không phù hợp cho mô hình chuỗi thời gian.

## Hạn chế

Dữ liệu phụ thuộc vào Yahoo Finance nên có thể thay đổi nếu nhà cung cấp điều chỉnh dữ liệu lịch sử. Báo cáo này không sử dụng dữ liệu để đưa ra khuyến nghị đầu tư.