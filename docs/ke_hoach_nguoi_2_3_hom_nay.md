# Kế hoạch trong ngày cho Người 2 và Người 3

> Ngày thực hiện: 19/06/2026.  
> Mục tiêu: hoàn thành mọi phần **không phụ thuộc dữ liệu cuối**, để sau khi Người 1 bàn giao chỉ cần chạy lại, kiểm tra số và cập nhật nhận xét.

## 1. Nguyên tắc làm việc hôm nay

- Người 2 làm branch `person2-forecast-framework`.
- Người 3 làm branch `person3-garch-report-framework`.
- Dữ liệu hiện tại chỉ là **provisional data**. Được dùng để chạy thử code, không được coi là kết quả cuối.
- Không commit đè `data/raw/`, `data/processed/` hoặc output mới của Người 1.
- Không nhập số liệu thủ công vào Markdown, Word hoặc slide.
- Mỗi người commit code và tài liệu do mình thực sự chạy/đọc/kiểm tra.
- Khi Người 1 gửi `DATA HANDOFF PASSED`, cả hai phải pull dữ liệu mới và chạy lại toàn bộ model.

## 2. Hợp đồng dữ liệu tạm thời

Người 2 và Người 3 viết code dựa trên schema sau:

```text
date, open, high, low, close, volume, log_close, return
```

Code phải kiểm tra trước khi chạy:

```r
required_columns <- c(
  "date", "open", "high", "low", "close", "volume", "log_close", "return"
)

missing_columns <- setdiff(required_columns, names(df))
if (length(missing_columns) > 0) {
  stop("Dữ liệu thiếu cột: ", paste(missing_columns, collapse = ", "))
}
```

Không dùng cột `time` hoặc `returns`. Biến model thống nhất là `close` và `return`.

## 3. Lịch làm việc đề xuất

| Khung | Người 2 | Người 3 |
|---|---|---|
| 08:00-09:00 | Chuẩn hóa script và hàm đánh giá | Dựng entry point, dependency check, khung report |
| 09:00-11:00 | Naive benchmark và rolling-origin CV | GARCH variants và bảng so sánh |
| 11:00-12:00 | Residual diagnostics | GARCH diagnostics |
| 13:30-15:00 | ETS damped, SARIMA/ARIMAX có điều kiện | Ghép report, bảng và hình tự động |
| 15:00-16:00 | Viết Modeling không chứa số cứng | Dựng slide và các mục rubric còn thiếu |
| 16:00-17:00 | Tự kiểm thử và PR | Tự kiểm thử và PR |
| 17:00-18:00 | Review chéo phần Người 3 | Review chéo phần Người 2 |

Nếu bắt đầu muộn, giữ nguyên thứ tự và rút ngắn phần model cải tiến trước; không bỏ diagnostics hoặc report skeleton.

## 4. Nhiệm vụ Người 2 - Forecast framework

### P2-1. Tách code thành các hàm tái sử dụng

**File sở hữu:** `R/03_stationarity_arima_ets.R`.

Tạo tối thiểu các hàm:

```r
validate_model_data(df)
calculate_forecast_metrics(actual, predicted)
fit_forecast_models(train_data)
forecast_one_split(train_data, test_data)
run_rolling_origin_cv(df, initial, horizon, step)
diagnose_forecast_model(model, model_name)
```

Tiêu chí nghiệm thu:

- [ ] Không còn phụ thuộc cố định vào 2,960 hoặc 2,930 dòng.
- [ ] `n_test` được cấu hình ở đầu file.
- [ ] Hàm metric trả về RMSE, MAE và MAPE.
- [ ] Có lỗi rõ ràng nếu test set rỗng hoặc actual chứa giá không dương.
- [ ] Tất cả model dùng cùng train/test split.

### P2-2. Thêm benchmark bắt buộc

Thêm ít nhất:

- Naive/random walk: dự báo mọi bước bằng giá cuối tập train.
- Drift: dùng `forecast::rwf(..., drift = TRUE)`.

ARIMA hoặc ETS chỉ được gọi là tốt hơn khi metric ngoài mẫu thấp hơn benchmark.

Output dự kiến:

```text
output/tables/forecast_metrics.csv
```

Schema bắt buộc:

```text
model,split,rmse,mae,mape
```

### P2-3. Rolling-origin cross-validation

Dùng nhiều cửa sổ theo thời gian, không shuffle dữ liệu. Có thể bắt đầu với:

```r
initial <- floor(0.80 * nrow(df))
horizon <- 20
step <- 20
```

Nếu chạy `auto.arima(stepwise = FALSE)` quá lâu, CV được phép dùng `stepwise = TRUE`, nhưng lần fit cuối có thể dùng tìm kiếm đầy đủ.

Output:

```text
output/tables/forecast_cv_metrics.csv
```

Phải có metric theo từng fold và một bảng tổng hợp mean/median.

### P2-4. Residual diagnostics

Với ARIMA và ETS:

- Vẽ residual time plot, ACF residual.
- Chạy Ljung-Box với bậc tự do phù hợp.
- Ghi rõ H0 và cách diễn giải.
- Không khẳng định residual là white noise nếu p-value không hỗ trợ.

Output:

```text
output/tables/forecast_diagnostics.csv
output/figures/arima_residual_diagnostics.png
output/figures/ets_residual_diagnostics.png
```

### P2-5. Model cải tiến theo mức ưu tiên

1. **ETS damped:** làm ngay, vì không cần biến ngoài.
2. **SARIMA chu kỳ 5:** chỉ giữ trong bảng cuối nếu weekday/ACF từ Người 1 có bằng chứng hợp lý.
3. **ARIMAX:** hôm nay chỉ viết framework dùng biến trễ. Không dùng volume hoặc daily range tương lai thật của test set như dữ liệu đã biết.

ARIMAX an toàn hơn có thể dùng:

```text
lag_volume, lag_daily_range, lag_return
```

Tất cả được tạo bằng `lag()` trước khi chia train/test. Nếu forecast nhiều bước vẫn cần giả định biến tương lai, phải ghi đây là conditional forecast hoặc hoãn khỏi bài cuối.

### P2-6. Viết phần báo cáo không chứa số cứng

**File sở hữu:** `report/sections/04_modeling_arima_ets.md`.

Hôm nay hoàn thiện:

- Lý do split theo thời gian.
- Công thức và ý nghĩa Naive, ARIMA, ETS, ETS damped.
- Cách hoạt động rolling-origin CV.
- Định nghĩa RMSE, MAE, MAPE.
- Quy trình residual diagnostics.
- Tiêu chí chọn model.

Đánh dấu vị trí bảng/hình bằng tên output, không gõ trước kết quả số.

### P2-7. Pull Request cuối ngày

Commit đề xuất:

```text
Refactor forecast evaluation pipeline
Add naive benchmarks and rolling-origin validation
Add ARIMA and ETS residual diagnostics
Document reproducible forecast methodology
```

PR phải ghi:

```text
## Đã hoàn thành
- [ ] Code không phụ thuộc số dòng cố định
- [ ] Naive và drift benchmark
- [ ] Rolling-origin CV
- [ ] Residual diagnostics
- [ ] ETS damped
- [ ] Modeling section không chứa số cứng

## Trạng thái dữ liệu
Kết quả hiện tại là provisional. Cần chạy lại sau DATA HANDOFF PASSED.

## Cách kiểm thử
source("R/03_stationarity_arima_ets.R")
```

## 5. Nhiệm vụ Người 3 - GARCH, báo cáo và tích hợp

### P3-1. Tạo entry point và dependency check

**File sở hữu:** `R/run_all.R` và `R/00_config.R`.

`R/run_all.R` phải:

1. Kiểm tra package, không tự động cài.
2. Kiểm tra thư mục chạy là project root.
3. Chạy script từ `01` đến `06` theo thứ tự.
4. Dừng ngay khi một script lỗi.
5. Ghi `sessionInfo()` vào `output/session_info.txt`.

Không chạy `font_import()` tự động trong pipeline vì rất chậm và phụ thuộc máy.

Tiêu chí nghiệm thu:

- [ ] Một lệnh `source("R/run_all.R")` đủ chạy project.
- [ ] Thông báo lỗi nêu package/file đang thiếu.
- [ ] Không có `install.packages()` trong script sản xuất.

### P3-2. Refactor GARCH thành framework nhiều model

**File sở hữu:** `R/04_garch_volatility.R`.

Tạo hàm dùng chung:

```r
fit_garch_model(returns, variance_model, distribution_model)
extract_garch_summary(fit, model_name)
diagnose_garch_model(fit, model_name)
```

Fit thử bốn model trên cùng return/sample:

1. sGARCH(1,1), Normal.
2. sGARCH(1,1), Student-t.
3. eGARCH(1,1), Student-t.
4. GJR-GARCH(1,1), Student-t.

Không để một model fail làm mất toàn bộ kết quả. Dùng xử lý lỗi và ghi trạng thái convergence.

### P3-3. Chẩn đoán GARCH

Trước khi fit:

- ARCH-LM trên return hoặc residual mean equation.

Sau khi fit:

- Kiểm tra convergence.
- Ljung-Box standardized residuals.
- Ljung-Box squared standardized residuals.
- ARCH-LM sau model.
- Sign bias test nếu `rugarch` cung cấp.
- Kiểm tra persistence theo đúng công thức model.

Không diễn giải eGARCH/GJR bằng công thức persistence của sGARCH.

Output:

```text
output/tables/garch_comparison.csv
output/tables/garch_diagnostics.csv
output/tables/garch_parameters.csv
output/figures/garch_model_comparison.png
```

### P3-4. Sửa model comparison

**File sở hữu:** `R/05_model_comparison.R`.

Tách thành hai bảng:

```text
output/tables/price_forecast_comparison.csv
output/tables/volatility_model_comparison.csv
```

Không đặt RMSE/MAPE và AIC/BIC trong cùng một bảng xếp hạng. Không gọi AIC âm là bằng chứng model “cực kỳ tối ưu”.

### P3-5. Hoàn thiện report skeleton

**File sở hữu:** `report/report.Rmd` và các section ngoài phần Người 1/Người 2.

Hôm nay báo cáo phải knit được ngay cả khi một vài bảng cải tiến chưa có. Cấu trúc đủ 11 mục:

1. Abstract.
2. Introduction.
3. Data.
4. Data Visualization.
5. Data Modeling.
6. Experiments, Results and Discussion.
7. Conclusions.
8. Appendices.
9. Contributions.
10. References.
11. Peer Assessment.

Yêu cầu:

- Dùng child documents hoặc `knit_child()` để ghép section.
- Chèn bảng bằng `read_csv()` + `knitr::kable()`.
- Chèn hình bằng `knitr::include_graphics()`.
- Có helper kiểm tra file tồn tại và hiển thị ghi chú “pending final rerun” thay vì crash ở bản provisional.
- Điền tên thật, mã sinh viên và tên nhóm khi đã có.

### P3-6. Tạo slide skeleton

Tạo `presentation/fpt_stock_analysis.pptx` hoặc nguồn `presentation.Rmd` nếu nhóm dùng R Markdown.

Tối thiểu 10 slide:

1. Tên đề tài và thành viên.
2. Bài toán và mục tiêu.
3. Nguồn và quy trình dữ liệu.
4. EDA chính.
5. Stationarity.
6. Forecast methodology.
7. Forecast results.
8. Volatility/GARCH.
9. Hạn chế và kết luận.
10. Contributions và Q&A.

Hôm nay dùng placeholder có nhãn rõ `PENDING FINAL DATA`, không dùng số cũ như số cuối.

### P3-7. Viết nội dung học thuật không phụ thuộc data cuối

Hoàn thiện trước:

- Abstract dạng khung, chưa ghi metric.
- Introduction và research questions.
- Phương pháp GARCH.
- Cách so sánh model và diagnostics.
- Hạn chế về dữ liệu lịch sử và structural breaks.
- Contributions/Peer Assessment dạng bảng để cả nhóm điền.
- References theo một style thống nhất.

Xóa hoặc sửa các câu hiện tại về khuyến nghị mua/bán, VaR, cắt lỗ nếu chưa triển khai/backtest.

### P3-8. Pull Request cuối ngày

Commit đề xuất:

```text
Add reproducible project entry point
Add GARCH variants and diagnostics framework
Separate price and volatility model comparisons
Build rubric-complete report and presentation skeleton
```

PR phải ghi:

```text
## Đã hoàn thành
- [ ] run_all.R và dependency checks
- [ ] 4 GARCH specifications
- [ ] GARCH diagnostics
- [ ] Tách comparison tables
- [ ] Report đủ 11 mục và knit thử
- [ ] Slide skeleton

## Trạng thái dữ liệu
Kết quả hiện tại là provisional. Cần chạy lại sau DATA HANDOFF PASSED.

## Cách kiểm thử
source("R/run_all.R")
rmarkdown::render("report/report.Rmd")
```

## 6. Review chéo cuối ngày

### Người 2 review Người 3

- [ ] Bốn GARCH dùng đúng cùng sample.
- [ ] Model comparison không trộn metric khác bài toán.
- [ ] Report có đủ 11 phần rubric.
- [ ] Không còn khẳng định AIC âm nghĩa là tối ưu.
- [ ] Không còn khuyến nghị đầu tư chưa được kiểm chứng.

### Người 3 review Người 2

- [ ] Có naive benchmark.
- [ ] Split/CV giữ đúng thứ tự thời gian.
- [ ] Không dùng biến xreg tương lai bị rò rỉ.
- [ ] Metric tính trên cùng actual/test folds.
- [ ] Có residual diagnostics và diễn giải đúng H0.

Mỗi người để ít nhất một review có nội dung trên PR của người còn lại. Không tự merge PR của mình nếu chưa được review.

## 7. Definition of Done lúc kết thúc hôm nay

### Người 2 hoàn thành khi

- [ ] Script forecast chạy được trên provisional data.
- [ ] Có Naive, Drift, ARIMA, ETS và ETS damped.
- [ ] Có rolling-origin CV và residual diagnostics.
- [ ] Section Modeling đã viết xong phần phương pháp.
- [ ] PR đã được Người 3 review.

### Người 3 hoàn thành khi

- [ ] Có `R/run_all.R`.
- [ ] Framework bốn GARCH chạy hoặc ghi lỗi convergence rõ ràng.
- [ ] Có GARCH diagnostics và bảng comparison tách riêng.
- [ ] `report.Rmd` có đủ 11 phần và knit được bản provisional.
- [ ] Có slide skeleton.
- [ ] PR đã được Người 2 review.

## 8. Việc phải làm ngay khi Người 1 bàn giao

Không sửa model trước khi làm tuần tự:

1. Merge PR Người 1.
2. Cả hai pull cùng một commit.
3. Xóa hoặc ghi đè các output provisional bằng lần chạy mới.
4. Người 2 chạy forecast pipeline và chốt model/metric.
5. Người 3 chạy GARCH pipeline, comparison và render báo cáo.
6. Đối chiếu mọi số trong Word/slide với CSV.
7. Chạy kiểm thử chéo trên máy của người không viết module đó.
8. Chỉ khi đó mới gỡ nhãn `PENDING FINAL DATA`.

## 9. Tin nhắn gửi nhóm ngay bây giờ

```text
Trong lúc chờ data sạch, Người 2 và Người 3 sẽ hoàn thiện framework trên dữ liệu tạm.

Người 2: benchmark, rolling CV, forecast diagnostics, ETS damped và phần phương pháp ARIMA/ETS.
Người 3: run_all, GARCH variants/diagnostics, report đủ rubric và slide skeleton.

Không ai chốt số cuối hoặc sửa file của Người 1. Sau khi nhận DATA HANDOFF PASSED, cả hai sẽ chạy lại toàn bộ từ cùng một commit dữ liệu.
```

