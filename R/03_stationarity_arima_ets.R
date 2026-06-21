# Kiểm định tính dừng, fit forecast models và đánh giá ngoài mẫu.
source("R/00_config.R")
require_packages(c("tseries", "forecast", "ggplot2"))

MODEL_COLUMNS <- c("date", "open", "high", "low", "close", "volume", "log_close", "return")
HOLDOUT_SIZE <- 30
CV_HORIZON <- 20
CV_STEP <- 20

# Tính ba metric trên cùng vector actual/predicted; giá phải dương để MAPE hợp lệ.
forecast_metrics <- function(actual, predicted) {
  if (!length(actual) || length(actual) != length(predicted)) stop("Forecast length không hợp lệ.")
  if (any(actual <= 0, na.rm = TRUE)) stop("Actual phải dương để tính MAPE.")
  error <- actual - as.numeric(predicted)
  tibble(
    rmse = sqrt(mean(error^2, na.rm = TRUE)),
    mae = mean(abs(error), na.rm = TRUE),
    mape = 100 * mean(abs(error / actual), na.rm = TRUE)
  )
}

# Chuyển kết quả adf.test thành một hàng tidy để báo cáo đọc trực tiếp.
adf_row <- function(values, series_name) {
  test <- suppressWarnings(tseries::adf.test(stats::na.omit(values)))
  tibble(
    Series = series_name,
    ADF_Statistic = unname(test$statistic),
    P_Value = test$p.value,
    Stationary = if_else(test$p.value < 0.05, "Có (Stationary)", "Không (Non-stationary)")
  )
}

# Fit toàn bộ final-split models; mỗi model dùng đúng cùng train và horizon.
fit_final_models <- function(train, test) {
  train_ts <- ts(train$close, frequency = 1)
  seasonal_ts <- ts(train$close, frequency = 5)
  horizon <- nrow(test)
  x_columns <- c("lag_volume", "lag_daily_range", "lag_return")
  x_train <- as.matrix(train[x_columns])
  x_test <- as.matrix(test[x_columns])

  # Model object được lưu để diagnostics/RDS; benchmark chỉ cần forecast object.
  models <- list(
    ARIMA = forecast::auto.arima(train_ts, stepwise = FALSE, approximation = FALSE),
    SARIMA = forecast::auto.arima(seasonal_ts, seasonal = TRUE,
                                  stepwise = FALSE, approximation = FALSE),
    ETS = forecast::ets(train_ts),
    ETS_Damped = forecast::ets(train_ts, damped = TRUE),
    ARIMAX = forecast::auto.arima(train_ts, xreg = x_train, stepwise = TRUE)
  )
  forecasts <- list(
    Naive = forecast::naive(train_ts, h = horizon),
    Drift = forecast::rwf(train_ts, drift = TRUE, h = horizon),
    ARIMA = forecast::forecast(models$ARIMA, h = horizon),
    SARIMA = forecast::forecast(models$SARIMA, h = horizon),
    ETS = forecast::forecast(models$ETS, h = horizon),
    ETS_Damped = forecast::forecast(models$ETS_Damped, h = horizon),
    ARIMAX = forecast::forecast(models$ARIMAX, xreg = x_test, h = horizon)
  )
  list(models = models, forecasts = forecasts)
}

# Tên hiển thị tách khỏi key code để file/output luôn nhất quán.
model_labels <- c(
  Naive = "Naive", Drift = "Drift", ARIMA = "ARIMA", SARIMA = "SARIMA",
  ETS = "ETS", ETS_Damped = "ETS Damped", ARIMAX = "ARIMAX (Lagged)"
)

# Tính metric cho một named list forecast mà không lặp bảy đoạn code giống nhau.
score_forecasts <- function(forecasts, actual) {
  purrr::imap_dfr(forecasts, ~ forecast_metrics(actual, .x$mean) %>%
                    mutate(model = model_labels[[.y]], .before = 1))
}

# Vẽ forecast interval và actual; actual bắt đầu ngay sau điểm cuối của train ts.
save_forecast_plot <- function(forecast_object, actual, title, filename) {
  frequency <- stats::frequency(forecast_object$x)
  actual_ts <- ts(actual, start = end(forecast_object$x)[1] + 1 / frequency,
                  frequency = frequency)
  plot <- forecast::autoplot(forecast_object) +
    forecast::autolayer(actual_ts, series = "Thực tế",
                        color = "red", linewidth = 0.8) +
    labs(title = paste("Dự báo", title, "so với thực tế"),
         x = "Thời gian", y = "Giá đóng cửa (VND)") +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", hjust = 0.5),
          legend.position = "bottom", legend.title = element_blank())
  ggsave(file.path(FIGURE_DIR, filename), plot, width = 10, height = 6,
         dpi = 300, bg = "white")
}

# Ljung-Box kiểm tra residual còn autocorrelation sau khi fit hay không.
diagnose_model <- function(model, name) {
  residuals <- stats::residuals(model)
  fitdf <- if (inherits(model, "ARIMA")) sum(model$arma[c(1, 2)]) else length(model$par)
  test_lag <- max(10, fitdf + 1)
  test <- stats::Box.test(residuals, lag = test_lag, type = "Ljung-Box", fitdf = fitdf)

  # tsdisplay gom residual series, ACF và PACF vào một hình.
  png(file.path(FIGURE_DIR, paste0(tolower(gsub(" ", "_", name)),
                                   "_residual_diagnostics.png")),
      width = 800, height = 500)
  on.exit(dev.off(), add = TRUE)
  forecast::tsdisplay(residuals, main = paste("Residual diagnostics -", name))

  tibble(
    model = name,
    lb_statistic = unname(test$statistic),
    lb_p_value = test$p.value,
    test_lag = test_lag,
    fitdf = fitdf,
    white_noise = if_else(test$p.value > 0.05,
                          "Yes (Fail to reject H0)", "No (Reject H0)")
  )
}

# Một CV fold chỉ fit năm model có cùng coverage trong thiết kế hiện tại.
score_cv_fold <- function(data, train_end, horizon, fold_id) {
  train <- data[seq_len(train_end), ]
  test <- data[train_end + seq_len(horizon), ]
  train_ts <- ts(train$close, frequency = 1)
  fits <- list(
    Naive = forecast::naive(train_ts, h = horizon),
    Drift = forecast::rwf(train_ts, drift = TRUE, h = horizon),
    ARIMA = forecast::forecast(
      forecast::auto.arima(train_ts, stepwise = TRUE, approximation = TRUE), h = horizon
    ),
    ETS = forecast::forecast(forecast::ets(train_ts), h = horizon),
    ETS_Damped = forecast::forecast(forecast::ets(train_ts, damped = TRUE), h = horizon)
  )
  score_forecasts(fits, test$close) %>% mutate(split = fold_id)
}

# Rolling-origin mở rộng train theo thời gian và tổng hợp metric qua mọi fold.
run_rolling_cv <- function(data, initial, horizon = CV_HORIZON, step = CV_STEP) {
  origins <- seq(initial, nrow(data) - horizon, by = step)
  raw <- purrr::imap_dfr(origins, ~ score_cv_fold(data, .x, horizon, .y))
  summary <- raw %>%
    group_by(model) %>%
    summarise(
      mean_rmse = mean(rmse), mean_mae = mean(mae),
      mean_mape = mean(mape), median_mape = median(mape), .groups = "drop"
    )
  list(raw = raw, summary = summary)
}

# Đọc clean data, xác nhận schema và tạo feature chỉ từ thông tin phiên trước.
data <- readr::read_csv(CLEAN_DATA_PATH, show_col_types = FALSE) %>%
  mutate(date = as.Date(date))
assert_columns(data, MODEL_COLUMNS, "Dữ liệu model")

# ADF luôn được tái sinh từ đúng clean data của lần chạy hiện tại.
stationarity <- bind_rows(
  adf_row(data$close, "Giá đóng cửa (Close)"),
  adf_row(data$log_close, "Log giá đóng cửa (Log Close)"),
  adf_row(data$return, "Lợi suất Log (Return)")
)
write_project_csv(stationarity, "stationarity_tests.csv")

# Lag một phiên ngăn việc dùng trực tiếp thông tin cùng ngày làm xreg.
model_data <- data %>%
  arrange(date) %>%
  mutate(
    daily_range = high - low,
    lag_volume = lag(volume),
    lag_daily_range = lag(daily_range),
    lag_return = lag(return)
  ) %>%
  drop_na(lag_volume, lag_daily_range, lag_return)
if (nrow(model_data) <= HOLDOUT_SIZE) stop("Không đủ dữ liệu cho holdout.")

# Final split giữ nguyên 30 phiên cuối làm dữ liệu chưa thấy khi huấn luyện.
train_end <- nrow(model_data) - HOLDOUT_SIZE
train <- model_data[seq_len(train_end), ]
test <- model_data[train_end + seq_len(HOLDOUT_SIZE), ]
final <- fit_final_models(train, test)
final_metrics <- score_forecasts(final$forecasts, test$close) %>%
  mutate(split = "Final 30 days", .after = model) %>%
  select(model, split, rmse, mae, mape)
write_project_csv(final_metrics, "forecast_metrics.csv")

# Registry này điều khiển đồng thời tên model, tên file hình và tên file RDS.
model_files <- tribble(
  ~key, ~label, ~plot_file, ~rds_file, ~type,
  "ARIMA", "ARIMA", "arima_forecast.png", "arima_model.rds", "Base",
  "SARIMA", "SARIMA", "sarima_forecast.png", "sarima_model.rds", "Improved",
  "ETS", "ETS", "ets_forecast.png", "ets_model.rds", "Base",
  "ETS_Damped", "ETS Damped", "ets_damped_forecast.png", "ets_damped_model.rds", "Improved",
  "ARIMAX", "ARIMAX (Lagged)", "arima_xreg_forecast.png", "arima_xreg_model.rds", "Improved"
)
purrr::pwalk(model_files, function(key, label, plot_file, rds_file, type) {
  save_forecast_plot(final$forecasts[[key]], test$close, label, plot_file)
  saveRDS(final$models[[key]], file.path(MODEL_DIR, rds_file))
})

# AIC/BIC chỉ áp dụng cho fitted statistical models, không cho Naive/Drift.
aic_bic <- purrr::map_dfr(seq_len(nrow(model_files)), function(index) {
  key <- model_files$key[[index]]
  fitted_model <- final$models[[key]]
  tibble(
    model = model_files$label[[index]],
    aic = AIC(fitted_model), bic = BIC(fitted_model),
    type = model_files$type[[index]]
  )
})
write_project_csv(
  final_metrics %>% left_join(aic_bic, by = "model") %>%
    select(model, rmse, mape, aic, bic, type),
  "model_aic_bic_comparison.csv"
)

# Diagnostics dùng key ARIMAX ngắn để tương thích bảng comparison hiện tại.
diagnostic_labels <- c(ARIMA = "ARIMA", SARIMA = "SARIMA", ETS = "ETS",
                       ETS_Damped = "ETS Damped", ARIMAX = "ARIMAX")
diagnostics <- purrr::imap_dfr(final$models, ~ diagnose_model(.x, diagnostic_labels[[.y]]))
write_project_csv(diagnostics, "forecast_diagnostics.csv")

# CV bắt đầu tại 80% sample và dùng horizon/step 20 phiên.
cv <- run_rolling_cv(model_data, initial = floor(0.80 * nrow(model_data)))
write_project_csv(cv$raw, "forecast_cv_metrics_raw.csv")
write_project_csv(cv$summary, "forecast_cv_metrics_summary.csv")

message("Hoàn tất forecast: 7 holdout models và ",
        length(unique(cv$raw$split)), " rolling-origin folds.")
