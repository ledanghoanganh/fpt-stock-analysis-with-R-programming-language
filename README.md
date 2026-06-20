# Phân tích và dự báo cổ phiếu FPT bằng R

> **Môn học:** Lập trình R cho phân tích
>
> **Nhóm:** 06
>
> **Giảng viên:** TS. Phan Thị Thể
>
> **Bài toán:** Dự báo mức giá và phân tích conditional volatility của cổ phiếu FPT
>
> **Công nghệ chính:** R, R Markdown; Python/Google Colab cho bước thu thập dữ liệu

## Tổng quan

Dự án triển khai một quy trình phân tích chuỗi thời gian có thể tái lập:

1. Thu thập và kiểm tra dữ liệu OHLCV của FPT.
2. Làm sạch, tạo `log_close` và log return.
3. Trực quan hóa mức giá, volume và return.
4. Kiểm định tính dừng bằng ADF.
5. So sánh benchmark và các mô hình dự báo giá.
6. Kiểm tra ARCH effect và so sánh các biến thể GARCH.
7. Kiểm tra residual, stability, distribution fit và tổng hợp báo cáo Word.

Dự án tách hai câu hỏi khác nhau:

- **Dự báo mức giá:** đánh giá bằng RMSE, MAE, MAPE và rolling-origin cross-validation.
- **Mô hình hóa volatility:** đánh giá bằng convergence, likelihood, AIC/BIC, persistence và residual diagnostics.

Hai nhóm model không được xếp hạng chung vì chúng giải quyết hai response và dùng các metric khác nhau.

## Trạng thái hiện tại

Snapshot hiện tại đã có:

- Benchmark Naive và Drift.
- ARIMA, SARIMA, ARIMAX với biến trễ, ETS và ETS Damped.
- sGARCH-Normal, sGARCH-Student-t, eGARCH-Student-t và GJR-GARCH-Student-t.
- Holdout 30 phiên, rolling-origin CV cho nhóm model đã triển khai và forecast residual diagnostics.
- ARCH-LM, Ljung-Box, sign-bias, Nyblom stability và adjusted Pearson GOF cho GARCH.
- Hai bảng so sánh độc lập cho forecast-price và volatility.
- Báo cáo R Markdown đủ cấu trúc rubric và file Word đã render.

### Việc phải khóa trước bản nộp cuối

- Đối chiếu lại mọi số trong Word và slide với CSV mới nhất.
- Điền tên thật, mã sinh viên, contributions và peer assessment đã thống nhất.

Data handoff đã hoàn tất: notebook, raw CSV và tài liệu cùng dùng Yahoo Finance
(`FPT.VN`); 173 dòng `volume = 0` đã bị loại trước khi mô hình hóa.

## Dữ liệu

| Thuộc tính | Giá trị hiện tại |
|---|---|
| Mã cổ phiếu | FPT, HOSE |
| Khoảng thời gian | 2015-01-01 đến 2026-06-08 |
| Số quan sát dữ liệu thô | 2,960 dòng |
| Số quan sát dữ liệu sạch | 2,787 dòng |
| Số log return hợp lệ | 2,786 |
| File raw | `data/raw/FPT_stock_data.csv` |
| File model input | `data/processed/fpt_clean.csv` |

Tệp sạch hiện có các cột:

| Cột | Ý nghĩa |
|---|---|
| `date` | Ngày quan sát |
| `open`, `high`, `low`, `close` | Dữ liệu giá OHLC |
| `volume` | Khối lượng giao dịch |
| `log_close` | `log(close)` |
| `return` | `log(close_t) - log(close_(t-1))` |

### Lưu ý về provenance

Dữ liệu được tải từ Yahoo Finance bằng notebook tái lập tại
`notebooks/01_scrape_fpt_colab.ipynb` với `auto_adjust = TRUE`. Notebook xuất
đúng tên `FPT_stock_data.csv`; quy trình làm sạch và quality report được mô tả
trong [`data/README_data.md`](data/README_data.md).

## Hệ thống mô hình

### Dự báo giá

| Model | Vai trò |
|---|---|
| Naive | Random-walk benchmark |
| Drift | Random walk có độ trôi |
| ARIMA | Mô hình AR-I-MA tự động |
| SARIMA | Kiểm tra thành phần mùa vụ |
| ETS | Exponential smoothing state-space |
| ETS Damped | ETS với damped trend |
| ARIMAX (Lagged) | ARIMA với biến giải thích trễ |

Các model được đánh giá trên holdout 30 phiên. Rolling-origin CV hiện có cho Naive, Drift, ARIMA, ETS và ETS Damped; ARIMAX và SARIMA chưa có cùng coverage CV nên chưa thể tuyên bố một winner tuyệt đối.

### Conditional volatility

| Model | Distribution | Mục tiêu |
|---|---|---|
| sGARCH(1,1) | Normal | Baseline đối xứng |
| sGARCH(1,1) | Student-t | Kiểm tra heavy tails |
| eGARCH(1,1) | Student-t | Log variance và asymmetry |
| GJR-GARCH(1,1) | Student-t | Indicator cho shock âm |

Tất cả specification dùng cùng chuỗi return và mean equation ARMA(0,0).

## Kết quả sau data handoff

### ADF

| Chuỗi | ADF statistic | p-value | Kết luận ở mức 5% |
|---|---:|---:|---|
| `close` | -1.7892 | 0.6676 | Chưa đủ bằng chứng bác bỏ unit root |
| `log_close` | -1.3194 | 0.8665 | Chưa đủ bằng chứng bác bỏ unit root |
| `return` | -13.7914 | <= 0.01 | Bác bỏ unit root; return dừng |

### Forecast-price

- **Holdout leader:** ETS Damped, RMSE `1,939.13`, MAE `1,524.15`, MAPE `2.10%`.
- ETS Damped chỉ hơn Naive khoảng `0.72` RMSE trên holdout.
- **Rolling-CV leader:** Naive, mean RMSE `5,353.94`; ETS Damped đạt `5,404.76`.
- Tất cả fitted forecast models đều bị Ljung-Box bác bỏ white-noise residual ở mức 5%.
- ARIMAX và SARIMA chưa có rolling CV trong output hiện tại.

Kết luận: chưa có bằng chứng model phức tạp cải thiện Naive một cách ổn định.

Xem [`output/tables/price_forecast_comparison.csv`](output/tables/price_forecast_comparison.csv).

### Volatility

| Model | AIC | Persistence | Core diagnostics | Nyblom joint 5% |
|---|---:|---:|---|---|
| GJR-GARCH Student-t | -5.634427 | 0.985742 | Đạt | Không đạt |
| eGARCH Student-t | -5.633058 | 0.962670 | Đạt | Đạt |
| sGARCH Student-t | -5.631732 | 0.989137 | Đạt | Không đạt |
| sGARCH Normal | -5.507300 | 0.964510 | Đạt | Không đạt |

eGARCH-Student-t là **ứng viên cân bằng** vì AIC chỉ kém GJR khoảng `0.00137`,
core residual diagnostics đạt và Nyblom joint stability đạt. Adjusted Pearson
GOF vẫn bác bỏ distribution fit cho tất cả model, nên lựa chọn này phải được
trình bày cùng hạn chế phân phối.

Xem [`output/tables/volatility_model_comparison.csv`](output/tables/volatility_model_comparison.csv).

## Cấu trúc repository

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
│   └── 06_export_report_tables.R
├── output/
│   ├── figures/
│   ├── models/
│   └── tables/
├── report/
│   ├── report.Rmd
│   ├── report.docx
│   └── sections/                 # Bản chương tham khảo; report.Rmd đã tích hợp đầy đủ
└── docs/
    ├── guide.md
    ├── guide_nguoi_1.md
    ├── ke_hoach_nguoi_2_3_hom_nay.md
    ├── ly_thuyet_project.md
    ├── phan_cong_mo_hinh_cai_tien.md
    └── rubric/
```

`local_docs/` được `.gitignore` và chỉ dùng cho ghi chú/script học tập cá nhân.

## Cài đặt

Khuyến nghị dùng R 4.6.0 và RStudio trên Windows 11. Cài dependency một lần trong R Console:

```r
install.packages(c(
  "tidyverse",
  "lubridate",
  "forecast",
  "tseries",
  "urca",
  "FinTS",
  "rugarch",
  "scales",
  "knitr",
  "rmarkdown",
  "openxlsx"
))
```

Nên cài dependency trước khi chạy. `R/06_export_report_tables.R` hiện vẫn có fallback cài `openxlsx` nếu thiếu; các module còn lại sẽ dừng và báo package cần bổ sung.

## Cách chạy

Mở `FPT_Stock_TimeSeries.Rproj`, bảo đảm working directory là thư mục gốc rồi chạy:

```r
source("R/01_data_cleaning.R")
source("R/02_visualization.R")
source("R/03_stationarity_arima_ets.R")
source("R/04_garch_volatility.R")
source("R/05_model_comparison.R")
source("R/06_export_report_tables.R")
```

Render báo cáo:

```r
rmarkdown::render(
  "report/report.Rmd",
  output_file = "report.docx",
  knit_root_dir = normalizePath(".")
)
```

Báo cáo chỉ đọc CSV/PNG đã sinh, không chạy lại model trong lúc knit.

## Output chính

### Forecast

| Output | Nội dung |
|---|---|
| `forecast_metrics.csv` | Holdout RMSE/MAE/MAPE |
| `forecast_cv_metrics_raw.csv` | Metric theo từng rolling fold |
| `forecast_cv_metrics_summary.csv` | Tổng hợp rolling CV |
| `forecast_diagnostics.csv` | Ljung-Box forecast residuals |
| `price_forecast_comparison.csv` | Holdout + CV + diagnostics |
| `*_forecast.png` | Dự báo từng model |
| `*_residual_diagnostics.png` | Residual diagnostics từng model |

### GARCH

| Output | Nội dung |
|---|---|
| `garch_parameters.csv` | Estimate và robust standard error |
| `garch_comparison.csv` | Likelihood, AIC/BIC, persistence |
| `garch_diagnostics.csv` | Bảng dài toàn bộ diagnostic tests |
| `garch_diagnostic_summary.csv` | Tóm tắt diagnostics theo model |
| `volatility_model_comparison.csv` | Fit + diagnostics + provisional rule |
| `garch_model_comparison.png` | Conditional volatility của bốn model |
| `garch_acf_diagnostics.png` | ACF standardized residuals |
| `garch_qq_diagnostics.png` | Normal-reference QQ plots |
| `garch_news_impact.png` | News-impact curves của model bất đối xứng |

### Báo cáo

- [`report/report.Rmd`](report/report.Rmd): nguồn báo cáo tái lập, đủ 11 phần rubric.
- [`report/report.docx`](report/report.docx): Word đã render và nhúng bảng/hình.
- `output/tables/report_tables.xlsx`: workbook hỗ trợ kiểm tra bảng.
- [`presentation/khung_noi_dung_slide.docx`](presentation/khung_noi_dung_slide.docx): khung nội dung để nhóm hoàn thiện PowerPoint.

## Phân công

| Thành viên | Tỷ lệ | Phạm vi |
|---|---:|---|
| Trần Thiên Lực - 24133037 | 30% | Data provenance, cleaning, quality checks và visualization |
| Nguyễn Đức Học - 24162039 | 35% | Forecast framework, benchmark, rolling CV và residual diagnostics |
| Lê Đặng Hoàng Anh - 24162006 | 35% | GARCH variants, diagnostics, model comparison, báo cáo và khung slide |

Chi tiết đóng góp và peer assessment được trình bày trong báo cáo.

## Tài liệu dự án

- [Tài liệu tổng hợp toàn bộ dự án](docs/MASTER_DOCUMENTATION.md)
- [Rubric và yêu cầu](docs/rubric/)
- [Lý thuyết nền tảng](docs/ly_thuyet_project.md)
- [Phân công mô hình cải tiến](docs/phan_cong_mo_hinh_cai_tien.md)

## Giới hạn sử dụng

Đây là đồ án học thuật. Kết quả dự báo và volatility không phải khuyến nghị mua,
bán, định giá hay quản trị rủi ro thực tế. Mọi kết luận cuối phải được kiểm tra
chéo với các CSV trong `output/tables`.