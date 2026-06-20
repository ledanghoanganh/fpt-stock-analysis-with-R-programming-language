# Tính dừng và dự báo giá

## Kiểm định ADF

Augmented Dickey-Fuller kiểm định:

- H0: chuỗi có unit root, không dừng.
- H1: chuỗi dừng theo specification của kiểm định.

P-value lớn được diễn giải là “chưa đủ bằng chứng bác bỏ H0”, không phải “chấp nhận H0”.

```{r adf-table}
kable(stationarity, caption = "Kết quả kiểm định ADF trên dữ liệu sạch", digits = 4)
```

`close` và `log_close` có p-value lần lượt `r fmt_number(stationarity$P_Value[1], 4)` và `r fmt_number(stationarity$P_Value[2], 4)`, nên chưa bác bỏ unit root ở mức 5%. `return` có p-value được `adf.test()` báo ở cận dưới 0,01, nên bác bỏ unit root. Log transform thay đổi scale nhưng không tự loại stochastic trend; sai phân log tạo return phù hợp hơn cho GARCH.

## Thiết kế forecast

Dữ liệu được chia theo thời gian, không shuffle. Ba mươi phiên cuối tạo holdout chung cho bảy phương pháp. Rolling-origin CV bắt đầu từ 80% model sample, dùng horizon 20 và step 20, tạo `r n_cv_folds` folds cho Naive, Drift, ARIMA, ETS và ETS Damped. SARIMA và ARIMAX chưa có cùng CV coverage, nên chỉ được đánh giá trên final holdout.

| Mô hình | Ý tưởng |
|---|---|
| Naive | Mọi dự báo bằng giá cuối tập train |
| Drift | Random walk cộng độ trôi trung bình lịch sử |
| ARIMA | AR, sai phân và MA; order được `auto.arima()` lựa chọn |
| SARIMA | Thử thêm cấu trúc chu kỳ 5 phiên |
| ETS | State-space error, trend và seasonality |
| ETS Damped | ETS với trend tắt dần |
| ARIMAX Lagged | ARIMA cộng `lag_volume`, `lag_daily_range`, `lag_return` |

ARIMAX chỉ dùng biến trễ một phiên để tránh dùng trực tiếp thông tin cùng ngày. Tuy nhiên, triển khai thực tế vẫn phải bảo đảm xreg có sẵn đúng thời điểm forecast.

## Metric và diagnostics

\[
RMSE=\sqrt{\frac{1}{n}\sum e_t^2}, \qquad
MAE=\frac{1}{n}\sum |e_t|, \qquad
MAPE=\frac{100}{n}\sum\left|\frac{e_t}{y_t}\right|.
\]

Ba metric đều có hướng nhỏ hơn tốt hơn. RMSE phạt lỗi lớn mạnh hơn MAE; MAPE cho tỷ lệ tương đối nhưng không phù hợp khi actual gần 0. Ljung-Box residual có H0 là không có autocorrelation đến lag kiểm tra. P-value nhỏ cho thấy model còn bỏ sót mean dynamics.

## Kết quả holdout, CV và residual

```{r price-comparison-table}
price_report <- price_comparison %>%
  select(model, rmse, mae, mape, final_rmse_rank,
         cv_mean_rmse, cv_mean_mape, cv_rmse_rank,
         residual_ljung_box_p, residual_diagnostic_pass,
         evidence_assessment)
kable(price_report,
      caption = "So sánh forecast bằng holdout, rolling CV và Ljung-Box",
      digits = 4)
```

`r best_holdout$model` có holdout RMSE thấp nhất (`r fmt_number(best_holdout$rmse)`), nhưng chỉ hơn Naive `r fmt_number(holdout_gain)` đơn vị RMSE. MAPE thấp nhất thuộc về `r price_comparison$model[which.min(price_comparison$mape)]` (`r fmt_number(min(price_comparison$mape), 2)`%), cho thấy thứ hạng phụ thuộc metric. Trong rolling CV, `r best_cv$model` dẫn đầu với mean RMSE `r fmt_number(best_cv$cv_mean_rmse)`.

```{r forecast-diagnostic-table}
kable(forecast_diagnostics,
      caption = "Ljung-Box trên residual của fitted forecast models",
      digits = 5)
```

Có `r n_forecast_diagnostics_pass` trong `r nrow(forecast_diagnostics)` fitted models vượt Ljung-Box ở mức 5%; hiện tất cả residual đều chưa đạt white noise. Kết hợp ba nguồn bằng chứng, dự án chưa chứng minh model phức tạp cải thiện Naive một cách ổn định.

```{r ets-damped-forecast, fig.cap="ETS Damped trên holdout 30 phiên"}
include_required_figure("output/figures/ets_damped_forecast.png")
```

Biểu đồ cần được đọc ở phần cuối chuỗi: forecast và interval chỉ mô tả bất định theo model, không phải cam kết giá tương lai nằm trong khoảng.

```{r ets-damped-diagnostics, fig.cap="Residual diagnostics của ETS Damped"}
include_required_figure("output/figures/ets_damped_residual_diagnostics.png")
```

## Kết luận phần forecast

ETS Damped là holdout leader theo RMSE nhưng mức cải thiện so với Naive rất nhỏ; Naive dẫn rolling CV; mọi fitted model còn residual autocorrelation. Vì vậy báo cáo không chỉ định một model thắng chung cuộc và không dùng forecast này làm tín hiệu mua/bán. Kết quả phù hợp với nhận định thận trọng rằng mức giá khó dự báo ổn định trong protocol hiện tại, nhưng không chứng minh mọi giá tài chính luôn tuân theo random walk.
