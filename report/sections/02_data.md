# Dữ liệu và kiểm tra chất lượng

## Nguồn và phạm vi

Dữ liệu được lấy từ Yahoo Finance với ticker `FPT.VN` bằng `notebooks/01_scrape_fpt_colab.ipynb`. Notebook dùng `auto_adjust = TRUE`, vì vậy các cột giá được hiểu là giá đã điều chỉnh theo dữ liệu của nhà cung cấp. Tệp raw cố định có `r fmt_number(raw_rows, 0)` dòng từ 2015-01-01 đến 2026-06-08 và được lưu tại `data/raw/FPT_stock_data.csv`.

| Biến | Ý nghĩa |
|---|---|
| `date` | Ngày quan sát |
| `open` | Giá mở cửa đã điều chỉnh |
| `high` | Giá cao nhất đã điều chỉnh |
| `low` | Giá thấp nhất đã điều chỉnh |
| `close` | Giá đóng cửa đã điều chỉnh |
| `volume` | Khối lượng giao dịch |

## Quy trình làm sạch

`R/01_data_cleaning.R` chuẩn hóa tên cột, chuyển kiểu Date/numeric, sắp xếp theo thời gian và kiểm tra schema. Pipeline dừng nếu có ngày lỗi, ngày trùng, missing OHLCV, giá không dương hoặc volume âm.

Dữ liệu raw có `r zero_volume_removed` dòng `volume = 0`; các dòng này bị loại vì không đại diện cho phiên có khối lượng giao dịch dương trong chuỗi mô hình. Quan hệ OHLC được kiểm tra với tolerance `1e-8` để không nhầm sai số floating-point khoảng `10^-12` với lỗi thực. Sau tolerance và lọc volume, `r ohlc_repaired` dòng OHLC bất thường thực sự được chuẩn hóa.

```{r quality-table}
quality_for_report <- quality_report %>%
  filter(check %in% c(
    "raw_rows", "invalid_date", "duplicate_date", "missing_ohlcv",
    "non_positive_price", "negative_volume", "zero_volume",
    "ohlc_rows_repaired_after_volume_filter"
  ))
kable(quality_for_report, caption = "Tóm tắt kiểm tra chất lượng dữ liệu")
```

## Dữ liệu model

Tệp `data/processed/fpt_clean.csv` có `r fmt_number(n_observations, 0)` dòng từ `r analysis_start` đến `r analysis_end`, gồm tám biến raw/derived. Hai biến được tạo thêm là:

\[
\text{log\_close}_t=\log(P_t), \qquad
r_t=\log(P_t)-\log(P_{t-1}).
\]

Return đầu tiên là `NA` theo định nghĩa vì không có giá phiên trước; còn lại có `r fmt_number(n_returns, 0)` log returns hợp lệ. Dữ liệu sạch không còn volume bằng 0.

```{r missing-table}
kable(
  missing_values %>% filter(variable %in% names(clean_data)),
  caption = "Giá trị thiếu trong tám biến của dữ liệu model",
  digits = 4
)
```

```{r descriptive-table}
kable(data_summary, caption = "Thống kê mô tả dữ liệu sạch", digits = 4)
```

Mean return lịch sử xấp xỉ `r fmt_number(100 * return_summary$mean, 4)`% mỗi phiên và standard deviation xấp xỉ `r fmt_number(100 * return_summary$sd, 3)`%. Đây là mô tả sample, không phải lợi suất hoặc rủi ro đảm bảo trong tương lai. Volume có mean lớn hơn median do phân phối lệch và các quan sát rất lớn.

## Hạn chế dữ liệu

Yahoo Finance có thể hiệu chỉnh dữ liệu lịch sử. Vì vậy dự án dùng fixed raw CSV để tái lập đúng sample; nếu tải lại dữ liệu, nhóm phải rerun toàn pipeline và không được trộn output cũ với input mới. Chuỗi chỉ gồm một cổ phiếu và chưa có market index hoặc biến vĩ mô để kiểm soát bối cảnh thị trường.
