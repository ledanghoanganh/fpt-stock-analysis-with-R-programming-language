# FPT Stock Time Series Project

> **Đề tài:** Dự báo giá và phân tích biến động cổ phiếu FPT bằng mô hình chuỗi thời gian  
> **Môn học:** Lập Trình R Cho Phân Tích  
> **Trạng thái:** Đang phát triển  
> **Phiên bản README:** Mẫu tổng quan dự án, sẽ được cập nhật sau khi hoàn thành phân tích

---

## 1. Giới thiệu dự án

Dự án này tập trung vào việc **thu thập, làm sạch, phân tích, trực quan hóa và mô hình hóa dữ liệu giá cổ phiếu FPT** bằng các kỹ thuật phân tích chuỗi thời gian trong R.

Mục tiêu chính của dự án là xây dựng một quy trình phân tích hoàn chỉnh từ dữ liệu thô đến báo cáo cuối cùng, bao gồm:

- Thu thập dữ liệu giá cổ phiếu FPT bằng Python/Colab với thư viện `vnstock`.
- Làm sạch và chuẩn hóa dữ liệu để có thể phân tích bằng R.
- Thống kê mô tả và trực quan hóa biến động giá cổ phiếu.
- Kiểm tra tính dừng của chuỗi thời gian.
- Xây dựng mô hình dự báo giá bằng **ARIMA** và **ETS**.
- Phân tích volatility/rủi ro bằng mô hình **GARCH**.
- So sánh kết quả mô hình, thảo luận, kết luận và tổng hợp báo cáo Word.

Dự án được thiết kế để đáp ứng yêu cầu đồ án môn học, trong đó nhóm cần nộp **mã nguồn R**, **báo cáo Word**, và có thể kèm **notebook Colab** phục vụ phần thu thập dữ liệu.

---

## 2. Mục tiêu nghiên cứu

Các câu hỏi chính mà dự án hướng tới trả lời:

1. Dữ liệu giá cổ phiếu FPT trong giai đoạn nghiên cứu có đặc điểm biến động như thế nào?
2. Giá đóng cửa cổ phiếu FPT có xu hướng tăng/giảm rõ ràng hay không?
3. Chuỗi giá cổ phiếu FPT có dừng hay không?
4. Sau khi log transform và differencing, chuỗi có phù hợp hơn để mô hình hóa không?
5. Mô hình ARIMA và ETS cho kết quả dự báo giá cổ phiếu FPT như thế nào?
6. Mô hình nào có sai số dự báo thấp hơn dựa trên RMSE và MAPE?
7. Biến động/rủi ro của cổ phiếu FPT thay đổi như thế nào theo thời gian?
8. Mô hình GARCH có giúp nhận diện các giai đoạn volatility cao/thấp không?

---

## 3. Phạm vi dự án

### 3.1. Đối tượng phân tích

- Mã cổ phiếu: **FPT**
- Sàn giao dịch: **HOSE**
- Loại dữ liệu: Dữ liệu giá cổ phiếu theo ngày
- Biến phân tích chính: Giá đóng cửa (`close`) và lợi suất log (`return`)

### 3.2. Giai đoạn dữ liệu

> Phần này sẽ được cập nhật sau khi nhóm chốt dữ liệu cuối cùng.

- Ngày bắt đầu: `YYYY-MM-DD`
- Ngày kết thúc: `YYYY-MM-DD`
- Số quan sát: `...`
- Nguồn dữ liệu: `vnstock`

### 3.3. Phương pháp sử dụng

Dự án sử dụng các nhóm phương pháp sau:

- **Tiền xử lý dữ liệu:** kiểm tra thiếu dữ liệu, đổi kiểu dữ liệu, sắp xếp theo thời gian, tạo biến mới.
- **Thống kê mô tả:** min, max, mean, median, variance, standard deviation.
- **Trực quan hóa dữ liệu:** biểu đồ giá đóng cửa, khối lượng giao dịch, log return, phân phối return.
- **Kiểm định chuỗi thời gian:** ADF test, log transform, differencing.
- **Mô hình dự báo:** ARIMA và ETS.
- **Đánh giá mô hình:** RMSE và MAPE.
- **Mô hình volatility:** GARCH(1,1).
- **Tổng hợp báo cáo:** RMarkdown/Word.

---

## 4. Cấu trúc thư mục dự án

```text
fpt-stock-time-series/
│
├── README.md
├── .gitignore
├── FPT_Stock_TimeSeries.Rproj
│
├── docs/
│   ├── guide.md
│   ├── rubric/
│   └── references/
│
├── notebooks/
│   └── 01_scrape_fpt_colab.ipynb
│
├── data/
│   ├── raw/
│   │   └── FPT_stock_data.csv
│   ├── processed/
│   │   └── fpt_clean.csv
│   └── README_data.md
│
├── R/
│   ├── 00_config.R
│   ├── 01_data_cleaning.R
│   ├── 02_visualization.R
│   ├── 03_stationarity_arima_ets.R
│   ├── 04_garch_volatility.R
│   ├── 05_model_comparison.R
│   └── 06_export_report_tables.R
│
├── output/
│   ├── figures/
│   │   ├── close_price.png
│   │   ├── volume.png
│   │   ├── returns.png
│   │   ├── return_distribution.png
│   │   ├── arima_forecast.png
│   │   ├── ets_forecast.png
│   │   └── garch_volatility.png
│   │
│   ├── tables/
│   │   ├── data_summary.csv
│   │   ├── missing_values.csv
│   │   ├── stationarity_tests.csv
│   │   ├── forecast_metrics.csv
│   │   ├── garch_summary.csv
│   │   └── model_comparison.csv
│   │
│   └── models/
│       ├── arima_model.rds
│       ├── ets_model.rds
│       └── garch_model.rds
│
└── report/
    ├── report.Rmd
    ├── report.docx
    └── sections/
        ├── 01_introduction.md
        ├── 02_data.md
        ├── 03_visualization.md
        ├── 04_modeling_arima_ets.md
        ├── 05_garch_results_discussion.md
        └── 06_conclusion.md
```

---

## 5. Chức năng chính của từng thư mục

| Thư mục | Chức năng |
|---|---|
| `docs/` | Lưu tài liệu hướng dẫn, rubric, tài liệu tham khảo, ghi chú lý thuyết. |
| `notebooks/` | Lưu notebook Python/Colab dùng để thu thập dữ liệu cổ phiếu FPT. |
| `data/raw/` | Lưu dữ liệu gốc vừa thu thập, chưa làm sạch. |
| `data/processed/` | Lưu dữ liệu đã làm sạch, chuẩn hóa, sẵn sàng phân tích. |
| `R/` | Lưu toàn bộ mã nguồn R theo từng bước xử lý. |
| `output/figures/` | Lưu biểu đồ sinh ra từ R. |
| `output/tables/` | Lưu bảng kết quả, thống kê, metric, kiểm định. |
| `output/models/` | Lưu các mô hình đã train dưới dạng `.rds`. |
| `report/` | Lưu file báo cáo chính và các phần nội dung báo cáo. |

---

## 6. Chức năng chính của từng file

### 6.1. File cấu hình chung

| File | Chức năng |
|---|---|
| `R/00_config.R` | Khai báo thư viện, đường dẫn dữ liệu, đường dẫn output, tạo thư mục cần thiết. Tất cả script R nên gọi file này đầu tiên. |

Tất cả các file R nên bắt đầu bằng:

```r
source("R/00_config.R")
```

---

### 6.2. File thu thập và xử lý dữ liệu

| File | Phụ trách | Chức năng |
|---|---|---|
| `notebooks/01_scrape_fpt_colab.ipynb` | Người 1 | Thu thập dữ liệu FPT bằng `vnstock`, lưu ra CSV. |
| `R/01_data_cleaning.R` | Người 1 | Đọc dữ liệu thô, kiểm tra thiếu dữ liệu, chuẩn hóa cột ngày, tạo `log_close`, `return`, xuất dữ liệu sạch. |
| `R/02_visualization.R` | Người 1 | Tạo các biểu đồ mô tả dữ liệu: giá đóng cửa, khối lượng, return, phân phối return. |

---

### 6.3. File mô hình hóa ARIMA/ETS

| File | Phụ trách | Chức năng |
|---|---|---|
| `R/03_stationarity_arima_ets.R` | Người 2 | Kiểm định ADF, log transform, differencing, xây dựng ARIMA, ETS, tính RMSE/MAPE và xuất kết quả. |

---

### 6.4. File GARCH, so sánh mô hình và xuất kết quả

| File | Phụ trách | Chức năng |
|---|---|---|
| `R/04_garch_volatility.R` | Người 3 | Xây dựng mô hình GARCH(1,1), phân tích volatility, xuất biểu đồ và bảng kết quả. |
| `R/05_model_comparison.R` | Người 3 | Đọc kết quả ARIMA/ETS và GARCH, tạo bảng so sánh mô hình. |
| `R/06_export_report_tables.R` | Người 3 | Tổng hợp bảng/figure cần đưa vào báo cáo cuối. |

---

### 6.5. File báo cáo

| File | Phụ trách | Chức năng |
|---|---|---|
| `report/report.Rmd` | Người 3 | File báo cáo chính, gọi các section nhỏ và knit ra Word. |
| `report/sections/01_introduction.md` | Cả nhóm/Người 3 tổng hợp | Giới thiệu đề tài, lý do chọn đề tài, mục tiêu. |
| `report/sections/02_data.md` | Người 1 | Mô tả nguồn dữ liệu, các biến, cách làm sạch. |
| `report/sections/03_visualization.md` | Người 1 | Phân tích các biểu đồ trực quan hóa. |
| `report/sections/04_modeling_arima_ets.md` | Người 2 | Trình bày kiểm định tính dừng, ARIMA, ETS, RMSE, MAPE. |
| `report/sections/05_garch_results_discussion.md` | Người 3 | Trình bày GARCH, volatility, so sánh mô hình, thảo luận kết quả. |
| `report/sections/06_conclusion.md` | Người 3 | Kết luận, hạn chế, hướng phát triển. |

---

## 7. Phân công công việc

### 7.1. Người 1 - Data + Visualization

**Tỉ trọng dự kiến:** khoảng 30%

Người 1 chịu trách nhiệm toàn bộ phần dữ liệu và trực quan hóa.

#### Công việc cần làm

- Thu thập dữ liệu cổ phiếu FPT bằng notebook Python/Colab.
- Lưu dữ liệu thô vào `data/raw/FPT_stock_data.csv`.
- Làm sạch dữ liệu bằng R.
- Kiểm tra dữ liệu thiếu.
- Kiểm tra kiểu dữ liệu của từng cột.
- Tạo thêm các biến phục vụ phân tích như `log_close` và `return`.
- Xuất dữ liệu sạch ra `data/processed/fpt_clean.csv`.
- Tạo thống kê mô tả.
- Vẽ các biểu đồ trực quan hóa.
- Viết nội dung phần Data và Visualization trong báo cáo.

#### File phụ trách

- `notebooks/01_scrape_fpt_colab.ipynb`
- `R/01_data_cleaning.R`
- `R/02_visualization.R`
- `report/sections/02_data.md`
- `report/sections/03_visualization.md`

#### Output bắt buộc

- `data/raw/FPT_stock_data.csv`
- `data/processed/fpt_clean.csv`
- `output/tables/data_summary.csv`
- `output/tables/missing_values.csv`
- `output/figures/close_price.png`
- `output/figures/volume.png`
- `output/figures/returns.png`
- `output/figures/return_distribution.png`

---

### 7.2. Người 2 - Modeling ARIMA/ETS

**Tỉ trọng dự kiến:** khoảng 35%

Người 2 chịu trách nhiệm phần kiểm định chuỗi thời gian và dự báo giá bằng ARIMA/ETS.

#### Công việc cần làm

- Đọc dữ liệu sạch từ `data/processed/fpt_clean.csv`.
- Kiểm định tính dừng bằng ADF.
- Thực hiện log transform nếu cần.
- Thực hiện differencing để làm chuỗi dừng.
- Chia dữ liệu thành train/test.
- Xây dựng mô hình ARIMA.
- Xây dựng mô hình ETS.
- Dự báo giá trên tập test.
- Tính RMSE và MAPE.
- Xuất bảng kết quả mô hình.
- Vẽ biểu đồ dự báo ARIMA/ETS so với giá thực tế.
- Viết phần Modeling ARIMA/ETS trong báo cáo.

#### File phụ trách

- `R/03_stationarity_arima_ets.R`
- `report/sections/04_modeling_arima_ets.md`

#### Output bắt buộc

- `output/tables/stationarity_tests.csv`
- `output/tables/forecast_metrics.csv`
- `output/figures/arima_forecast.png`
- `output/figures/ets_forecast.png`
- `output/models/arima_model.rds`
- `output/models/ets_model.rds`

---

### 7.3. Người 3 - GARCH + Results & Discussion + Tổng hợp báo cáo

**Tỉ trọng dự kiến:** khoảng 35%

Người 3 chịu trách nhiệm phân tích volatility bằng GARCH, so sánh mô hình, viết Results & Discussion, viết kết luận và ghép báo cáo cuối.

#### Công việc cần làm

- Đọc dữ liệu sạch từ `data/processed/fpt_clean.csv`.
- Sử dụng chuỗi lợi suất log (`return`) để xây dựng mô hình GARCH.
- Xây dựng mô hình GARCH(1,1).
- Phân tích volatility/conditional sigma/conditional variance.
- Xuất biểu đồ volatility.
- Xuất bảng tham số mô hình GARCH.
- Đọc kết quả ARIMA/ETS từ `forecast_metrics.csv`.
- Tổng hợp bảng so sánh mô hình.
- Viết Results & Discussion.
- Viết kết luận.
- Ghép các section báo cáo thành file Word cuối cùng.

#### File phụ trách

- `R/04_garch_volatility.R`
- `R/05_model_comparison.R`
- `R/06_export_report_tables.R`
- `report/sections/05_garch_results_discussion.md`
- `report/sections/06_conclusion.md`
- `report/report.Rmd`

#### Output bắt buộc

- `output/tables/garch_summary.csv`
- `output/tables/garch_volatility.csv`
- `output/tables/model_comparison.csv`
- `output/figures/garch_volatility.png`
- `output/models/garch_model.rds`
- `report/report.docx`

---

## 8. Chuẩn dữ liệu dùng chung

File dữ liệu sạch bắt buộc phải có đường dẫn:

```text
data/processed/fpt_clean.csv
```

File này là đầu vào chính cho Người 2 và Người 3.

### 8.1. Các cột bắt buộc

| Cột | Kiểu dữ liệu | Ý nghĩa |
|---|---|---|
| `date` | Date | Ngày giao dịch. |
| `open` | Numeric | Giá mở cửa. |
| `high` | Numeric | Giá cao nhất trong ngày. |
| `low` | Numeric | Giá thấp nhất trong ngày. |
| `close` | Numeric | Giá đóng cửa. |
| `volume` | Numeric | Khối lượng giao dịch. |
| `log_close` | Numeric | Log tự nhiên của giá đóng cửa. |
| `return` | Numeric | Lợi suất log, tính bằng `log_close - lag(log_close)`. |

### 8.2. Công thức biến tạo thêm

```r
log_close = log(close)
return = log_close - lag(log_close)
```

### 8.3. Yêu cầu đối với dữ liệu sạch

- Không để sai kiểu dữ liệu ở các cột số.
- Cột `date` phải có kiểu `Date`.
- Dữ liệu phải được sắp xếp tăng dần theo thời gian.
- Không được có dòng trùng lặp theo `date`.
- Nếu có giá trị thiếu, cần xử lý hoặc giải thích trong báo cáo.
- File `fpt_clean.csv` phải được commit vào repo để các thành viên khác chạy được.

---

## 9. Cài đặt môi trường

### 9.1. Phần mềm cần có

- R phiên bản khuyến nghị: `>= 4.3.0`
- RStudio hoặc VS Code có extension R
- Python hoặc Google Colab cho phần thu thập dữ liệu
- Git để quản lý phiên bản

### 9.2. Gói R cần cài đặt

Chạy một lần trong R console:

```r
install.packages(c(
  "tidyverse",
  "lubridate",
  "forecast",
  "tseries",
  "rugarch",
  "knitr",
  "rmarkdown"
))
```

### 9.3. Gói Python cần cài đặt trong Colab

```python
!pip install vnstock --upgrade
```

---

## 10. Cách chạy toàn bộ project

Chạy theo đúng thứ tự dưới đây để tránh lỗi thiếu file.

### Bước 1: Thu thập dữ liệu

Mở và chạy notebook:

```text
notebooks/01_scrape_fpt_colab.ipynb
```

Kết quả cần có:

```text
data/raw/FPT_stock_data.csv
```

### Bước 2: Làm sạch dữ liệu

Chạy file:

```r
source("R/01_data_cleaning.R")
```

Kết quả cần có:

```text
data/processed/fpt_clean.csv
output/tables/data_summary.csv
output/tables/missing_values.csv
```

### Bước 3: Trực quan hóa dữ liệu

Chạy file:

```r
source("R/02_visualization.R")
```

Kết quả cần có:

```text
output/figures/close_price.png
output/figures/volume.png
output/figures/returns.png
output/figures/return_distribution.png
```

### Bước 4: Mô hình ARIMA/ETS

Chạy file:

```r
source("R/03_stationarity_arima_ets.R")
```

Kết quả cần có:

```text
output/tables/stationarity_tests.csv
output/tables/forecast_metrics.csv
output/figures/arima_forecast.png
output/figures/ets_forecast.png
output/models/arima_model.rds
output/models/ets_model.rds
```

### Bước 5: Mô hình GARCH

Chạy file:

```r
source("R/04_garch_volatility.R")
```

Kết quả cần có:

```text
output/tables/garch_summary.csv
output/tables/garch_volatility.csv
output/figures/garch_volatility.png
output/models/garch_model.rds
```

### Bước 6: So sánh mô hình

Chạy file:

```r
source("R/05_model_comparison.R")
```

Kết quả cần có:

```text
output/tables/model_comparison.csv
```

### Bước 7: Xuất bảng/ảnh cho báo cáo

Chạy file:

```r
source("R/06_export_report_tables.R")
```

Kết quả sẽ được dùng để đưa vào báo cáo cuối.

### Bước 8: Xuất báo cáo Word

Mở file:

```text
report/report.Rmd
```

Sau đó bấm **Knit** trong RStudio để xuất:

```text
report/report.docx
```

---

## 11. Kết quả dự kiến của dự án

Sau khi hoàn thành, dự án sẽ tạo ra các nhóm kết quả sau.

### 11.1. Dữ liệu

| File | Nội dung | Trạng thái |
|---|---|---|
| `data/raw/FPT_stock_data.csv` | Dữ liệu gốc thu thập bằng `vnstock`. | Chưa cập nhật |
| `data/processed/fpt_clean.csv` | Dữ liệu đã làm sạch, có thêm `log_close`, `return`. | Chưa cập nhật |

### 11.2. Bảng kết quả

| File | Nội dung | Trạng thái |
|---|---|---|
| `output/tables/data_summary.csv` | Thống kê mô tả dữ liệu. | Chưa cập nhật |
| `output/tables/missing_values.csv` | Số lượng giá trị thiếu theo từng cột. | Chưa cập nhật |
| `output/tables/stationarity_tests.csv` | Kết quả kiểm định ADF. | Chưa cập nhật |
| `output/tables/forecast_metrics.csv` | RMSE, MAPE của ARIMA và ETS. | Chưa cập nhật |
| `output/tables/garch_summary.csv` | Tham số mô hình GARCH. | Chưa cập nhật |
| `output/tables/model_comparison.csv` | Bảng so sánh mô hình. | Chưa cập nhật |

### 11.3. Biểu đồ

| File | Nội dung | Trạng thái |
|---|---|---|
| `output/figures/close_price.png` | Biểu đồ giá đóng cửa FPT theo thời gian. | Chưa cập nhật |
| `output/figures/volume.png` | Biểu đồ khối lượng giao dịch. | Chưa cập nhật |
| `output/figures/returns.png` | Biểu đồ log return. | Chưa cập nhật |
| `output/figures/return_distribution.png` | Phân phối log return. | Chưa cập nhật |
| `output/figures/arima_forecast.png` | Dự báo ARIMA so với thực tế. | Chưa cập nhật |
| `output/figures/ets_forecast.png` | Dự báo ETS so với thực tế. | Chưa cập nhật |
| `output/figures/garch_volatility.png` | Biểu đồ volatility từ GARCH. | Chưa cập nhật |

### 11.4. Mô hình

| File | Nội dung | Trạng thái |
|---|---|---|
| `output/models/arima_model.rds` | Mô hình ARIMA đã train. | Chưa cập nhật |
| `output/models/ets_model.rds` | Mô hình ETS đã train. | Chưa cập nhật |
| `output/models/garch_model.rds` | Mô hình GARCH đã train. | Chưa cập nhật |

### 11.5. Báo cáo

| File | Nội dung | Trạng thái |
|---|---|---|
| `report/report.Rmd` | File nguồn báo cáo. | Chưa cập nhật |
| `report/report.docx` | Báo cáo Word cuối cùng. | Chưa cập nhật |

---

## 12. Tóm tắt kết quả cuối cùng

> Phần này sẽ được nhóm điền sau khi chạy xong toàn bộ mô hình.

### 12.1. Thống kê dữ liệu

- Giai đoạn phân tích: `...`
- Số dòng dữ liệu: `...`
- Giá đóng cửa thấp nhất: `...`
- Giá đóng cửa cao nhất: `...`
- Giá đóng cửa trung bình: `...`
- Độ lệch chuẩn giá đóng cửa: `...`

### 12.2. Kết quả kiểm định tính dừng

- ADF test trên chuỗi giá gốc: `...`
- ADF test trên chuỗi log return/sai phân: `...`
- Kết luận: `...`

### 12.3. Kết quả dự báo

| Mô hình | RMSE | MAPE | Nhận xét |
|---|---:|---:|---|
| ARIMA | `...` | `...` | `...` |
| ETS | `...` | `...` | `...` |

### 12.4. Kết quả GARCH

- Mô hình sử dụng: `GARCH(1,1)`
- Tham số omega: `...`
- Tham số alpha1: `...`
- Tham số beta1: `...`
- Nhận xét volatility: `...`

### 12.5. Kết luận mô hình tốt nhất

> Điền sau khi có kết quả thực tế.

- Mô hình dự báo giá tốt hơn: `...`
- Lý do: `...`
- Mô hình phân tích volatility: `GARCH(1,1)`
- Nhận xét tổng quan: `...`

---

## 13. Cấu trúc báo cáo cuối cùng

Báo cáo Word cuối cùng dự kiến gồm các phần:

1. Tóm tắt / Abstract
2. Giới thiệu / Introduction
3. Dữ liệu / Data
4. Trực quan hóa dữ liệu / Data Visualization
5. Mô hình hóa dữ liệu / Data Modeling
6. Thực nghiệm, kết quả và thảo luận / Results & Discussion
7. Kết luận / Conclusion
8. Phụ lục / Appendices
9. Đóng góp thành viên / Contributions
10. Tài liệu tham khảo / References
11. Peer Assessment

---

## 14. Quy tắc làm việc nhóm

### 14.1. Quy tắc chung

- Không sửa trực tiếp file của người khác nếu chưa thống nhất.
- Mỗi người chỉ làm đúng file được phân công.
- Khi tạo output, phải lưu đúng tên file và đúng thư mục đã quy định.
- Nếu thay đổi tên cột dữ liệu, phải báo cả nhóm.
- Nếu script cần file output từ người khác, phải kiểm tra file tồn tại trước khi chạy.
- Không hard-code đường dẫn tuyệt đối theo máy cá nhân như `C:/Users/...`.
- Tất cả đường dẫn nên viết tương đối từ thư mục gốc project.

### 14.2. Quy tắc đặt tên file

- Tên file viết thường hoặc theo số thứ tự.
- Không dùng dấu tiếng Việt trong tên file.
- Không dùng khoảng trắng trong tên file.
- Nên dùng dấu gạch dưới `_`.

Ví dụ tốt:

```text
fpt_clean.csv
forecast_metrics.csv
garch_volatility.png
```

Ví dụ không nên dùng:

```text
Dữ liệu sạch.csv
kết quả mô hình.xlsx
biểu đồ cuối cùng.png
```

### 14.3. Quy tắc commit Git

Nếu dùng Git, mỗi người nên làm trên branch riêng:

```bash
git checkout -b person1-data-visualization
git checkout -b person2-arima-ets
git checkout -b person3-garch-report
```

Ví dụ commit:

```bash
git add .
git commit -m "Add GARCH volatility analysis"
git push origin person3-garch-report
```

---

## 15. Checklist hoàn thành dự án

### 15.1. Checklist Người 1

- [x] Đã thu thập dữ liệu FPT bằng notebook Colab.
- [x] Đã lưu dữ liệu thô vào `data/raw/FPT_stock_data.csv`.
- [x] Đã làm sạch dữ liệu.
- [x] Đã tạo `data/processed/fpt_clean.csv`.
- [x] Đã tạo thống kê mô tả.
- [x] Đã kiểm tra missing values.
- [x] Đã tạo biểu đồ giá đóng cửa.
- [x] Đã tạo biểu đồ volume.
- [x] Đã tạo biểu đồ return.
- [x] Đã viết phần Data.
- [x] Đã viết phần Visualization.

### 15.2. Checklist Người 2

- [x] Đã đọc được `data/processed/fpt_clean.csv`.
- [x] Đã kiểm định ADF.
- [x] Đã log transform.
- [x] Đã differencing.
- [x] Đã chia train/test.
- [x] Đã xây dựng ARIMA.
- [x] Đã xây dựng ETS.
- [x] Đã tính RMSE.
- [x] Đã tính MAPE.
- [x] Đã xuất `forecast_metrics.csv`.
- [x] Đã lưu model ARIMA/ETS.
- [x] Đã viết phần Modeling ARIMA/ETS.

### 15.3. Checklist Người 3

- [ ] Đã đọc được `data/processed/fpt_clean.csv`.
- [ ] Đã xây dựng GARCH(1,1).
- [ ] Đã xuất `garch_summary.csv`.
- [ ] Đã xuất `garch_volatility.csv`.
- [ ] Đã tạo biểu đồ volatility.
- [ ] Đã đọc được `forecast_metrics.csv`.
- [ ] Đã tạo `model_comparison.csv`.
- [ ] Đã viết Results & Discussion.
- [ ] Đã viết Conclusion.
- [ ] Đã ghép báo cáo bằng `report.Rmd`.
- [ ] Đã xuất `report/report.docx`.

### 15.4. Checklist trước khi nộp

- [ ] Repo có đủ mã nguồn R.
- [ ] Repo có đủ dữ liệu cần thiết để chạy lại.
- [ ] Repo có đủ biểu đồ output.
- [ ] Repo có đủ bảng kết quả.
- [ ] Báo cáo Word đã cập nhật kết quả thật.
- [ ] README.md đã cập nhật đầy đủ phần kết quả cuối cùng.
- [ ] Không còn đường dẫn tuyệt đối theo máy cá nhân.
- [ ] Không còn phần placeholder quan trọng như `...` trong báo cáo cuối.
- [ ] Cả nhóm đã đọc lại phần Contributions và Peer Assessment.

---

## 16. Đóng góp thành viên

> Phần này sẽ được cập nhật sau khi hoàn thành dự án.

| Thành viên | Vai trò | Công việc chính | Mức độ hoàn thành |
|---|---|---|---|
| Người 1 | Data + Visualization | Thu thập, làm sạch, thống kê mô tả, trực quan hóa. | `...` |
| Người 2 | ARIMA + ETS | Kiểm định tính dừng, mô hình ARIMA/ETS, RMSE/MAPE. | `...` |
| Người 3 | GARCH + Report | GARCH, volatility, so sánh mô hình, Results & Discussion, kết luận, ghép báo cáo. | `...` |

---

## 17. Hạn chế của dự án

> Phần này sẽ được cập nhật sau khi hoàn thành phân tích.

Một số hạn chế dự kiến:

- Dự án chủ yếu sử dụng dữ liệu giá lịch sử, chưa bổ sung tin tức, dữ liệu vĩ mô hoặc chỉ số thị trường.
- ARIMA và ETS có thể chưa nắm bắt tốt các biến động bất thường của thị trường chứng khoán.
- GARCH phân tích volatility tốt nhưng không trực tiếp trả lời câu hỏi dự báo giá nếu không kết hợp thêm mô hình mean equation phù hợp.
- Kết quả dự báo phụ thuộc nhiều vào giai đoạn dữ liệu được chọn.

---

## 18. Hướng phát triển

Một số hướng mở rộng nếu có thời gian:

- Thử mô hình SARIMA nếu dữ liệu có dấu hiệu mùa vụ.
- Thử Prophet để so sánh với ARIMA/ETS.
- Thử mô hình machine learning như Random Forest, XGBoost.
- Thử mô hình deep learning như LSTM/GRU.
- Bổ sung dữ liệu VN-Index để so sánh với thị trường chung.
- Bổ sung dữ liệu tin tức hoặc dữ liệu tài chính doanh nghiệp.
- Dự báo nhiều bước hơn và kiểm tra độ ổn định của mô hình.

---

## 19. Tài liệu tham khảo

> Phần này sẽ được cập nhật sau khi nhóm hoàn thành báo cáo.

- Tài liệu lý thuyết phân tích thống kê và mô hình hóa chuỗi thời gian do giảng viên cung cấp.
- Tài liệu gói `forecast` trong R.
- Tài liệu gói `tseries` trong R.
- Tài liệu gói `rugarch` trong R.
- Tài liệu thư viện `vnstock` trong Python.
- Website thông tin nhà đầu tư của FPT.

---

## 20. Ghi chú

File `README.md` này đóng vai trò là **mô tả tổng quan dự án**. Các hướng dẫn thao tác chi tiết hơn cho từng thành viên được đặt trong:

```text
docs/guide.md
```

Sau khi dự án hoàn thành, nhóm cần quay lại cập nhật các phần còn thiếu trong README này, đặc biệt là:

- Giai đoạn dữ liệu thực tế.
- Số dòng dữ liệu.
- Kết quả thống kê mô tả.
- Kết quả ADF test.
- RMSE/MAPE của ARIMA và ETS.
- Tham số GARCH.
- Nhận xét mô hình tốt nhất.
- Đóng góp thành viên.
- Tài liệu tham khảo cuối cùng.
