# Dự báo giá và phân tích biến động cổ phiếu FPT bằng mô hình chuỗi thời gian

> **Môn học:** Lập trình R cho phân tích
>
> **Nhóm:** 06
>
> **Giảng viên:** TS. Phan Thị Thể
>
> **Đề tài:** Phân tích chuỗi thời gian, dự báo giá và mô hình hóa biến động của cổ phiếu FPT

## 1. Giới thiệu

Dự án xây dựng một pipeline phân tích chuỗi thời gian bằng R cho cổ phiếu FPT. Dữ liệu được thu thập từ Yahoo Finance với ticker `FPT.VN`, sau đó được làm sạch, trực quan hóa, kiểm định tính dừng, mô hình hóa giá và mô hình hóa biến động lợi suất.

Dự án tách rõ hai bài toán:

1. **Dự báo giá đóng cửa:** so sánh Naive, Drift, ARIMA, SARIMA, ETS, ETS Damped và ARIMAX.
2. **Mô hình hóa conditional volatility:** so sánh sGARCH-Normal, sGARCH-Student-t, eGARCH-Student-t và GJR-GARCH-Student-t.

Kết quả chỉ phục vụ mục tiêu học thuật, không phải khuyến nghị đầu tư.

## 2. Thành viên

| Thành viên | MSSV | Tỷ lệ đóng góp | Phạm vi chính |
|---|---:|---:|---|
| Trần Thiên Lực | 24133037 | 30% | Thu thập dữ liệu, làm sạch, kiểm tra chất lượng, EDA |
| Nguyễn Đức Học | 24162039 | 35% | ADF, forecast models, rolling-origin CV, residual diagnostics |
| Lê Đặng Hoàng Anh | 24162006 | 35% | GARCH models, diagnostics, model comparison, tích hợp báo cáo |

## 3. Dữ liệu

| Thuộc tính | Giá trị |
|---|---|
| Mã cổ phiếu | `FPT.VN` |
| Nguồn | Yahoo Finance |
| Giai đoạn raw | 2015-01-01 đến 2026-06-08 |
| Số dòng raw | 2,960 |
| Số dòng clean | 2,787 |
| Số log return hợp lệ | 2,786 |
| File raw | `data/raw/FPT_stock_data.csv` |
| File clean | `data/processed/fpt_clean.csv` |

Quy trình cleaning loại 173 dòng `volume = 0`, kiểm tra missing value, duplicate date, non-positive price, negative volume và sửa 1 dòng OHLC bất thường sau khi lọc volume.

Các biến chính trong dữ liệu sạch:

| Cột | Ý nghĩa |
|---|---|
| `date` | Ngày giao dịch |
| `open`, `high`, `low`, `close` | Giá OHLC |
| `volume` | Khối lượng giao dịch |
| `log_close` | Logarit tự nhiên của giá đóng cửa |
| `return` | Log return: `log(close_t) - log(close_(t-1))` |

## 4. Pipeline

```text
data/raw/FPT_stock_data.csv
        |
        v
R/01_data_cleaning.R
        |
        v
data/processed/fpt_clean.csv
        |
        +--> R/02_visualization.R
        +--> R/03_stationarity_arima_ets.R
        +--> R/04_garch_volatility.R
        |
        v
R/05_model_comparison.R
        |
        v
R/06_export_report_tables.R
        |
        v
report/report.Rmd -> report/report.docx
```

Entry point chạy toàn bộ:

```r
source("R/run_all.R")
```

Pipeline cuối đã chạy thành công lúc `2026-06-23 11:43:26`; xem `output/pipeline_log.txt`.

## 5. Mô hình sử dụng

### 5.1 Dự báo giá

| Model | Vai trò |
|---|---|
| Naive | Benchmark random walk |
| Drift | Random walk có drift |
| ARIMA | Mô hình ARIMA tự động |
| SARIMA | ARIMA có yếu tố mùa vụ |
| ETS | Exponential smoothing |
| ETS Damped | ETS với damped trend |
| ARIMAX | ARIMA với biến giải thích trễ |

Đánh giá forecast dùng holdout 30 phiên cuối và rolling-origin cross-validation cho nhóm model có cùng coverage.

### 5.2 Conditional volatility

| Model | Distribution | Mục tiêu |
|---|---|---|
| sGARCH(1,1) | Normal | Baseline đối xứng |
| sGARCH(1,1) | Student-t | Kiểm tra heavy tails |
| eGARCH(1,1) | Student-t | Kiểm tra asymmetry qua log variance |
| GJR-GARCH(1,1) | Student-t | Kiểm tra tác động khác nhau của shock âm |

Tất cả GARCH models dùng cùng chuỗi log return và mean equation ARMA(0,0).

## 6. Kết quả chính

### 6.1 Kiểm định ADF

| Chuỗi | ADF statistic | p-value | Kết luận |
|---|---:|---:|---|
| Close | -1.7892 | 0.6676 | Không dừng |
| Log close | -1.3194 | 0.8665 | Không dừng |
| Log return | -13.7914 | 0.0100 | Dừng |

Kết quả này giải thích vì sao phần GARCH dùng `return`, không dùng trực tiếp `close`.

### 6.2 Dự báo giá

| Model | Holdout RMSE | Holdout MAPE | CV mean RMSE |
|---|---:|---:|---:|
| ETS Damped | 1,939.13 | 2.10% | 5,404.76 |
| Naive | 1,939.85 | 2.11% | 5,353.94 |
| SARIMA | 1,982.52 | 2.19% | NA |
| ETS | 1,987.03 | 2.08% | 5,477.37 |
| Drift | 2,021.03 | 2.23% | 5,396.80 |
| ARIMAX | 2,025.75 | 2.24% | NA |
| ARIMA | 2,119.64 | 2.38% | 6,501.47 |

ETS Damped đứng đầu holdout nhưng chỉ hơn Naive khoảng 0.72 RMSE. Trong rolling-origin CV, Naive tốt nhất trong nhóm được đánh giá đầy đủ. Vì vậy dự án không tuyên bố một model phức tạp thắng ổn định trong bài toán dự báo giá.

### 6.3 Volatility

| Model | AIC | Persistence | Core diagnostics | Stability |
|---|---:|---:|---|---|
| GJR-GARCH Student-t | -5.6344 | 0.9857 | Đạt | Không đạt |
| eGARCH Student-t | -5.6331 | 0.9627 | Đạt | Đạt |
| sGARCH Student-t | -5.6317 | 0.9891 | Đạt | Không đạt |
| sGARCH Normal | -5.5073 | 0.9645 | Đạt | Không đạt |

GJR-GARCH có AIC thấp nhất nhưng không đạt Nyblom stability. eGARCH-Student-t có AIC gần GJR, core diagnostics đạt và parameter stability đạt, nên được chọn là candidate cân bằng nhất. Adjusted Pearson GOF vẫn bác bỏ distribution fit cho tất cả GARCH models, đây là hạn chế cần nêu rõ.

## 7. Output cần xem

### Báo cáo

| File | Nội dung |
|---|---|
| `report/report.Rmd` | Source báo cáo tái lập |
| `report/report.docx` | Báo cáo Word đã render |
| `output/pipeline_log.txt` | Log chạy pipeline |

### Tables

| File | Nội dung |
|---|---|
| `output/tables/data_quality_report.csv` | Kiểm tra chất lượng dữ liệu |
| `output/tables/data_summary.csv` | Thống kê mô tả |
| `output/tables/stationarity_tests.csv` | Kết quả ADF |
| `output/tables/forecast_metrics.csv` | Metric holdout |
| `output/tables/forecast_cv_metrics_summary.csv` | Tổng hợp rolling CV |
| `output/tables/forecast_diagnostics.csv` | Ljung-Box forecast residuals |
| `output/tables/price_forecast_comparison.csv` | So sánh forecast tổng hợp |
| `output/tables/garch_comparison.csv` | So sánh GARCH theo likelihood, AIC/BIC, persistence |
| `output/tables/garch_parameters.csv` | Tham số và robust standard error |
| `output/tables/garch_diagnostic_summary.csv` | Tóm tắt diagnostics GARCH |
| `output/tables/volatility_model_comparison.csv` | Quy tắc chọn volatility model |
| `output/tables/report_tables.xlsx` | Workbook tổng hợp bảng |

### Figures

| File | Nội dung |
|---|---|
| `output/figures/close_price.png` | Giá đóng cửa FPT |
| `output/figures/volume.png` | Khối lượng giao dịch |
| `output/figures/returns.png` | Log return |
| `output/figures/squared_returns.png` | Squared return và volatility clustering |
| `output/figures/return_distribution.png` | Phân phối log return |
| `output/figures/qqplot_return.png` | Q-Q plot của log return |
| `output/figures/acf_return.png` | ACF return |
| `output/figures/pacf_return.png` | PACF return |
| `output/figures/ets_damped_forecast.png` | Forecast ETS Damped |
| `output/figures/ets_damped_residual_diagnostics.png` | Diagnostics của ETS Damped |
| `output/figures/garch_model_comparison.png` | Conditional volatility của 4 GARCH models |
| `output/figures/garch_acf_diagnostics.png` | ACF diagnostics cho standardized residuals |
| `output/figures/garch_news_impact.png` | News-impact curves |

### Models

| File | Nội dung |
|---|---|
| `output/models/arima_model.rds` | Fitted ARIMA |
| `output/models/sarima_model.rds` | Fitted SARIMA |
| `output/models/ets_model.rds` | Fitted ETS |
| `output/models/ets_damped_model.rds` | Fitted ETS Damped |
| `output/models/arima_xreg_model.rds` | Fitted ARIMAX |
| `output/models/garch_model.rds` | Baseline sGARCH-Normal |
| `output/models/garch_candidate_model.rds` | Candidate eGARCH-Student-t |
| `output/models/garch_fits.rds` | Named list chứa 4 fitted GARCH models |

Ví dụ load model:

```r
model <- readRDS("output/models/ets_damped_model.rds")
forecast::forecast(model, h = 10)
```

## 8. Cấu trúc thư mục

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
│   └── tables/
├── report/
│   ├── report.Rmd
│   ├── report.docx
│   └── sections/
├── presentation/
└── docs/
    └── MASTER_DOCUMENTATION.md
```

## 9. Cách chạy

Khuyến nghị dùng R 4.6.0 và RStudio.

Cài package:

```r
install.packages(c(
  "tidyverse", "lubridate", "forecast", "tseries", "urca",
  "FinTS", "rugarch", "scales", "knitr", "rmarkdown", "openxlsx"
))
```

Chạy toàn bộ pipeline:

```r
source("R/run_all.R")
```

Render riêng báo cáo:

```r
rmarkdown::render(
  "report/report.Rmd",
  output_file = "report.docx",
  knit_root_dir = normalizePath(".")
)
```

## 10. Hạn chế

- Dữ liệu chỉ gồm một ticker `FPT.VN`.
- Chưa đưa VN-Index, tin tức, biến vĩ mô hoặc dữ liệu intraday vào mô hình.
- Holdout forecast chỉ gồm 30 phiên cuối.
- SARIMA và ARIMAX chưa có rolling CV cùng coverage với toàn bộ nhóm model.
- Forecast residual diagnostics chưa ủng hộ kết luận model phức tạp thắng ổn định.
- GARCH chưa có out-of-sample volatility loss, QLIKE hoặc VaR backtest.
- Adjusted Pearson GOF vẫn bác bỏ distribution fit của tất cả GARCH specifications.

## 11. Kết luận ngắn

Dự án cho thấy log return của FPT có tính dừng và có ARCH effect rõ, phù hợp để mô hình hóa conditional volatility. Với bài toán forecast giá, ETS Damped đứng đầu holdout nhưng chưa vượt Naive một cách ổn định khi xét rolling CV và residual diagnostics. Với volatility, eGARCH-Student-t là lựa chọn cân bằng nhất trong các specification đã thử, nhưng kết quả vẫn cần được trình bày cùng hạn chế về distribution fit và thiếu đánh giá volatility ngoài mẫu.
