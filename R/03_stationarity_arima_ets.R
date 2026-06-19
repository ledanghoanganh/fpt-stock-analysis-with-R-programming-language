# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 03_stationarity_arima_ets.R
# PURPOSE: Framework dự báo chuỗi thời gian (Người 2)
# ==============================================================================

source("R/00_config.R")
library(tseries)
library(forecast)
library(urca)
library(ggplot2)
library(scales)
library(dplyr)
library(tidyr)
library(lmtest)

# 1. HÀM KIỂM TRA DỮ LIỆU
validate_model_data <- function(df) {
  required_columns <- c("date", "open", "high", "low", "close", "volume", "log_close", "return")
  missing_columns <- setdiff(required_columns, names(df))
  if (length(missing_columns) > 0) {
    stop("Dữ liệu thiếu cột: ", paste(missing_columns, collapse = ", "))
  }
  return(TRUE)
}

# 2. HÀM TÍNH TOÁN METRICS
calculate_forecast_metrics <- function(actual, predicted) {
  if(length(actual) == 0 || length(predicted) == 0) stop("Test set rỗng!")
  if(any(actual <= 0, na.rm = TRUE)) stop("actual chứa giá không dương, không thể tính MAPE!")
  
  rmse <- sqrt(mean((actual - predicted)^2, na.rm = TRUE))
  mae <- mean(abs(actual - predicted), na.rm = TRUE)
  mape <- mean(abs((actual - predicted) / actual), na.rm = TRUE) * 100
  
  return(data.frame(rmse = rmse, mae = mae, mape = mape))
}

# 3. HÀM VẼ BIỂU ĐỒ DỰ BÁO
plot_forecast <- function(forecast_obj, actual, model_name, file_name) {
  start_time <- end(forecast_obj$x)[1] + 1/frequency(forecast_obj$x)
  actual_ts <- ts(actual, start = start_time, frequency = frequency(forecast_obj$x))
  
  p <- autoplot(forecast_obj) +
    autolayer(actual_ts, series = "Thực tế", PI = FALSE, color = "red", size = 1) +
    labs(title = paste("Dự báo", model_name, "vs Thực tế"),
         y = "Giá đóng cửa (VNĐ)", x = "Thời gian") +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      legend.position = "bottom",
      legend.title = element_blank()
    )
  ggsave(file.path(FIGURE_DIR, file_name), plot = p, width = 10, height = 6, dpi = 300, bg = "white")
}

# 3.5. HÀM CHẨN ĐOÁN RESIDUAL
diagnose_forecast_model <- function(model, model_name) {
  res <- residuals(model)
  
  # Tìm degrees of freedom phù hợp cho Ljung-Box test
  test_lag <- 10
  if("ARIMA" %in% class(model)) {
    fitdf <- sum(model$arma[c(1, 2)])
  } else {
    fitdf <- length(model$par)
  }
  test_lag <- max(test_lag, fitdf + 1)
  
  lb_test <- Box.test(res, lag = test_lag, type = "Ljung-Box", fitdf = fitdf)
  
  # Vẽ đồ thị ACF và PACF
  png_path <- file.path(FIGURE_DIR, paste0(tolower(gsub(" ", "_", model_name)), "_residual_diagnostics.png"))
  png(png_path, width = 800, height = 500)
  tsdisplay(res, main = paste("Residual Diagnostics -", model_name))
  dev.off()
  
  return(data.frame(
    model = model_name,
    lb_statistic = lb_test$statistic,
    lb_p_value = lb_test$p.value,
    test_lag = test_lag,
    fitdf = fitdf,
    white_noise = ifelse(lb_test$p.value > 0.05, "Yes (Fail to reject H0)", "No (Reject H0)")
  ))
}

# 4. HÀM HUẤN LUYỆN VÀ DỰ BÁO TRÊN MỘT LẦN CHIA SPLIT
forecast_one_split <- function(train_data, test_data) {
  train_ts <- ts(train_data$close, frequency = 1)
  h <- nrow(test_data)
  actual <- test_data$close
  metrics_list <- list()
  
  # 4.1 Naive
  fc_naive <- naive(train_ts, h = h)
  m_naive <- calculate_forecast_metrics(actual, fc_naive$mean)
  m_naive$model <- "Naive"
  metrics_list[[1]] <- m_naive
  
  # 4.2 Drift
  fc_drift <- rwf(train_ts, drift = TRUE, h = h)
  m_drift <- calculate_forecast_metrics(actual, fc_drift$mean)
  m_drift$model <- "Drift"
  metrics_list[[2]] <- m_drift
  
  # 4.3 ARIMA
  fit_arima <- auto.arima(train_ts, stepwise = FALSE, approximation = FALSE)
  fc_arima <- forecast(fit_arima, h = h)
  m_arima <- calculate_forecast_metrics(actual, fc_arima$mean)
  m_arima$model <- "ARIMA"
  metrics_list[[3]] <- m_arima
  
  # 4.3.1 SARIMA
  train_ts_seasonal <- ts(train_data$close, frequency = 5)
  fit_sarima <- auto.arima(train_ts_seasonal, seasonal = TRUE, stepwise = FALSE, approximation = FALSE)
  fc_sarima <- forecast(fit_sarima, h = h)
  m_sarima <- calculate_forecast_metrics(actual, fc_sarima$mean)
  m_sarima$model <- "SARIMA"
  metrics_list[[4]] <- m_sarima
  
  # 4.4 ETS
  fit_ets <- ets(train_ts)
  fc_ets <- forecast(fit_ets, h = h)
  m_ets <- calculate_forecast_metrics(actual, fc_ets$mean)
  m_ets$model <- "ETS"
  metrics_list[[5]] <- m_ets
  
  # 4.5 ETS Damped
  fit_ets_damped <- ets(train_ts, damped = TRUE)
  fc_ets_damped <- forecast(fit_ets_damped, h = h)
  m_ets_damped <- calculate_forecast_metrics(actual, fc_ets_damped$mean)
  m_ets_damped$model <- "ETS Damped"
  metrics_list[[6]] <- m_ets_damped
  
  # 4.6 ARIMAX (Lagged)
  fit_arimax <- NULL
  fc_arimax <- NULL
  xreg_train <- as.matrix(train_data %>% select(lag_volume, lag_daily_range, lag_return))
  xreg_test <- as.matrix(test_data %>% select(lag_volume, lag_daily_range, lag_return))
  if(!any(is.na(xreg_train)) && !any(is.na(xreg_test))) {
    fit_arimax <- auto.arima(train_ts, xreg = xreg_train, stepwise = TRUE)
    fc_arimax <- forecast(fit_arimax, xreg = xreg_test, h = h)
    m_arimax <- calculate_forecast_metrics(actual, fc_arimax$mean)
    m_arimax$model <- "ARIMAX (Lagged)"
    metrics_list[[7]] <- m_arimax
  }
  
  all_metrics <- bind_rows(metrics_list) %>% select(model, rmse, mae, mape)
  
  return(list(
    metrics = all_metrics,
    models = list(ARIMA = fit_arima, SARIMA = fit_sarima, ETS = fit_ets, ETS_Damped = fit_ets_damped, ARIMAX = fit_arimax),
    forecasts = list(ARIMA = fc_arima, SARIMA = fc_sarima, ETS = fc_ets, ETS_Damped = fc_ets_damped, ARIMAX = fc_arimax)
  ))
}

# 5. HÀM ROLLING-ORIGIN CROSS VALIDATION
run_rolling_origin_cv <- function(df, initial, horizon, step) {
  n_total <- nrow(df)
  folds <- seq(initial, n_total - horizon, by = step)
  cv_results <- list()
  fold_idx <- 1
  
  for(i in folds) {
    train_data <- df[1:i, ]
    test_data <- df[(i + 1):(i + horizon), ]
    train_ts <- ts(train_data$close, frequency = 1)
    actual <- test_data$close
    
    fc_naive <- naive(train_ts, h = horizon)
    fc_drift <- rwf(train_ts, drift = TRUE, h = horizon)
    fit_arima <- auto.arima(train_ts, stepwise = TRUE, approximation = TRUE)
    fc_arima <- forecast(fit_arima, h = horizon)
    fit_ets <- ets(train_ts)
    fc_ets <- forecast(fit_ets, h = horizon)
    fit_ets_damped <- ets(train_ts, damped = TRUE)
    fc_ets_damped <- forecast(fit_ets_damped, h = horizon)
    
    m_naive <- calculate_forecast_metrics(actual, fc_naive$mean) %>% mutate(model = "Naive", split = fold_idx)
    m_drift <- calculate_forecast_metrics(actual, fc_drift$mean) %>% mutate(model = "Drift", split = fold_idx)
    m_arima <- calculate_forecast_metrics(actual, fc_arima$mean) %>% mutate(model = "ARIMA", split = fold_idx)
    m_ets <- calculate_forecast_metrics(actual, fc_ets$mean) %>% mutate(model = "ETS", split = fold_idx)
    m_ets_damped <- calculate_forecast_metrics(actual, fc_ets_damped$mean) %>% mutate(model = "ETS Damped", split = fold_idx)
    
    cv_results[[fold_idx]] <- bind_rows(m_naive, m_drift, m_arima, m_ets, m_ets_damped)
    fold_idx <- fold_idx + 1
  }
  
  all_cv <- bind_rows(cv_results)
  summary_cv <- all_cv %>%
    group_by(model) %>%
    summarise(
      mean_rmse = mean(rmse), mean_mae = mean(mae),
      mean_mape = mean(mape), median_mape = median(mape)
    )
  
  return(list(raw = all_cv, summary = summary_cv))
}

# 6. MAIN EXECUTION
if (sys.nframe() == 0) {
  print("--- Bắt đầu Forecast Framework ---")
  
  df <- read.csv(CLEAN_DATA_PATH)
  df$date <- as.Date(df$date)
  
  if("time" %in% names(df)) df <- df %>% select(-time)
  validate_model_data(df)
  
  df <- df %>%
    arrange(date) %>%
    mutate(
      daily_range = high - low,
      lag_volume = dplyr::lag(volume, 1),
      lag_daily_range = dplyr::lag(daily_range, 1),
      lag_return = dplyr::lag(return, 1)
    )
  
  df_model <- df %>% drop_na(lag_volume, lag_daily_range, lag_return)
  n_total <- nrow(df_model)
  n_test <- 30
  n_train <- n_total - n_test
  
  train_data <- df_model[1:n_train, ]
  test_data <- df_model[(n_train + 1):n_total, ]
  
  print("1. Huấn luyện các mô hình trên Final Split...")
  final_split_results <- forecast_one_split(train_data, test_data)
  
  final_metrics <- final_split_results$metrics %>% mutate(split = "Final 30 days")
  final_metrics <- final_metrics %>% select(model, split, rmse, mae, mape)
  write.csv(final_metrics, file.path(TABLE_DIR, "forecast_metrics.csv"), row.names = FALSE)
  print(paste("Đã xuất", file.path(TABLE_DIR, "forecast_metrics.csv")))
  
  print("1.5. Lưu biểu đồ, mô hình và trích xuất AIC/BIC...")
  models <- final_split_results$models
  forecasts <- final_split_results$forecasts
  
  # Lưu các biểu đồ
  plot_forecast(forecasts$ARIMA, test_data$close, "ARIMA", "arima_forecast.png")
  plot_forecast(forecasts$SARIMA, test_data$close, "SARIMA", "sarima_forecast.png")
  plot_forecast(forecasts$ETS, test_data$close, "ETS", "ets_forecast.png")
  plot_forecast(forecasts$ETS_Damped, test_data$close, "ETS Damped", "ets_damped_forecast.png")
  if(!is.null(forecasts$ARIMAX)) plot_forecast(forecasts$ARIMAX, test_data$close, "ARIMA+XREG", "arima_xreg_forecast.png")
  
  # Lưu mô hình .rds
  saveRDS(models$ARIMA, file.path(MODEL_DIR, "arima_model.rds"))
  saveRDS(models$SARIMA, file.path(MODEL_DIR, "sarima_model.rds"))
  saveRDS(models$ETS, file.path(MODEL_DIR, "ets_model.rds"))
  saveRDS(models$ETS_Damped, file.path(MODEL_DIR, "ets_damped_model.rds"))
  if(!is.null(models$ARIMAX)) saveRDS(models$ARIMAX, file.path(MODEL_DIR, "arima_xreg_model.rds"))
  
  # Trích xuất AIC/BIC
  aic_bic_list <- list()
  extract_aic_bic <- function(model, name, type) {
    if(!is.null(model)) {
      return(data.frame(model = name, aic = AIC(model), bic = BIC(model), type = type))
    }
    return(NULL)
  }
  
  aic_bic_list[[1]] <- extract_aic_bic(models$ARIMA, "ARIMA", "Base")
  aic_bic_list[[2]] <- extract_aic_bic(models$SARIMA, "SARIMA", "Improved")
  aic_bic_list[[3]] <- extract_aic_bic(models$ARIMAX, "ARIMAX (Lagged)", "Improved")
  aic_bic_list[[4]] <- extract_aic_bic(models$ETS, "ETS", "Base")
  aic_bic_list[[5]] <- extract_aic_bic(models$ETS_Damped, "ETS Damped", "Improved")
  
  model_aic_bic <- bind_rows(aic_bic_list)
  
  # Ghép với bảng metrics
  model_comparison_full <- final_metrics %>%
    left_join(model_aic_bic, by = "model") %>%
    select(model, rmse, mape, aic, bic, type)
    
  write.csv(model_comparison_full, file.path(TABLE_DIR, "model_aic_bic_comparison.csv"), row.names = FALSE)
  print(paste("Đã xuất", file.path(TABLE_DIR, "model_aic_bic_comparison.csv")))

  print("2. Chẩn đoán phần dư (Residual Diagnostics)...")
  diag_arima <- diagnose_forecast_model(models$ARIMA, "ARIMA")
  diag_sarima <- diagnose_forecast_model(models$SARIMA, "SARIMA")
  diag_ets <- diagnose_forecast_model(models$ETS, "ETS")
  diag_ets_d <- diagnose_forecast_model(models$ETS_Damped, "ETS Damped")
  diag_list <- list(diag_arima, diag_sarima, diag_ets, diag_ets_d)
  if(!is.null(models$ARIMAX)) diag_list[[5]] <- diagnose_forecast_model(models$ARIMAX, "ARIMAX")
  diag_all <- bind_rows(diag_list)
  write.csv(diag_all, file.path(TABLE_DIR, "forecast_diagnostics.csv"), row.names = FALSE)
  print(paste("Đã xuất", file.path(TABLE_DIR, "forecast_diagnostics.csv")))
  
  print("3. Thực hiện Rolling-origin Cross Validation...")
  initial_cv <- floor(0.80 * nrow(df_model))
  horizon_cv <- 20
  step_cv <- 20
  cv_res <- run_rolling_origin_cv(df_model, initial_cv, horizon_cv, step_cv)
  
  write.csv(cv_res$raw, file.path(TABLE_DIR, "forecast_cv_metrics_raw.csv"), row.names = FALSE)
  write.csv(cv_res$summary, file.path(TABLE_DIR, "forecast_cv_metrics_summary.csv"), row.names = FALSE)
  print(paste("Đã xuất bảng đánh giá Cross Validation vào thư mục", TABLE_DIR))
  
  print("--- Hoàn thành Forecast Framework ---")
}
