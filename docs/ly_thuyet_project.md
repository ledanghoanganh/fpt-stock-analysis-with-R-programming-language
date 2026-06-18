# Lý Thuyết & Giải Thích Toàn Bộ Project FPT Stock Analysis

> **Mục đích:** Tài liệu lý thuyết nền tảng cho toàn bộ project phân tích cổ phiếu FPT  
> **Đối tượng:** Các thành viên nhóm cần hiểu sâu lý thuyết trước khi code

---

## Phần 1: Tổng Quan Project

### 1.1. Bài toán
Dự án phân tích chuỗi thời gian giá cổ phiếu FPT (sàn HOSE) với hai mục tiêu:
1. **Dự báo giá** đóng cửa bằng ARIMA và ETS
2. **Phân tích biến động (volatility)** bằng GARCH

### 1.2. Quy trình phân tích
```
Thu thập dữ liệu → Làm sạch → Trực quan hóa → Kiểm định tính dừng 
→ Mô hình hóa (ARIMA/ETS/GARCH) → Đánh giá → So sánh → Báo cáo
```

### 1.3. Dữ liệu
- **Nguồn:** Thư viện `vnstock` (Python)
- **Biến chính:** `close` (giá đóng cửa), `log_close` = ln(close), `return` = log_close_t - log_close_{t-1}
- **Giai đoạn:** 01/01/2015 – 08/06/2026 (2960 quan sát)

---

## Phần 2: Lý Thuyết Chuỗi Thời Gian

### 2.1. Tính dừng (Stationarity)

Chuỗi thời gian {Yₜ} là **dừng** nếu:
- E(Yₜ) = μ (kỳ vọng không đổi)
- Var(Yₜ) = σ² (phương sai không đổi)
- Cov(Yₜ, Yₜ₊ₖ) chỉ phụ thuộc vào k (hiệp phương sai chỉ phụ thuộc độ trễ)

**Tại sao quan trọng?** ARIMA yêu cầu chuỗi dừng (sau sai phân). Nếu ước lượng trên chuỗi không dừng → hồi quy giả mạo (spurious regression).

### 2.2. Kiểm định ADF (Augmented Dickey-Fuller)
- **H₀:** Chuỗi chứa nghiệm đơn vị (không dừng)
- **H₁:** Chuỗi dừng
- **Quy tắc:** p-value < 0.05 → bác bỏ H₀ → chuỗi dừng

**Kết quả trong project:**
| Chuỗi | ADF Statistic | p-value | Kết luận |
|---|---|---|---|
| close | -1.73 | 0.69 | Không dừng |
| log_close | -1.27 | 0.89 | Không dừng |
| return | -13.85 | <0.01 | **Dừng** |

→ Cần lấy sai phân bậc 1 (d=1) trước khi mô hình hóa ARIMA.

### 2.3. Log Transform & Differencing
- **Log transform:** log(close) → ổn định phương sai, giảm heteroskedasticity
- **Differencing bậc 1:** return_t = log(P_t) - log(P_{t-1}) → loại bỏ xu hướng, tạo chuỗi dừng

---

## Phần 3: Mô Hình ARIMA

### 3.1. ARIMA(p,d,q) — Base Model

**Tên đầy đủ:** AutoRegressive Integrated Moving Average

**Phương trình:**
```
ΔᵈYₜ = c + φ₁ΔᵈYₜ₋₁ + ... + φₚΔᵈYₜ₋ₚ + θ₁εₜ₋₁ + ... + θqεₜ₋q + εₜ
```

**Các thành phần:**
| Ký hiệu | Ý nghĩa |
|---|---|
| p (AR) | Bậc tự hồi quy — số ngày quá khứ ảnh hưởng đến giá hiện tại |
| d (I) | Bậc sai phân — số lần lấy sai phân để chuỗi dừng |
| q (MA) | Bậc trung bình trượt — số sai số quá khứ ảnh hưởng |

**Trong project:** `auto.arima()` chọn ARIMA(3,1,2) dựa trên AICc nhỏ nhất.

### 3.2. SARIMA(p,d,q)(P,D,Q)[m] — Cải tiến #1

**Tên:** Seasonal ARIMA — mở rộng ARIMA với thành phần mùa vụ.

**Phương trình tổng quát:**
```
Φ(Bᵐ)φ(B)(1-B)ᵈ(1-Bᵐ)ᴰYₜ = Θ(Bᵐ)θ(B)εₜ
```

Trong đó:
- (P,D,Q) là bậc AR, sai phân, MA theo mùa vụ
- m là chu kỳ mùa vụ (m=5 cho dữ liệu chứng khoán ngày = 5 ngày/tuần)
- B là toán tử trễ (lag operator)

**Khi nào dùng?** Khi dữ liệu có dấu hiệu lặp lại theo chu kỳ (ví dụ: hiệu ứng ngày thứ Hai, hiệu ứng cuối tuần).

**Cách dùng trong R:**
```r
train_ts <- ts(train_data$close, frequency = 5)
fit_sarima <- auto.arima(train_ts, seasonal = TRUE)
```

### 3.3. ARIMA + XREG — Cải tiến #2

**Ý tưởng:** Thêm biến ngoại sinh (exogenous variables) vào phương trình mean:

```
Yₜ = β₁X₁ₜ + β₂X₂ₜ + ... + NARIMAₜ
```

Trong đó NARIMAₜ là thành phần ARIMA trên phần dư sau khi trừ ảnh hưởng của biến ngoại sinh.

**Biến ngoại sinh phù hợp:** volume (khối lượng giao dịch), daily_range = high - low

**Lưu ý:** Khi dự báo, phải cung cấp giá trị biến ngoại sinh cho giai đoạn dự báo (`xreg` trong `forecast()`).

---

## Phần 4: Mô Hình ETS

### 4.1. ETS(Error, Trend, Seasonal) — Base

**Tên đầy đủ:** Exponential Smoothing State Space Model

ETS có 3 thành phần, mỗi thành phần có thể là:
| Thành phần | Các dạng |
|---|---|
| Error (E) | Additive (A) hoặc Multiplicative (M) |
| Trend (T) | None (N), Additive (A), Additive Damped (Ad), Multiplicative (M), Multiplicative Damped (Md) |
| Seasonal (S) | None (N), Additive (A), Multiplicative (M) |

**Trong project:** ETS(M,A,N)
- M: Sai số nhân tỉ lệ (sai số lớn hơn khi giá cao)
- A: Xu hướng tuyến tính cộng dồn
- N: Không mùa vụ

**Tham số làm mịn:**
- α = 0.9999 (gần 1 → mô hình "nhớ" chủ yếu quan sát gần nhất)
- β = 0.0016 (rất nhỏ → xu hướng thay đổi rất chậm)

### 4.2. ETS với Damped Trend — Cải tiến

**Ý tưởng:** Thay xu hướng tuyến tính (A) bằng xu hướng tắt dần (Ad). Tham số damping φ (0 < φ < 1) làm xu hướng giảm dần về 0 khi dự báo xa.

**Tại sao thực tế hơn?** Giá cổ phiếu không thể tăng mãi theo đường thẳng. ETS damped tránh việc ngoại suy quá xa.

```r
fit_ets_damped <- ets(train_ts, damped = TRUE)
```

---

## Phần 5: Mô Hình GARCH

### 5.1. Bối cảnh: Volatility Clustering

Dữ liệu tài chính có đặc điểm: giai đoạn biến động mạnh thường theo sau bởi biến động mạnh, và ngược lại. Đây gọi là **volatility clustering**. ARIMA/ETS giả sử phương sai sai số không đổi → không phù hợp để mô hình hóa volatility.

### 5.2. GARCH(1,1) — Base

**Tên:** Generalized Autoregressive Conditional Heteroskedasticity

**Phương trình:**
```
Mean equation:    rₜ = μ + εₜ,    εₜ = σₜ·zₜ,    zₜ ~ N(0,1)
Variance equation: σ²ₜ = ω + α₁ε²ₜ₋₁ + β₁σ²ₜ₋₁
```

| Tham số | Ý nghĩa |
|---|---|
| ω (omega) | Phương sai nền (baseline variance) |
| α₁ (alpha1) | Mức phản ứng với cú sốc mới (ARCH effect) |
| β₁ (beta1) | Mức duy trì volatility quá khứ (GARCH effect) |
| α₁ + β₁ | Persistence — càng gần 1, volatility càng dai dẳng |

**Ràng buộc:** ω > 0, α₁ ≥ 0, β₁ ≥ 0, α₁ + β₁ < 1 (để phương sai vô điều kiện hữu hạn)

### 5.3. eGARCH(1,1) — Cải tiến #1

**Tên:** Exponential GARCH (Nelson, 1991)

**Phương trình:**
```
ln(σ²ₜ) = ω + α₁|zₜ₋₁| + γ₁zₜ₋₁ + β₁ln(σ²ₜ₋₁)
```

**Ưu điểm so với GARCH chuẩn:**
1. Mô hình hóa log(variance) → không cần ràng buộc dương cho tham số
2. **Nắm bắt leverage effect** qua tham số γ:
   - γ < 0: tin xấu (return âm) gây volatility lớn hơn tin tốt → có leverage effect
   - γ = 0: tác động đối xứng (giống GARCH chuẩn)

### 5.4. GJR-GARCH(1,1) — Cải tiến #2

**Tên:** Glosten-Jagannathan-Runkle GARCH (1993)

**Phương trình:**
```
σ²ₜ = ω + (α₁ + γ₁·Iₜ₋₁)ε²ₜ₋₁ + β₁σ²ₜ₋₁
```

Trong đó Iₜ₋₁ = 1 nếu εₜ₋₁ < 0 (cú sốc âm), = 0 nếu εₜ₋₁ ≥ 0.

**Giải thích:**
- Khi có tin tốt (ε > 0): hệ số phản ứng = α₁
- Khi có tin xấu (ε < 0): hệ số phản ứng = α₁ + γ₁
- γ₁ > 0: tin xấu gây biến động mạnh hơn → **asymmetric volatility**

### 5.5. Phân phối Student-t

GARCH chuẩn giả sử zₜ ~ N(0,1). Tuy nhiên, return tài chính thường có **đuôi dày** (fat tails / excess kurtosis). Thay bằng phân phối Student-t:

zₜ ~ t(ν), với ν là bậc tự do (degrees of freedom)

- ν nhỏ → đuôi dày hơn (nhiều giá trị cực đoan)
- ν → ∞ → tiến về phân phối chuẩn

Trong R: `distribution.model = "std"` thay vì `"norm"`

---

## Phần 6: Đánh Giá Mô Hình

### 6.1. Metrics dự báo giá (ARIMA/ETS)

| Metric | Công thức | Ý nghĩa |
|---|---|---|
| RMSE | √(Σ(actual-pred)²/n) | Sai số tuyệt đối, phạt nặng sai số lớn |
| MAPE | Σ(\|actual-pred\|/actual)×100/n | Sai số theo %, dễ so sánh giữa các thang đo |

**Quy ước MAPE:**
- < 10%: Dự báo rất tốt
- 10-20%: Dự báo tốt
- 20-50%: Dự báo chấp nhận được
- > 50%: Dự báo kém

### 6.2. Metrics so sánh mô hình (AIC/BIC)

| Metric | Công thức | Đặc điểm |
|---|---|---|
| AIC | -2·logL + 2k | Cân bằng fit và complexity, nhẹ phạt |
| BIC | -2·logL + k·ln(n) | Phạt nặng hơn cho mô hình phức tạp |

**Quy tắc:** Mô hình có AIC/BIC **nhỏ hơn** là tốt hơn.

### 6.3. Đánh giá GARCH

GARCH không dùng RMSE/MAPE (vì dự báo volatility, không dự báo giá). Thay vào đó:
- So sánh AIC/BIC giữa các biến thể GARCH
- Kiểm tra ý nghĩa thống kê của tham số
- Kiểm tra tính dai dẳng: α + β gần 1 → volatility rất dai dẳng
- Kiểm tra leverage effect (eGARCH: γ, GJR: γ₁)

---

## Phần 7: Giải Thích Code Hiện Tại

### 7.1. File `00_config.R`
Khai báo đường dẫn và thư viện chung. Mọi file R khác phải `source("R/00_config.R")` đầu tiên.

### 7.2. File `01_data_cleaning.R` (Người 1 ✅)
- Đọc CSV thô → parse ngày → sắp xếp tăng dần → ép kiểu numeric
- Tạo `log_close = log(close)` và `return = log_close - lag(log_close)`
- Xuất `fpt_clean.csv`

### 7.3. File `02_visualization.R` (Người 1 ✅)
- Vẽ 3 biểu đồ: giá đóng cửa, volume, return
- Xuất bảng thống kê mô tả và missing values
- Dùng theme tùy chỉnh kiểu học thuật

### 7.4. File `03_stationarity_arima_ets.R` (Người 2 ✅)
**Quy trình:**
1. Kiểm định ADF cho close, log_close, return
2. Chia train/test: 2930/30 quan sát
3. Tạo ts object với frequency=1
4. `auto.arima()` → ARIMA(3,1,2)
5. `ets()` → ETS(M,A,N)
6. Forecast h=30, tính RMSE/MAPE
7. Vẽ biểu đồ forecast với khoảng tin cậy 80% và 95%

**Lưu ý trong code hiện tại:** Dòng 8 có `setwd()` với đường dẫn tuyệt đối → cần sửa thành đường dẫn tương đối.

### 7.5. File `04_garch_volatility.R` (Người 3 ❌)
**TRỐNG** — chưa được code. Cần Người 3 hoàn thành.

### 7.6. File `05_model_comparison.R` và `06_export_report_tables.R`
**TRỐNG** — chưa được code.

---

## Phần 8: Tại Sao Cần Mô Hình Cải Tiến?

### 8.1. Hạn chế của mô hình gốc

| Mô hình gốc | Hạn chế | Giải pháp cải tiến |
|---|---|---|
| ARIMA(3,1,2) | Không xét mùa vụ | SARIMA với m=5 |
| ARIMA(3,1,2) | Không tận dụng biến khác (volume...) | ARIMA + XREG |
| ETS(M,A,N) | Xu hướng tuyến tính → ngoại suy quá mạnh | ETS Damped |
| GARCH(1,1) | Giả sử tác động đối xứng | eGARCH / GJR-GARCH |
| GARCH(1,1) | Giả sử phân phối chuẩn | GARCH + Student-t |

### 8.2. Kỳ vọng kết quả

Sau khi áp dụng cải tiến, kỳ vọng:
- SARIMA: Có thể cải thiện RMSE/MAPE nếu dữ liệu FPT có tính mùa vụ tuần
- ARIMA+XREG: Có thể cải thiện nếu volume có tương quan với biến động giá
- ETS Damped: Dự báo dài hạn ổn định hơn ETS gốc
- eGARCH/GJR: Phát hiện leverage effect → hiểu rõ hơn hành vi biến động của FPT
- Student-t: AIC/BIC thường tốt hơn vì return tài chính thường có đuôi dày

---

## Phần 9: Tài Liệu Tham Khảo

1. Hyndman, R.J. & Athanasopoulos, G. (2021). *Forecasting: Principles and Practice*, 3rd ed. OTexts.
2. Tsay, R.S. (2010). *Analysis of Financial Time Series*, 3rd ed. Wiley.
3. Nelson, D.B. (1991). "Conditional Heteroskedasticity in Asset Returns: A New Approach". *Econometrica*, 59(2), 347-370.
4. Glosten, L.R., Jagannathan, R. & Runkle, D.E. (1993). "On the Relation between the Expected Value and the Volatility of the Nominal Excess Return on Stocks". *Journal of Finance*, 48(5), 1779-1801.
5. Package `forecast`: https://pkg.robjhyndman.com/forecast/
6. Package `rugarch`: https://cran.r-project.org/web/packages/rugarch/
