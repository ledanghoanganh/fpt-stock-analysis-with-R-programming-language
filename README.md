# 📈 Phân Tích & Dự Báo Cổ Phiếu FPT Bằng Mô Hình Chuỗi Thời Gian

> **Môn học:** Lập Trình R Cho Phân Tích  
> **Đề tài:** Dự báo giá và phân tích biến động cổ phiếu FPT bằng các mô hình chuỗi thời gian cơ bản và cải tiến  
> **Ngôn ngữ:** R | Python (thu thập dữ liệu)

---

## 1. Giới Thiệu

Dự án thực hiện phân tích toàn diện cổ phiếu **FPT** (sàn HOSE) bằng phương pháp chuỗi thời gian, bao gồm:

- **Thu thập dữ liệu** lịch sử giá cổ phiếu FPT bằng thư viện `vnstock` (Python/Colab)
- **Làm sạch & trực quan hóa** dữ liệu trong R
- **Kiểm định tính dừng** bằng ADF test, log transform và differencing
- **Dự báo giá** bằng các mô hình ARIMA, ETS và các phiên bản cải tiến
- **Phân tích biến động (volatility)** bằng GARCH và các phiên bản cải tiến
- **So sánh & đánh giá** toàn bộ mô hình, tổng hợp báo cáo Word

---

## 2. Dữ Liệu

| Thông tin | Chi tiết |
|---|---|
| Mã cổ phiếu | **FPT** |
| Sàn giao dịch | HOSE |
| Nguồn dữ liệu | Thư viện `vnstock` (Python) |
| Giai đoạn | 01/01/2015 — 08/06/2026 |
| Số quan sát | 2960 ngày giao dịch |
| Biến chính | `close` (giá đóng cửa), `log_close`, `return` (lợi suất log) |

### Các biến trong dữ liệu sạch (`fpt_clean.csv`)

| Cột | Kiểu | Ý nghĩa |
|---|---|---|
| `date` | Date | Ngày giao dịch |
| `open` | Numeric | Giá mở cửa |
| `high` | Numeric | Giá cao nhất trong ngày |
| `low` | Numeric | Giá thấp nhất trong ngày |
| `close` | Numeric | Giá đóng cửa |
| `volume` | Numeric | Khối lượng giao dịch |
| `log_close` | Numeric | ln(close) |
| `return` | Numeric | log_close(t) − log_close(t−1) |

---

## 3. Hệ Thống Mô Hình

Dự án sử dụng **8 mô hình** chia thành 2 nhóm: dự báo giá và phân tích volatility.

### 3.1. Nhóm Dự Báo Giá (ARIMA & ETS)

| # | Mô hình | Loại | Mô tả |
|---|---|---|---|
| 1 | **ARIMA(p,d,q)** | Base | Mô hình tự hồi quy tích hợp trung bình trượt. Kết quả: ARIMA(3,1,2) |
| 2 | **SARIMA(p,d,q)(P,D,Q)[5]** | Cải tiến | ARIMA mùa vụ — kiểm tra hiệu ứng chu kỳ tuần (m=5 ngày giao dịch/tuần) |
| 3 | **ARIMA + XREG** | Cải tiến | ARIMA với biến ngoại sinh (volume, daily_range) để tăng khả năng giải thích |
| 4 | **ETS(M,A,N)** | Base | San bằng mũ — Multiplicative Error, Additive Trend, No Seasonality |
| 5 | **ETS Damped (M,Ad,N)** | Cải tiến | ETS với xu hướng tắt dần — thực tế hơn cho dự báo dài hạn |

### 3.2. Nhóm Phân Tích Volatility (GARCH)

| # | Mô hình | Loại | Mô tả |
|---|---|---|---|
| 6 | **GARCH(1,1)** | Base | Mô hình phương sai có điều kiện — phân tích biến động theo thời gian |
| 7 | **eGARCH(1,1)** | Cải tiến | Exponential GARCH — nắm bắt leverage effect (tin xấu gây biến động mạnh hơn) |
| 8 | **GJR-GARCH(1,1)** | Cải tiến | Asymmetric GARCH — kiểm tra tác động bất đối xứng của cú sốc dương/âm |

### 3.3. Metrics Đánh Giá

| Metric | Áp dụng cho | Ý nghĩa |
|---|---|---|
| RMSE | ARIMA, ETS | Căn phương sai sai số trung bình — nhỏ hơn = tốt hơn |
| MAPE | ARIMA, ETS | Sai số phần trăm tuyệt đối trung bình — nhỏ hơn = tốt hơn |
| AIC / BIC | Tất cả mô hình | Tiêu chuẩn thông tin — nhỏ hơn = mô hình phù hợp hơn |

---

## 4. Kết Quả Sơ Bộ (Mô Hình Base)

### 4.1. Kiểm Định Tính Dừng (ADF Test)

| Chuỗi | ADF Statistic | p-value | Kết luận |
|---|---|---|---|
| Giá đóng cửa (`close`) | −1.73 | 0.6921 | Không dừng |
| Log giá đóng cửa (`log_close`) | −1.27 | 0.8893 | Không dừng |
| Lợi suất log (`return`) | −13.85 | < 0.01 | **Dừng** ✅ |

→ Chuỗi giá gốc chứa xu hướng ngẫu nhiên (random walk). Sau khi lấy sai phân bậc 1, chuỗi return dừng hoàn toàn.

### 4.2. Kết Quả Dự Báo (Tập Test = 30 Ngày Cuối)

| Mô hình | RMSE (VNĐ) | MAPE (%) |
|---|---|---|
| **ARIMA(3,1,2)** | **2016.99** | **2.19%** |
| ETS(M,A,N) | 2099.80 | 2.29% |

→ Cả hai mô hình base đều có MAPE < 5% (rất tốt). ARIMA(3,1,2) vượt trội hơn nhẹ.

### 4.3. Kết Quả GARCH & Mô Hình Cải Tiến

> ⏳ *Đang được hoàn thiện — sẽ cập nhật sau khi chạy xong toàn bộ mô hình cải tiến.*

---

## 5. Cấu Trúc Dự Án

```
fpt-stock-analysis-with-R-programming-language/
│
├── README.md                          ← File này
├── .gitignore
├── FPT_Stock_TimeSeries.Rproj
│
├── data/
│   ├── raw/
│   │   └── FPT_stock_data.csv         ← Dữ liệu gốc từ vnstock
│   ├── processed/
│   │   └── fpt_clean.csv              ← Dữ liệu sạch (đầu vào chính)
│   └── README_data.md
│
├── notebooks/
│   └── 01_scrape_fpt_colab.ipynb      ← Notebook thu thập dữ liệu
│
├── R/
│   ├── 00_config.R                    ← Cấu hình chung (thư viện, đường dẫn)
│   ├── 01_data_cleaning.R             ← Làm sạch dữ liệu
│   ├── 02_visualization.R             ← Trực quan hóa & thống kê mô tả
│   ├── 03_stationarity_arima_ets.R    ← Kiểm định dừng + ARIMA/ETS (+ cải tiến)
│   ├── 04_garch_volatility.R          ← GARCH + eGARCH + GJR-GARCH
│   ├── 05_model_comparison.R          ← So sánh tổng hợp mô hình
│   └── 06_export_report_tables.R      ← Xuất bảng/hình cho báo cáo
│
├── output/
│   ├── figures/                       ← Biểu đồ xuất ra (PNG, 300 DPI)
│   ├── tables/                        ← Bảng kết quả (CSV)
│   └── models/                        ← Mô hình đã train (RDS)
│
├── report/
│   ├── report.Rmd                     ← File nguồn báo cáo
│   ├── report.docx                    ← Báo cáo Word cuối cùng
│   └── sections/                      ← Các phần báo cáo riêng lẻ
│
└── docs/
    ├── guide.md                       ← Hướng dẫn chi tiết cho nhóm
    ├── README_old_task.md             ← README phân công phiên bản cũ
    ├── phan_cong_mo_hinh_cai_tien.md  ← Phân công mô hình cải tiến
    └── ly_thuyet_project.md           ← Tài liệu lý thuyết toàn bộ project
```

---

## 6. Phân Công Nhóm

| Thành viên | Vai trò | Công việc chính |
|---|---|---|
| **Người 1** | Data + Visualization | Thu thập, làm sạch, thống kê mô tả, trực quan hóa dữ liệu |
| **Người 2** | ARIMA + ETS | Kiểm định dừng, ARIMA, SARIMA, ARIMA+XREG, ETS, ETS Damped |
| **Người 3** | GARCH + Report | GARCH, eGARCH, GJR-GARCH, so sánh mô hình, tổng hợp báo cáo |

> Chi tiết phân công: xem [`docs/phan_cong_mo_hinh_cai_tien.md`](docs/phan_cong_mo_hinh_cai_tien.md)  
> Lý thuyết nền tảng: xem [`docs/ly_thuyet_project.md`](docs/ly_thuyet_project.md)

---

## 7. Cách Chạy Project

### 7.1. Yêu Cầu Môi Trường

- **R** ≥ 4.3.0 (khuyến nghị 4.6.0)
- **RStudio** hoặc VS Code + R extension
- **Python / Google Colab** (cho bước thu thập dữ liệu)

### 7.2. Cài Đặt Gói R

```r
install.packages(c(
  "tidyverse", "lubridate", "forecast", "tseries",
  "rugarch", "urca", "scales", "extrafont",
  "knitr", "rmarkdown"
))
```

### 7.3. Thứ Tự Chạy

```r
# Bước 1: Chạy notebook Python (notebooks/01_scrape_fpt_colab.ipynb)
# → Tạo data/raw/FPT_stock_data.csv

# Bước 2: Làm sạch dữ liệu
source("R/01_data_cleaning.R")

# Bước 3: Trực quan hóa
source("R/02_visualization.R")

# Bước 4: Mô hình ARIMA / ETS (base + cải tiến)
source("R/03_stationarity_arima_ets.R")

# Bước 5: Mô hình GARCH (base + cải tiến)
source("R/04_garch_volatility.R")

# Bước 6: So sánh mô hình
source("R/05_model_comparison.R")

# Bước 7: Xuất báo cáo
rmarkdown::render("report/report.Rmd", output_format = "word_document")
```

> ⚠️ **Lưu ý:** Phải chạy theo đúng thứ tự. Nếu thiếu `fpt_clean.csv` thì bước 4-7 sẽ lỗi.

---

## 8. Output Dự Kiến

### Biểu đồ (`output/figures/`)

| File | Nội dung |
|---|---|
| `close_price_professional.png` | Xu hướng giá đóng cửa FPT |
| `volume_professional.png` | Khối lượng giao dịch theo thời gian |
| `returns_professional.png` | Tỷ suất sinh lời hằng ngày |
| `arima_forecast.png` | Dự báo ARIMA vs thực tế |
| `ets_forecast.png` | Dự báo ETS vs thực tế |
| `sarima_forecast.png` | Dự báo SARIMA *(mới)* |
| `arima_xreg_forecast.png` | Dự báo ARIMA+XREG *(mới)* |
| `ets_damped_forecast.png` | Dự báo ETS Damped *(mới)* |
| `garch_volatility.png` | Conditional volatility GARCH |
| `egarch_volatility.png` | Conditional volatility eGARCH *(mới)* |
| `gjr_garch_volatility.png` | Conditional volatility GJR-GARCH *(mới)* |

### Bảng kết quả (`output/tables/`)

| File | Nội dung |
|---|---|
| `data_summary.csv` | Thống kê mô tả |
| `missing_values.csv` | Báo cáo giá trị thiếu |
| `stationarity_tests.csv` | Kết quả kiểm định ADF |
| `forecast_metrics.csv` | RMSE/MAPE cho tất cả mô hình dự báo |
| `model_aic_bic_comparison.csv` | So sánh AIC/BIC *(mới)* |
| `garch_summary.csv` | Tham số các mô hình GARCH |
| `garch_comparison.csv` | So sánh các biến thể GARCH *(mới)* |
| `model_comparison.csv` | Bảng tổng hợp toàn bộ mô hình |

---

## 9. Cấu Trúc Báo Cáo

1. Giới thiệu / Introduction
2. Dữ liệu / Data Description
3. Trực quan hóa / Data Visualization
4. Mô hình hóa ARIMA & ETS (base + cải tiến)
5. Mô hình hóa GARCH (base + cải tiến) & Results Discussion
6. Kết luận / Conclusion
7. Tài liệu tham khảo / References
8. Phụ lục / Appendices

---

## 10. Tài Liệu Tham Khảo

- Hyndman, R.J. & Athanasopoulos, G. (2021). *Forecasting: Principles and Practice*, 3rd ed.
- Tsay, R.S. (2010). *Analysis of Financial Time Series*, 3rd ed.
- Nelson, D.B. (1991). "Conditional Heteroskedasticity in Asset Returns". *Econometrica*.
- Glosten, L.R., Jagannathan, R. & Runkle, D.E. (1993). *Journal of Finance*.
- Package `forecast`: https://pkg.robjhyndman.com/forecast/
- Package `rugarch`: https://cran.r-project.org/web/packages/rugarch/
- Thư viện `vnstock`: https://github.com/thinh-vu/vnstock

---

## 11. Ghi Chú

- README phân công phiên bản cũ được lưu tại [`docs/README_old_task.md`](docs/README_old_task.md)
- Hướng dẫn thao tác chi tiết: [`docs/guide.md`](docs/guide.md)
- Tài liệu lý thuyết: [`docs/ly_thuyet_project.md`](docs/ly_thuyet_project.md)
- Phân công mô hình cải tiến: [`docs/phan_cong_mo_hinh_cai_tien.md`](docs/phan_cong_mo_hinh_cai_tien.md)
