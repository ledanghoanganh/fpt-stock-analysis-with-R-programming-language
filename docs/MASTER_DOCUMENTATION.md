# MASTER DOCUMENTATION

Tài liệu này dành cho người làm trong dự án. Mục tiêu là giúp cả nhóm hiểu dữ liệu, code, output, kết quả và cách bảo trì repo mà không cần đọc lại toàn bộ lịch sử làm việc.

## 1. Thông tin chung

| Mục | Nội dung |
|---|---|
| Tên đề tài | Phân tích và dự báo cổ phiếu FPT bằng R |
| Môn học | Lập trình R cho phân tích |
| Nhóm | 06 |
| Giảng viên | TS. Phan Thị Thể |
| Đối tượng dữ liệu | Cổ phiếu FPT, ticker `FPT.VN` |
| Nguồn dữ liệu | Yahoo Finance |
| Ngôn ngữ chính | R |

Thành viên:

| Thành viên | MSSV | Tỷ lệ | Phạm vi |
|---|---:|---:|---|
| Trần Thiên Lực | 24133037 | 30% | Thu thập dữ liệu, cleaning, quality check, EDA |
| Nguyễn Đức Học | 24162039 | 35% | ADF, forecast models, rolling-origin CV, forecast diagnostics |
| Lê Đặng Hoàng Anh | 24162006 | 35% | GARCH, volatility diagnostics, model comparison, report integration |

## 2. Dự án trả lời câu hỏi gì?

Dự án có hai câu hỏi chính.

### 2.1 Giá FPT có thể được dự báo tốt hơn benchmark đơn giản không?

Response là `close`. Nhóm so sánh nhiều mô hình dự báo giá:

- Naive;
- Drift;
- ARIMA;
- SARIMA;
- ETS;
- ETS Damped;
- ARIMAX.

Metric chính:

- RMSE;
- MAE;
- MAPE;
- rolling-origin CV;
- Ljung-Box residual diagnostics.

### 2.2 Biến động của return FPT thay đổi theo thời gian như thế nào?

Response là `return`, không phải `close`. Nhóm dùng GARCH-family models:

- sGARCH-Normal;
- sGARCH-Student-t;
- eGARCH-Student-t;
- GJR-GARCH-Student-t.

Tiêu chí đánh giá:

- convergence;
- log-likelihood;
- AIC/BIC;
- persistence;
- Ljung-Box residuals;
- ARCH-LM;
- sign-bias;
- Nyblom parameter stability;
- adjusted Pearson GOF.

Hai bài toán này không được xếp chung một bảng điểm vì chúng có response, đơn vị đo và metric khác nhau.

## 3. Bản đồ repo

```text
.
├── README.md
├── FPT_Stock_TimeSeries.Rproj
├── data/
│   ├── raw/FPT_stock_data.csv
│   ├── processed/fpt_clean.csv
│   └── README_data.md
├── notebooks/
│   └── 01_scrape_fpt_colab.ipynb
├── R/
│   ├── 00_config.R
│   ├── 01_data_cleaning.R
│   ├── 02_visualization.R
│   ├── 03_stationarity_arima_ets.R
│   ├── 04_garch_volatility.R
│   ├── 05_model_comparison.R
│   ├── 06_export_report_tables.R
│   └── run_all.R
├── output/
│   ├── figures/
│   ├── models/
│   ├── tables/
│   └── pipeline_log.txt
├── report/
│   ├── report.Rmd
│   ├── report.docx
│   └── sections/
├── presentation/
└── docs/
    └── MASTER_DOCUMENTATION.md
```

Trong repo chính thức, `README.md` là file giới thiệu cho người ngoài dự án. File này là tài liệu nội bộ để hiểu và bảo trì dự án.

## 4. Pipeline tái lập

Pipeline đầy đủ:

```text
raw CSV
  -> cleaning
  -> processed CSV
  -> EDA figures/tables
  -> ADF + forecast models
  -> GARCH models
  -> model comparison
  -> workbook
  -> report.docx
```

Entry point:

```r
source("R/run_all.R")
```

Lần chạy nghiệm thu gần nhất:

```text
Pipeline started: 2026-06-23 11:42:17
Pipeline completed: 2026-06-23 11:43:26
```

Các bước đã chạy:

1. `R/01_data_cleaning.R`;
2. `R/02_visualization.R`;
3. `R/03_stationarity_arima_ets.R`;
4. `R/04_garch_volatility.R`;
5. `R/05_model_comparison.R`;
6. `R/06_export_report_tables.R`;
7. render `report/report.docx`;
8. render `presentation/khung_noi_dung_slide.docx`.

## 5. Dữ liệu

### 5.1 Raw data

File: `data/raw/FPT_stock_data.csv`

| Check | Giá trị |
|---|---:|
| Raw rows | 2,960 |
| Invalid date | 0 |
| Duplicate date | 0 |
| Missing OHLCV | 0 |
| Non-positive price | 0 |
| Negative volume | 0 |
| Zero volume | 173 |
| Raw high below open/close | 1 |
| Raw low above open/close | 0 |

### 5.2 Clean data

File: `data/processed/fpt_clean.csv`

| Nội dung | Giá trị |
|---|---:|
| Clean rows | 2,787 |
| Valid log returns | 2,786 |
| Period | 2015-01-05 đến 2026-06-08 |
| Mean return | 0.0008365 |
| SD return | 0.0165820 |
| Min return | -0.07248 |
| Max return | 0.08853 |

### 5.3 Các cột trong clean data

| Cột | Ý nghĩa |
|---|---|
| `date` | Ngày giao dịch |
| `open` | Giá mở cửa |
| `high` | Giá cao nhất |
| `low` | Giá thấp nhất |
| `close` | Giá đóng cửa đã điều chỉnh theo dữ liệu Yahoo Finance |
| `volume` | Khối lượng giao dịch |
| `log_close` | `log(close)` |
| `return` | `log(close_t) - log(close_(t-1))` |

### 5.4 Vì sao loại `volume = 0`?

Các dòng có `volume = 0` không phản ánh phiên giao dịch có thanh khoản bình thường. Nếu giữ lại, return và volatility có thể bị nhiễu bởi giá không đại diện cho giao dịch thật. Vì vậy dự án loại 173 dòng này trước khi mô hình hóa.

### 5.5 Vì sao dùng log return?

Giá `close` có trend và không dừng. GARCH không nên fit trực tiếp trên `close`. Log return ổn định hơn và phù hợp với mô hình variance.

Công thức:

```text
r_t = log(P_t) - log(P_(t-1))
    = log(P_t / P_(t-1))
```

Ví dụ nếu giá tăng từ 100,000 lên 102,000:

```text
simple return = 102000 / 100000 - 1 = 0.0200
log return    = log(102000 / 100000) ≈ 0.0198
```

## 6. Kiến thức nền cần nắm

### 6.1 Stationarity

Một chuỗi dừng là chuỗi có đặc tính thống kê tương đối ổn định theo thời gian. Với mô hình chuỗi thời gian, stationarity quan trọng vì nhiều mô hình giả định mean, variance và autocorrelation không trôi tự do theo thời gian.

Trong dự án:

- `close` không dừng;
- `log_close` không dừng;
- `return` dừng.

### 6.2 ADF test

ADF kiểm định unit root.

```text
H0: chuỗi có unit root, tức là không dừng.
H1: chuỗi không có unit root, tức là dừng.
```

Kết quả:

| Series | ADF statistic | p-value | Kết luận |
|---|---:|---:|---|
| Close | -1.7892 | 0.6676 | Không đủ bằng chứng bác bỏ H0 |
| Log close | -1.3194 | 0.8665 | Không đủ bằng chứng bác bỏ H0 |
| Return | -13.7914 | 0.0100 | Bác bỏ H0 |

Không nói “chấp nhận H0”. Nói đúng là “không đủ bằng chứng bác bỏ H0”.

### 6.3 Forecast metrics

RMSE:

```text
sqrt(mean((actual - predicted)^2))
```

RMSE phạt lỗi lớn mạnh hơn vì bình phương sai số.

MAE:

```text
mean(abs(actual - predicted))
```

MAE dễ hiểu vì cùng đơn vị với giá.

MAPE:

```text
mean(abs((actual - predicted) / actual)) * 100
```

MAPE là lỗi phần trăm, dễ so sánh hơn khi level giá thay đổi.

### 6.4 Rolling-origin CV

Rolling-origin CV đánh giá model qua nhiều điểm cắt thời gian:

```text
train 1 -> test 1
train 2 -> test 2
train 3 -> test 3
...
```

Điểm quan trọng: không shuffle dữ liệu time series vì làm vậy sẽ gây data leakage.

### 6.5 Residual diagnostics

Residual là phần model chưa giải thích được.

Nếu residual còn autocorrelation rõ, model chưa nắm hết cấu trúc thời gian. Dự án dùng Ljung-Box để kiểm tra residual forecast.

### 6.6 Volatility clustering

Volatility clustering là hiện tượng giai đoạn biến động lớn thường đi gần giai đoạn biến động lớn, và giai đoạn yên tĩnh thường đi gần giai đoạn yên tĩnh.

Trong dự án, điều này thấy qua:

- `returns.png`;
- `squared_returns.png`;
- ARCH-LM p-value rất nhỏ.

### 6.7 ARCH/GARCH

GARCH mô hình hóa phương sai có điều kiện:

```text
r_t = mu_t + epsilon_t
epsilon_t = sigma_t * z_t
sigma_t^2 = omega + alpha * epsilon_(t-1)^2 + beta * sigma_(t-1)^2
```

Ý nghĩa:

- `r_t`: log return;
- `mu_t`: conditional mean;
- `epsilon_t`: shock ngoài dự kiến;
- `sigma_t`: conditional volatility;
- `z_t`: standardized innovation;
- `alpha`: phản ứng với shock mới;
- `beta`: trí nhớ của volatility quá khứ.

GARCH không trực tiếp dự báo giá. Nó mô hình hóa độ bất định của return.

## 7. Đọc code theo từng file

### 7.1 `R/00_config.R`

Vai trò:

- nạp `tidyverse` và `lubridate`;
- khai báo đường dẫn dùng chung;
- tạo thư mục `output/figures`, `output/tables`, `output/models`;
- định nghĩa helper kiểm tra package;
- định nghĩa helper kiểm tra schema;
- định nghĩa helper ghi CSV.

Các biến quan trọng:

```r
RAW_DATA_PATH <- "data/raw/FPT_stock_data.csv"
CLEAN_DATA_PATH <- "data/processed/fpt_clean.csv"
FIGURE_DIR <- "output/figures"
TABLE_DIR <- "output/tables"
MODEL_DIR <- "output/models"
```

### 7.2 `R/01_data_cleaning.R`

Input:

- `data/raw/FPT_stock_data.csv`.

Việc chính:

1. Đọc raw CSV.
2. Chuẩn hóa tên cột.
3. Kiểm tra schema.
4. Kiểm tra lỗi dữ liệu.
5. Loại `volume = 0`.
6. Sửa 1 dòng OHLC bất thường sau khi lọc volume.
7. Tạo `log_close`.
8. Tạo `return`.
9. Ghi clean data.
10. Ghi quality report.

Output:

- `data/processed/fpt_clean.csv`;
- `output/tables/data_quality_report.csv`.

### 7.3 `R/02_visualization.R`

Input:

- `data/processed/fpt_clean.csv`.

Output bảng:

- `missing_values.csv`;
- `data_summary.csv`.

Output hình:

- `close_price.png`;
- `volume.png`;
- `returns.png`;
- `return_distribution.png`;
- `qqplot_return.png`;
- `squared_returns.png`;
- `acf_return.png`;
- `pacf_return.png`.

Các hình này đủ cho phần EDA trong báo cáo. Những hình thăm dò không phục vụ báo cáo chính đã được loại khỏi pipeline để tránh output dư.

### 7.4 `R/03_stationarity_arima_ets.R`

Input:

- `data/processed/fpt_clean.csv`.

Việc chính:

1. Kiểm định ADF cho `close`, `log_close`, `return`.
2. Tạo biến trễ cho ARIMAX.
3. Chia holdout 30 phiên cuối.
4. Fit forecast models.
5. Tính RMSE, MAE, MAPE.
6. Chạy Ljung-Box residual diagnostics.
7. Chạy rolling-origin CV.
8. Lưu fitted models vào `output/models`.

Forecast models:

- Naive;
- Drift;
- ARIMA;
- SARIMA;
- ETS;
- ETS Damped;
- ARIMAX.

Output:

- `stationarity_tests.csv`;
- `forecast_metrics.csv`;
- `forecast_diagnostics.csv`;
- `forecast_cv_metrics_raw.csv`;
- `forecast_cv_metrics_summary.csv`;
- `ets_damped_forecast.png`;
- `ets_damped_residual_diagnostics.png`;
- `arima_model.rds`;
- `sarima_model.rds`;
- `ets_model.rds`;
- `ets_damped_model.rds`;
- `arima_xreg_model.rds`.

### 7.5 `R/04_garch_volatility.R`

Input:

- log return từ `data/processed/fpt_clean.csv`.

Models:

- sGARCH-Normal;
- sGARCH-Student-t;
- eGARCH-Student-t;
- GJR-GARCH-Student-t.

Diagnostics:

- pre-fit ARCH-LM;
- Ljung-Box standardized residuals;
- Ljung-Box squared standardized residuals;
- ARCH-LM standardized residuals;
- sign-bias;
- Nyblom stability;
- adjusted Pearson GOF.

Output:

- `garch_comparison.csv`;
- `garch_parameters.csv`;
- `garch_diagnostics.csv`;
- `garch_diagnostic_summary.csv`;
- `garch_model_comparison.png`;
- `garch_acf_diagnostics.png`;
- `garch_news_impact.png`;
- `garch_model.rds`;
- `garch_candidate_model.rds`;
- `garch_fits.rds`.

### 7.6 `R/05_model_comparison.R`

Input:

- forecast metrics;
- forecast CV summary;
- forecast diagnostics;
- GARCH comparison;
- GARCH diagnostic summary.

Output:

- `price_forecast_comparison.csv`;
- `volatility_model_comparison.csv`;
- `model_comparison.csv`.

Logic quan trọng:

- Forecast và volatility được so sánh riêng.
- Forecast không được chọn chỉ theo holdout nếu CV và diagnostics không ủng hộ.
- GARCH không được chọn chỉ theo AIC nếu stability không đạt.

### 7.7 `R/06_export_report_tables.R`

Input:

- các CSV chính trong `output/tables`.

Output:

- `output/tables/report_tables.xlsx`.

Workbook này dùng để kiểm tra nhanh bảng, không phải nguồn model.

### 7.8 `R/run_all.R`

Entry point chạy từ đầu đến cuối:

1. Kiểm tra working directory.
2. Nạp config.
3. Kiểm tra packages.
4. Chạy 6 module.
5. Render báo cáo Word.
6. Render khung slide.
7. Ghi `output/pipeline_log.txt`.

## 8. Đọc output

### 8.1 Tables

| File | Cách dùng |
|---|---|
| `data_quality_report.csv` | Chứng minh dữ liệu đã được kiểm tra |
| `missing_values.csv` | Kiểm tra NA theo cột |
| `data_summary.csv` | Thống kê mô tả close, volume, return |
| `stationarity_tests.csv` | Kết quả ADF |
| `forecast_metrics.csv` | Holdout metrics |
| `forecast_cv_metrics_raw.csv` | Metric từng CV fold |
| `forecast_cv_metrics_summary.csv` | Mean/median CV |
| `forecast_diagnostics.csv` | Ljung-Box residual forecast |
| `price_forecast_comparison.csv` | Bảng kết luận forecast |
| `garch_comparison.csv` | AIC/BIC/persistence GARCH |
| `garch_parameters.csv` | Tham số GARCH |
| `garch_diagnostics.csv` | Diagnostic tests dạng dài |
| `garch_diagnostic_summary.csv` | Diagnostic summary theo model |
| `volatility_model_comparison.csv` | Bảng kết luận volatility |
| `model_comparison.csv` | Overview hai bài toán |
| `report_tables.xlsx` | Workbook tổng hợp |

### 8.2 Figures

| File | Thông điệp |
|---|---|
| `close_price.png` | Giá có trend, không nên fit GARCH trực tiếp |
| `volume.png` | Volume lệch phải và có spike lớn |
| `returns.png` | Return quanh 0 nhưng biên độ thay đổi |
| `squared_returns.png` | Volatility clustering |
| `return_distribution.png` | Return có heavy tails so với Normal |
| `qqplot_return.png` | Đuôi lệch khỏi Normal |
| `acf_return.png` | Autocorrelation tuyến tính của return |
| `pacf_return.png` | Partial autocorrelation của return |
| `ets_damped_forecast.png` | ETS Damped so với holdout actual |
| `ets_damped_residual_diagnostics.png` | Residual của ETS Damped còn cần kiểm tra |
| `garch_model_comparison.png` | Volatility ước lượng từ 4 GARCH models |
| `garch_acf_diagnostics.png` | GARCH đã xử lý dependence trong residual tốt đến đâu |
| `garch_news_impact.png` | Tác động shock âm/dương trong asymmetric GARCH |

### 8.3 Models

| File | Nội dung |
|---|---|
| `arima_model.rds` | Fitted ARIMA |
| `sarima_model.rds` | Fitted SARIMA |
| `ets_model.rds` | Fitted ETS |
| `ets_damped_model.rds` | Fitted ETS Damped |
| `arima_xreg_model.rds` | Fitted ARIMAX |
| `garch_model.rds` | Baseline sGARCH-Normal |
| `garch_candidate_model.rds` | eGARCH-Student-t |
| `garch_fits.rds` | Named list của 4 GARCH models |

Ví dụ load:

```r
model <- readRDS("output/models/ets_damped_model.rds")
forecast::forecast(model, h = 10)
```

GARCH:

```r
fits <- readRDS("output/models/garch_fits.rds")
names(fits)
```

## 9. Kết quả chính

### 9.1 EDA

- `close` tăng mạnh qua thời gian và có trend.
- `volume` lệch phải, có spike rất lớn.
- `return` dao động quanh 0.
- `squared_returns` có spike theo cụm, gợi ý volatility clustering.
- Distribution của return có heavy tails, nên Student-t là lựa chọn hợp lý để thử trong GARCH.

### 9.2 ADF

| Series | p-value | Kết luận |
|---|---:|---|
| Close | 0.6676 | Không dừng |
| Log close | 0.8665 | Không dừng |
| Return | 0.0100 | Dừng |

Kết luận thực hành: forecast giá có thể dùng differencing/ARIMA/ETS, còn volatility nên dùng return.

### 9.3 Forecast

| Model | RMSE | MAE | MAPE | CV mean RMSE |
|---|---:|---:|---:|---:|
| ETS Damped | 1,939.13 | 1,524.15 | 2.10% | 5,404.76 |
| Naive | 1,939.85 | 1,524.70 | 2.11% | 5,353.94 |
| SARIMA | 1,982.52 | 1,580.68 | 2.19% | NA |
| ETS | 1,987.03 | 1,518.66 | 2.08% | 5,477.37 |
| Drift | 2,021.03 | 1,608.96 | 2.23% | 5,396.80 |
| ARIMAX | 2,025.75 | 1,613.60 | 2.24% | NA |
| ARIMA | 2,119.64 | 1,710.78 | 2.38% | 6,501.47 |

Cách diễn giải:

- ETS Damped tốt nhất trên holdout 30 phiên.
- Chênh lệch ETS Damped và Naive rất nhỏ.
- Naive tốt nhất trong rolling CV.
- Residual diagnostics chưa đủ tốt để tuyên bố model phức tạp thắng ổn định.

### 9.4 Volatility

| Model | AIC | Persistence | Core diagnostics | Stability | Candidate |
|---|---:|---:|---|---|---|
| GJR-GARCH Student-t | -5.6344 | 0.9857 | Đạt | Không đạt | Không |
| eGARCH Student-t | -5.6331 | 0.9627 | Đạt | Đạt | Có |
| sGARCH Student-t | -5.6317 | 0.9891 | Đạt | Không đạt | Không |
| sGARCH Normal | -5.5073 | 0.9645 | Đạt | Không đạt | Không |

Cách diễn giải:

- GJR-GARCH có AIC thấp nhất nhưng parameter stability không đạt.
- eGARCH-Student-t có AIC rất gần GJR và đạt stability.
- Vì vậy eGARCH-Student-t là candidate cân bằng nhất.
- Không gọi eGARCH là “hoàn hảo” vì Pearson GOF vẫn không đạt.

## 10. Cách chạy dự án

### 10.1 Cài package

```r
install.packages(c(
  "tidyverse", "lubridate", "forecast", "tseries", "urca",
  "FinTS", "rugarch", "scales", "knitr", "rmarkdown", "openxlsx"
))
```

### 10.2 Chạy toàn bộ

Từ project root:

```r
source("R/run_all.R")
```

### 10.3 Chạy từng phần

```r
source("R/01_data_cleaning.R")
source("R/02_visualization.R")
source("R/03_stationarity_arima_ets.R")
source("R/04_garch_volatility.R")
source("R/05_model_comparison.R")
source("R/06_export_report_tables.R")
```

### 10.4 Render report

```r
rmarkdown::render(
  "report/report.Rmd",
  output_file = "report.docx",
  knit_root_dir = normalizePath(".")
)
```

### 10.5 PowerShell

```powershell
$env:RSTUDIO_PANDOC="C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools"
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" -e "source('R/run_all.R')"
```

## 11. Các lỗi thường gặp

### 11.1 Sai working directory

Dấu hiệu:

```text
Không tìm thấy FPT_Stock_TimeSeries.Rproj
```

Cách xử lý: mở `.Rproj` hoặc đặt working directory về project root.

### 11.2 Thiếu package

Cách xử lý: đọc tên package trong error và cài bằng `install.packages()`.

### 11.3 Thiếu Pandoc khi render Word

Cách xử lý trong Windows/RStudio:

```r
Sys.setenv(
  RSTUDIO_PANDOC =
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
)
```

### 11.4 GARCH fit chậm

GARCH dùng optimization. Nếu chạy chậm, kiểm tra:

- dữ liệu return có NA/Inf không;
- package `rugarch` đã cài đúng chưa;
- không chạy song song nhiều phiên R nặng.

### 11.5 Output cũ

Nếu nghi ngờ output cũ, chạy lại:

```r
source("R/run_all.R")
```

Sau đó kiểm tra:

- `output/pipeline_log.txt`;
- timestamp file output;
- row count trong `data_quality_report.csv`.

## 12. Quy ước bảo trì

### 12.1 Không sửa số trực tiếp trong report

Số liệu trong report phải đến từ CSV hoặc code chunk. Nếu số sai, sửa pipeline và render lại.

### 12.2 Không thêm output nếu không dùng

Output mới chỉ nên được thêm khi:

- có mặt trong report;
- phục vụ kiểm chứng model;
- hoặc phục vụ tái lập kết quả.

Output không dùng dễ làm người đọc hỏi lan man.

### 12.3 Giữ model RDS

`output/models/` được giữ vì đây là artifact cốt lõi để người khác load thử model mà không phải chạy lại toàn bộ pipeline.

### 12.4 Luôn tách forecast và volatility

Không viết “GARCH dự báo giá”. Cách đúng:

- forecast models dự báo `close`;
- GARCH models mô hình hóa conditional volatility của `return`.

### 12.5 Không gọi model là tốt nhất tuyệt đối

Cách nói đúng:

- “ETS Damped đứng đầu holdout nhưng chưa thắng ổn định trên CV.”
- “eGARCH-Student-t là candidate cân bằng nhất trong bốn specification đã thử.”

## 13. Hạn chế

### 13.1 Dữ liệu

- Chỉ dùng một cổ phiếu.
- Không dùng VN-Index hoặc biến vĩ mô.
- Không dùng tin tức.
- Không dùng dữ liệu intraday.

### 13.2 Forecast

- Holdout chỉ 30 phiên.
- SARIMA và ARIMAX chưa có rolling CV cùng coverage với các model còn lại.
- Residual forecast vẫn còn vấn đề theo Ljung-Box.

### 13.3 GARCH

- Mean equation cố định ARMA(0,0).
- Chưa có out-of-sample volatility loss.
- Chưa có VaR backtest.
- Pearson GOF không đạt cho cả bốn model.

## 14. Hướng phát triển

Ưu tiên hợp lý nếu phát triển tiếp:

1. Chạy rolling CV cùng coverage cho SARIMA và ARIMAX.
2. Thêm MASE hoặc sMAPE cho forecast.
3. Đánh giá prediction interval coverage.
4. Chia train/test cho volatility.
5. Dùng QLIKE hoặc MSE trên realized proxy variance.
6. Thêm VaR backtest.
7. Thử skewed Student-t hoặc GED trong GARCH.
8. Thêm VN-Index hoặc biến thị trường có kiểm soát leakage.

## 15. Checklist trước khi nộp

- [ ] `source("R/run_all.R")` chạy thành công.
- [ ] `output/pipeline_log.txt` có dòng `Pipeline completed`.
- [ ] `report/report.docx` mở được.
- [ ] `report/report.Rmd` không thiếu file input.
- [ ] `output/tables/` có đủ CSV chính.
- [ ] `output/figures/` chỉ chứa hình dùng trong báo cáo.
- [ ] `output/models/` có đủ 8 file `.rds`.
- [ ] README chỉ trình bày nội dung dự án, output chính và cách chạy.
- [ ] Báo cáo nêu rõ đây không phải khuyến nghị đầu tư.
- [ ] Các thành viên, MSSV và tỷ lệ đóng góp đúng.

## 16. Bảng thuật ngữ

| Thuật ngữ | Giải thích |
|---|---|
| ACF | Autocorrelation function |
| ADF | Augmented Dickey-Fuller test |
| AIC | Information criterion dùng để so sánh fit có penalty |
| ARCH | Variance phụ thuộc squared shock quá khứ |
| ARIMA | Autoregressive integrated moving average |
| ARIMAX | ARIMA có biến giải thích ngoài |
| BIC | Information criterion penalty mạnh hơn AIC |
| Conditional mean | Kỳ vọng có điều kiện |
| Conditional volatility | Độ biến động có điều kiện |
| Drift | Độ trôi trong random walk |
| eGARCH | GARCH trên log variance, hỗ trợ asymmetry |
| ETS | Error-trend-seasonality model |
| GARCH | Generalized ARCH |
| GJR-GARCH | GARCH có hiệu ứng shock âm |
| GOF | Goodness-of-fit |
| Heavy tails | Đuôi phân phối dày hơn Normal |
| Holdout | Tập dữ liệu giữ lại để kiểm tra |
| Innovation | Shock ngoài conditional mean |
| Ljung-Box | Kiểm định autocorrelation theo nhóm lag |
| Log return | Log tỷ số giá hai phiên liên tiếp |
| MAE | Mean absolute error |
| MAPE | Mean absolute percentage error |
| Naive | Dự báo bằng quan sát cuối cùng |
| Nyblom | Kiểm định stability của tham số |
| OHLCV | Open, high, low, close, volume |
| PACF | Partial autocorrelation function |
| Persistence | Độ dai dẳng của volatility shock |
| Residual | Phần model chưa giải thích được |
| RMSE | Root mean squared error |
| Rolling-origin CV | Cross-validation theo thời gian |
| SARIMA | Seasonal ARIMA |
| sGARCH | Standard symmetric GARCH |
| Sign bias | Kiểm tra bất đối xứng còn sót |
| Stationarity | Tính dừng |
| Student-t | Phân phối đuôi dày |
| Unit root | Dấu hiệu chuỗi level không dừng |
| Volatility clustering | Biến động lớn/nhỏ xuất hiện theo cụm |
| White noise | Chuỗi không còn autocorrelation có hệ thống |

## 17. Câu kết luận chuẩn

Câu kết luận nên dùng:

> Dự án cho thấy `close` và `log_close` của FPT không dừng, còn log return dừng và có ARCH effect. Với dự báo giá, ETS Damped đứng đầu holdout nhưng chưa vượt Naive ổn định khi xét rolling CV và residual diagnostics. Với volatility, eGARCH-Student-t là candidate cân bằng nhất vì AIC gần GJR-GARCH, core diagnostics đạt và Nyblom stability đạt, nhưng distribution GOF vẫn là hạn chế. Kết quả phục vụ học thuật, không phải khuyến nghị đầu tư.
