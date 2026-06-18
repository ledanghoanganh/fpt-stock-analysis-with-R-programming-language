# Phân Công Nhiệm Vụ: Nâng Cấp Mô Hình Cải Tiến

> **Mục tiêu:** Áp dụng các phiên bản **mô hình cải tiến** cho ARIMA, ETS và GARCH theo yêu cầu giảng viên  
> **Nguyên tắc:** Giữ nguyên mô hình gốc (base model) đã chạy, BỔ SUNG thêm mô hình cải tiến để so sánh  
> **Ngày tạo:** 18/06/2026

---

## Tổng Quan: Hiện Trạng Và Hướng Cải Tiến

### Hiện trạng project đã hoàn thành

| Mô hình | Phiên bản hiện tại | Trạng thái | Người phụ trách |
|---|---|---|---|
| ARIMA | ARIMA(3,1,2) - tự động bởi `auto.arima` | ✅ Xong | Người 2 |
| ETS | ETS(M,A,N) - tự động bởi `ets()` | ✅ Xong | Người 2 |
| GARCH | Chưa code (file trống) | ❌ Chưa làm | Người 3 |

### Các mô hình cải tiến cần bổ sung

| Mô hình gốc | Mô hình cải tiến đề xuất | Lý do áp dụng | Người phụ trách |
|---|---|---|---|
| ARIMA(3,1,2) | **SARIMA** (Seasonal ARIMA) | Kiểm tra/khai thác tính mùa vụ nếu có (ví dụ: hiệu ứng ngày trong tuần) | Người 2 |
| ARIMA(3,1,2) | **ARIMA + XREG** (ARIMA với biến ngoại sinh) | Thêm biến volume, lag return làm biến ngoại sinh để tăng khả năng giải thích | Người 2 |
| ETS(M,A,N) | **ETS với damped trend** (ETS(M,Ad,N)) | Xu hướng tắt dần - thực tế hơn vì giá cổ phiếu không tăng mãi theo đường thẳng | Người 2 |
| GARCH(1,1) | **eGARCH** (Exponential GARCH) | Nắm bắt hiệu ứng đòn bẩy (leverage effect): tin xấu tác động mạnh hơn tin tốt | Người 3 |
| GARCH(1,1) | **GJR-GARCH** (Glosten-Jagannathan-Runkle) | Phiên bản cải tiến khác để kiểm tra asymmetric volatility | Người 3 |
| *(Bonus)* | **ARIMA-GARCH kết hợp** | Kết hợp ARIMA cho mean equation + GARCH cho variance equation | Người 2 + Người 3 |

---

## Phân Công Chi Tiết Theo Từng Người

---

## 👤 Người 1 — Data + Visualization (Bổ sung)

**Tỉ trọng bổ sung:** ~10% (hỗ trợ)

Người 1 đã hoàn thành phần chính. Nhiệm vụ bổ sung khi áp dụng mô hình cải tiến:

### Công việc cần làm

1. **Bổ sung biểu đồ ACF/PACF** cho chuỗi return (hỗ trợ Người 2 chọn bậc SARIMA)
2. **Bổ sung biểu đồ phân phối return** chi tiết hơn (histogram + QQ-plot) để hỗ trợ đánh giá phân phối chuẩn/lệch chuẩn → liên quan đến lựa chọn distribution trong GARCH
3. **Bổ sung biểu đồ boxplot return theo ngày trong tuần** (Monday, Tuesday, ...) để kiểm tra tính mùa vụ tuần

### Checklist Người 1 (Bổ sung)

- [ ] Đã vẽ biểu đồ ACF/PACF cho chuỗi return
- [ ] Đã vẽ QQ-plot cho chuỗi return
- [ ] Đã vẽ boxplot return theo ngày trong tuần
- [ ] Đã lưu các biểu đồ mới vào `output/figures/`

### File và Output bổ sung

| File | Output |
|---|---|
| `R/02_visualization.R` (cập nhật) | `output/figures/acf_pacf_return.png` |
| | `output/figures/qqplot_return.png` |
| | `output/figures/return_by_weekday.png` |

---

## 👤 Người 2 — Mô Hình ARIMA/ETS Cải Tiến (Trọng tâm chính)

**Tỉ trọng bổ sung:** ~40% (phần nặng nhất)

### Công việc cần làm — CHI TIẾT

#### A. SARIMA (Seasonal ARIMA) — Mô hình cải tiến #1

**Ý tưởng:** Mở rộng ARIMA(p,d,q) thành SARIMA(p,d,q)(P,D,Q)[m] để kiểm tra xem có tính mùa vụ (weekly seasonality) với chu kỳ m=5 (5 ngày giao dịch/tuần) không.

**Các bước cần thực hiện:**

1. Tạo đối tượng time series với `frequency = 5`:
   ```r
   train_ts_seasonal <- ts(train_data$close, frequency = 5)
   ```

2. Chạy `auto.arima` với `seasonal = TRUE`:
   ```r
   fit_sarima <- auto.arima(train_ts_seasonal, 
                            seasonal = TRUE, 
                            stepwise = FALSE, 
                            approximation = FALSE)
   ```

3. Dự báo h = 30 bước, tính RMSE/MAPE
4. Vẽ biểu đồ forecast SARIMA tương tự biểu đồ ARIMA hiện tại
5. Lưu model vào `output/models/sarima_model.rds`

---

#### B. ARIMA + XREG (Biến ngoại sinh) — Mô hình cải tiến #2

**Ý tưởng:** Thêm biến ngoại sinh (exogenous variables) vào mô hình ARIMA để tăng khả năng giải thích. Các biến ngoại sinh hợp lý cho cổ phiếu:
- `volume` (khối lượng giao dịch)
- `daily_range` = `high - low` (biên độ dao động trong ngày)

**Các bước cần thực hiện:**

1. Tạo ma trận biến ngoại sinh cho tập train và test:
   ```r
   # Chuẩn bị biến ngoại sinh
   df$daily_range <- df$high - df$low
   
   xreg_train <- cbind(
     volume = train_data$volume,
     daily_range = train_data$daily_range
   )
   
   xreg_test <- cbind(
     volume = test_data$volume,
     daily_range = test_data$daily_range
   )
   ```

2. Chạy ARIMA với xreg:
   ```r
   fit_arima_xreg <- auto.arima(train_ts, 
                                 xreg = xreg_train,
                                 stepwise = FALSE, 
                                 approximation = FALSE)
   ```

3. Dự báo:
   ```r
   fc_arima_xreg <- forecast(fit_arima_xreg, h = n_test, xreg = xreg_test)
   ```

4. Tính RMSE/MAPE, vẽ biểu đồ, lưu model

---

#### C. ETS với Damped Trend — Mô hình cải tiến #3

**Ý tưởng:** Ép ETS dùng xu hướng tắt dần (damped trend) thay vì xu hướng tuyến tính thuần. Xu hướng tắt dần thực tế hơn vì dự báo dài hạn không nên ngoại suy đường thẳng mãi.

**Các bước cần thực hiện:**

1. Xây dựng mô hình ETS damped:
   ```r
   fit_ets_damped <- ets(train_ts, damped = TRUE)
   ```

2. Dự báo, tính RMSE/MAPE
3. So sánh AIC/BIC giữa ETS gốc và ETS damped
4. Vẽ biểu đồ và lưu model

---

#### D. Tổng hợp bảng so sánh mô hình cải tiến

Sau khi chạy xong tất cả, tạo bảng tổng hợp:

```
model,rmse,mape,aic,bic,type
ARIMA(3,1,2),2016.99,2.19,48308.69,48344.58,Base
SARIMA(...),xxx,xxx,xxx,xxx,Improved
ARIMA+XREG(...),xxx,xxx,xxx,xxx,Improved
ETS(M,A,N),2099.80,2.29,59067.73,59097.64,Base
ETS(M,Ad,N),xxx,xxx,xxx,xxx,Improved
```

---

### Checklist Người 2

#### Phần giữ nguyên (đã xong ✅)
- [x] ARIMA(3,1,2) base model
- [x] ETS(M,A,N) base model
- [x] Kiểm định ADF
- [x] Bảng forecast_metrics.csv (ARIMA, ETS base)
- [x] Biểu đồ forecast ARIMA và ETS
- [x] Viết report section 04

#### Phần MỚI — Mô hình cải tiến (cần làm)
- [ ] **SARIMA:** Tạo time series với frequency=5
- [ ] **SARIMA:** Chạy auto.arima với seasonal=TRUE
- [ ] **SARIMA:** Dự báo h=30 và tính RMSE/MAPE
- [ ] **SARIMA:** Vẽ biểu đồ forecast SARIMA
- [ ] **SARIMA:** Lưu model vào `output/models/sarima_model.rds`
- [ ] **ARIMA+XREG:** Chuẩn bị biến ngoại sinh (volume, daily_range)
- [ ] **ARIMA+XREG:** Chạy auto.arima với xreg
- [ ] **ARIMA+XREG:** Dự báo và tính RMSE/MAPE
- [ ] **ARIMA+XREG:** Vẽ biểu đồ forecast
- [ ] **ARIMA+XREG:** Lưu model vào `output/models/arima_xreg_model.rds`
- [ ] **ETS Damped:** Chạy ets() với damped=TRUE
- [ ] **ETS Damped:** Dự báo và tính RMSE/MAPE
- [ ] **ETS Damped:** So sánh AIC/BIC với ETS gốc
- [ ] **ETS Damped:** Vẽ biểu đồ forecast
- [ ] **ETS Damped:** Lưu model vào `output/models/ets_damped_model.rds`
- [ ] **Tổng hợp:** Cập nhật `forecast_metrics.csv` với tất cả 5 mô hình
- [ ] **Tổng hợp:** Tạo bảng so sánh AIC/BIC cho tất cả mô hình
- [ ] **Báo cáo:** Cập nhật `report/sections/04_modeling_arima_ets.md` thêm phần mô hình cải tiến

### File và Output mới của Người 2

| File cần sửa/tạo | Output mới |
|---|---|
| `R/03_stationarity_arima_ets.R` (cập nhật) | `output/models/sarima_model.rds` |
| | `output/models/arima_xreg_model.rds` |
| | `output/models/ets_damped_model.rds` |
| | `output/figures/sarima_forecast.png` |
| | `output/figures/arima_xreg_forecast.png` |
| | `output/figures/ets_damped_forecast.png` |
| | `output/tables/forecast_metrics.csv` (cập nhật) |
| | `output/tables/model_aic_bic_comparison.csv` |
| `report/sections/04_modeling_arima_ets.md` (cập nhật) | Bổ sung mục 4.4, 4.5, 4.6 |

---

## 👤 Người 3 — GARCH Cải Tiến + Tổng Hợp Báo Cáo

**Tỉ trọng bổ sung:** ~40%

### Công việc cần làm — CHI TIẾT

#### A. GARCH(1,1) Base — Hoàn thành phần gốc (CHƯA CODE)

**LƯU Ý:** File `R/04_garch_volatility.R` hiện tại TRỐNG. Người 3 cần code phần base GARCH(1,1) trước.

**Các bước cơ bản:**

1. Đọc dữ liệu, lấy chuỗi return (bỏ NA):
   ```r
   library(rugarch)
   source("R/00_config.R")
   df <- read.csv(CLEAN_DATA_PATH)
   returns <- na.omit(df$return)
   ```

2. Định nghĩa và fit GARCH(1,1):
   ```r
   spec_garch <- ugarchspec(
     variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
     mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
     distribution.model = "norm"
   )
   fit_garch <- ugarchfit(spec_garch, data = returns)
   ```

3. Xuất kết quả, vẽ biểu đồ volatility, lưu model

---

#### B. eGARCH (Exponential GARCH) — Mô hình cải tiến #1

**Ý tưởng:** eGARCH mô hình hóa log(variance) thay vì variance trực tiếp, cho phép nắm bắt **hiệu ứng đòn bẩy** (leverage effect) — tức là tin xấu (negative shock) thường gây ra volatility lớn hơn tin tốt (positive shock) cùng biên độ.

**Các bước:**

```r
spec_egarch <- ugarchspec(
  variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)
fit_egarch <- ugarchfit(spec_egarch, data = returns)
```

- Kiểm tra tham số gamma (leverage): nếu gamma < 0 và có ý nghĩa thống kê → có leverage effect
- Vẽ biểu đồ conditional volatility của eGARCH

---

#### C. GJR-GARCH — Mô hình cải tiến #2

**Ý tưởng:** GJR-GARCH thêm biến chỉ thị (indicator) cho các cú sốc âm, cho phép hệ số phản ứng khác nhau với cú sốc dương và âm.

**Các bước:**

```r
spec_gjr <- ugarchspec(
  variance.model = list(model = "gjrGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)
fit_gjr <- ugarchfit(spec_gjr, data = returns)
```

- Kiểm tra tham số gamma1: nếu gamma1 > 0 và có ý nghĩa → tin xấu gây biến động mạnh hơn

---

#### D. So sánh các mô hình GARCH

Tạo bảng so sánh:

| Mô hình | AIC | BIC | Log-Likelihood | Persistence (α+β) | Leverage Effect |
|---|---|---|---|---|---|
| sGARCH(1,1) | ... | ... | ... | ... | Không |
| eGARCH(1,1) | ... | ... | ... | ... | Có/Không |
| GJR-GARCH(1,1) | ... | ... | ... | ... | Có/Không |

---

#### E. Thử phân phối Student-t

Cổ phiếu thường có phân phối đuôi dày (fat tails). Thử thay `distribution.model = "std"` (Student-t) thay vì `"norm"`:

```r
spec_garch_t <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"  # Student-t distribution
)
fit_garch_t <- ugarchfit(spec_garch_t, data = returns)
```

So sánh AIC/BIC của GARCH(1,1) với phân phối norm vs Student-t.

---

### Checklist Người 3

#### Phần base (CHƯA LÀM — cần hoàn thành trước)
- [ ] Code `R/04_garch_volatility.R` — GARCH(1,1) base
- [ ] Xuất `output/tables/garch_summary.csv`
- [ ] Xuất `output/figures/garch_volatility.png`
- [ ] Lưu `output/models/garch_model.rds`

#### Phần MỚI — Mô hình cải tiến
- [ ] **eGARCH:** Code mô hình eGARCH(1,1)
- [ ] **eGARCH:** Kiểm tra leverage effect (gamma)
- [ ] **eGARCH:** Vẽ biểu đồ volatility eGARCH
- [ ] **eGARCH:** Lưu model vào `output/models/egarch_model.rds`
- [ ] **GJR-GARCH:** Code mô hình GJR-GARCH(1,1)
- [ ] **GJR-GARCH:** Kiểm tra tham số gamma1
- [ ] **GJR-GARCH:** Vẽ biểu đồ volatility GJR
- [ ] **GJR-GARCH:** Lưu model vào `output/models/gjr_garch_model.rds`
- [ ] **Student-t:** Chạy lại GARCH(1,1) với distribution = "std"
- [ ] **Student-t:** So sánh AIC/BIC giữa norm và Student-t
- [ ] **So sánh:** Tạo bảng so sánh tất cả mô hình GARCH
- [ ] **So sánh:** Xuất `output/tables/garch_comparison.csv`
- [ ] **Tổng hợp:** Cập nhật `output/tables/model_comparison.csv` (tất cả mô hình base + cải tiến)
- [ ] **Báo cáo:** Cập nhật `report/sections/05_garch_results_discussion.md`
- [ ] **Báo cáo:** Cập nhật `report/sections/06_conclusion.md`
- [ ] **Báo cáo:** Ghép và knit `report/report.docx`

### File và Output mới của Người 3

| File cần sửa/tạo | Output mới |
|---|---|
| `R/04_garch_volatility.R` (code mới) | `output/models/garch_model.rds` |
| | `output/models/egarch_model.rds` |
| | `output/models/gjr_garch_model.rds` |
| | `output/figures/garch_volatility.png` |
| | `output/figures/egarch_volatility.png` |
| | `output/figures/gjr_garch_volatility.png` |
| | `output/tables/garch_summary.csv` |
| | `output/tables/garch_comparison.csv` |
| `R/05_model_comparison.R` (code mới) | `output/tables/model_comparison.csv` (cập nhật) |
| `report/sections/05_garch_results_discussion.md` | Bổ sung eGARCH, GJR |
| `report/sections/06_conclusion.md` | Cập nhật kết luận |

---

## Tổng Kết Mô Hình

### Bảng tổng hợp tất cả mô hình (base + cải tiến)

| # | Mô hình | Loại | Mục đích | Người làm |
|---|---|---|---|---|
| 1 | ARIMA(3,1,2) | Base | Dự báo giá | Người 2 ✅ |
| 2 | SARIMA(p,d,q)(P,D,Q)[5] | Cải tiến | Dự báo giá (có mùa vụ) | Người 2 |
| 3 | ARIMA + XREG | Cải tiến | Dự báo giá (có biến ngoại sinh) | Người 2 |
| 4 | ETS(M,A,N) | Base | Dự báo giá | Người 2 ✅ |
| 5 | ETS(M,Ad,N) Damped | Cải tiến | Dự báo giá (xu hướng tắt dần) | Người 2 |
| 6 | GARCH(1,1) | Base | Phân tích volatility | Người 3 |
| 7 | eGARCH(1,1) | Cải tiến | Volatility + leverage effect | Người 3 |
| 8 | GJR-GARCH(1,1) | Cải tiến | Volatility + asymmetric shock | Người 3 |

**Tổng cộng: 8 mô hình (3 base + 5 cải tiến)**

---

## Thứ Tự Thực Hiện Đề Xuất

1. **Người 1** bổ sung biểu đồ ACF/PACF, QQ-plot, boxplot weekday (nếu cần)
2. **Người 2** code thêm SARIMA, ARIMA+XREG, ETS Damped vào file `03_stationarity_arima_ets.R`
3. **Người 3** code GARCH base + eGARCH + GJR-GARCH vào file `04_garch_volatility.R`
4. **Người 3** tổng hợp model comparison và ghép báo cáo cuối

> ⚠️ **LƯU Ý QUAN TRỌNG:** Người 2 và Người 3 nên làm song song sau khi Người 1 hoàn thành phần bổ sung. Không cần đợi nhau vì data đầu vào (`fpt_clean.csv`) đã có sẵn.

---

## Package R Cần Cài Thêm

```r
# Đã có sẵn (không cần cài thêm)
# - forecast (cho auto.arima, ets)
# - tseries (cho adf.test)
# - rugarch (cho GARCH, eGARCH, GJR-GARCH)

# Chỉ cần đảm bảo đã cài:
install.packages(c("forecast", "tseries", "rugarch", "urca"))
```

Gói `rugarch` hỗ trợ sẵn tất cả các mô hình GARCH cải tiến (eGARCH, GJR-GARCH, iGARCH, TGARCH...), không cần cài thêm gói nào.
