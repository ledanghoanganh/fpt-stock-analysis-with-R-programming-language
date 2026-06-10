# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 03_stationarity_arima_ets.R
# PURPOSE: Kiểm định tính dừng, xây dựng mô hình ARIMA, ETS và dự báo
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN & CẤU HÌNH ----------------------------------------------
source("R/00_config.R")
library(tseries)
library(forecast)
library(urca)
library(ggplot2)
library(scales)

# 2. ĐỌC DỮ LIỆU ĐÃ LÀM SẠCH ---------------------------------------------------
if (!file.exists(CLEAN_DATA_PATH)) {
  stop(paste("Không tìm thấy file dữ liệu sạch tại:", CLEAN_DATA_PATH))
}

df <- read.csv(CLEAN_DATA_PATH)
df$date <- as.Date(df$date)
df$time <- as.Date(df$time)

print(paste("Đọc dữ liệu thành công! Tổng số quan sát:", nrow(df)))

# 3. KIỂM ĐỊNH TÍNH DỪNG (ADF TEST) --------------------------------------------
print("--- Thực hiện kiểm định ADF ---")

# Kiểm định trên chuỗi giá đóng cửa gốc (close)
adf_close <- adf.test(df$close, alternative = "stationary")

# Kiểm định trên chuỗi log giá đóng cửa (log_close)
adf_log_close <- adf.test(df$log_close, alternative = "stationary")

# Kiểm định trên chuỗi lợi suất log (return) - bỏ dòng đầu tiên do lag() bị NA
return_clean <- df$return[!is.na(df$return)]
adf_return <- adf.test(return_clean, alternative = "stationary")

# Tạo bảng kết quả kiểm định tính dừng
stationarity_tests <- data.frame(
  Series = c("Giá đóng cửa (Close)", "Log giá đóng cửa (Log Close)", "Lợi suất Log (Return)"),
  ADF_Statistic = c(adf_close$statistic, adf_log_close$statistic, adf_return$statistic),
  P_Value = c(adf_close$p.value, adf_log_close$p.value, adf_return$p.value),
  Stationary = c(
    if (adf_close$p.value < 0.05) "Có (Stationary)" else "Không (Non-stationary)",
    if (adf_log_close$p.value < 0.05) "Có (Stationary)" else "Không (Non-stationary)",
    if (adf_return$p.value < 0.05) "Có (Stationary)" else "Không (Non-stationary)"
  )
)

print(stationarity_tests)

# Xuất bảng kết quả kiểm định tính dừng ra file CSV
write.csv(stationarity_tests, file.path(TABLE_DIR, "stationarity_tests.csv"), row.names = FALSE)
print(paste("Đã xuất kết quả kiểm định tính dừng vào:", file.path(TABLE_DIR, "stationarity_tests.csv")))

# 4. CHIA TẬP DỮ LIỆU HUẤN LUYỆN VÀ KIỂM THỬ (TRAIN/TEST SPLIT) -----------------
n_total <- nrow(df)
n_test <- 30 # Sử dụng 30 ngày giao dịch cuối cùng để làm tập test
n_train <- n_total - n_test

train_data <- df[1:n_train, ]
test_data <- df[(n_train + 1):n_total, ]

print(paste("Tập Train:", nrow(train_data), "quan sát (Từ", min(train_data$date), "đến", max(train_data$date), ")"))
print(paste("Tập Test :", nrow(test_data), "quan sát (Từ", min(test_data$date), "đến", max(test_data$date), ")"))

# Tạo đối tượng Time Series cho tập Train (tần suất = 1 vì dữ liệu ngày không chu kỳ rõ ràng)
train_ts <- ts(train_data$close, frequency = 1)

# 5. XÂY DỰNG MÔ HÌNH ARIMA ---------------------------------------------------
print("--- Huấn luyện mô hình ARIMA ---")
# auto.arima tự động tìm tham số (p, d, q) tối ưu dựa trên AICc
fit_arima <- auto.arima(train_ts, stepwise = FALSE, approximation = FALSE)
print("Thông tin mô hình ARIMA được chọn:")
print(summary(fit_arima))

# Lưu mô hình ARIMA
saveRDS(fit_arima, file.path(MODEL_DIR, "arima_model.rds"))

# 6. XÂY DỰNG MÔ HÌNH ETS -----------------------------------------------------
print("--- Huấn luyện mô hình ETS ---")
# ets tự động lựa chọn dạng sai số (Error), xu hướng (Trend), mùa vụ (Seasonal)
fit_ets <- ets(train_ts)
print("Thông tin mô hình ETS được chọn:")
print(summary(fit_ets))

# Lưu mô hình ETS
saveRDS(fit_ets, file.path(MODEL_DIR, "ets_model.rds"))

# 7. DỰ BÁO TRÊN TẬP TEST -----------------------------------------------------
print("--- Tiến hành dự báo trên tập Test ---")

# Dự báo ARIMA
fc_arima <- forecast(fit_arima, h = n_test)
arima_pred <- as.numeric(fc_arima$mean)

# Dự báo ETS
fc_ets <- forecast(fit_ets, h = n_test)
ets_pred <- as.numeric(fc_ets$mean)

# 8. ĐÁNH GIÁ SAI SỐ DỰ BÁO (RMSE & MAPE) -------------------------------------
actual <- test_data$close

# Hàm tính toán RMSE và MAPE
calculate_errors <- function(actual, predicted) {
  rmse <- sqrt(mean((actual - predicted)^2))
  mape <- mean(abs((actual - predicted) / actual)) * 100
  return(c(rmse, mape))
}

arima_errors <- calculate_errors(actual, arima_pred)
ets_errors <- calculate_errors(actual, ets_pred)

forecast_metrics <- data.frame(
  model = c("ARIMA", "ETS"),
  rmse = c(arima_errors[1], ets_errors[1]),
  mape = c(arima_errors[2], ets_errors[2])
)

print(forecast_metrics)

# Xuất bảng metrics ra file CSV
write.csv(forecast_metrics, file.path(TABLE_DIR, "forecast_metrics.csv"), row.names = FALSE)
print(paste("Đã xuất kết quả sai số dự báo vào:", file.path(TABLE_DIR, "forecast_metrics.csv")))

# 9. VẼ BIỂU ĐỒ DỰ BÁO SO VỚI THỰC TẾ -----------------------------------------
# Tạo theme học thuật chung
theme_forecast <- theme_minimal() +
  theme(
    plot.title = element_text(family = "Arial", face = "bold", size = 14, color = "#111111", hjust = 0.5),
    plot.subtitle = element_text(family = "Arial", size = 10, color = "#444444", hjust = 0.5),
    axis.title = element_text(family = "Arial", face = "bold", size = 11, color = "#111111"),
    axis.text = element_text(family = "Arial", size = 9.5, color = "#333333"),
    panel.grid.major = element_line(color = "#EAEAEA", linewidth = 0.5),
    panel.grid.minor = element_line(color = "#FAFAFA", linewidth = 0.3),
    legend.position = "bottom",
    plot.margin = margin(15, 15, 15, 15)
  )

# Chuẩn bị dữ liệu vẽ biểu đồ (lấy khoảng 100 ngày trước tập test + tập test để biểu đồ dễ nhìn)
n_history_plot <- 100
plot_history_data <- train_data[(n_train - n_history_plot + 1):n_train, ]

# Tạo dataframe để vẽ biểu đồ ARIMA
plot_arima_df <- data.frame(
  date = c(plot_history_data$date, test_data$date),
  Price = c(plot_history_data$close, actual),
  Type = c(rep("Thực tế (Lịch sử)", n_history_plot), rep("Thực tế (Tập Test)", n_test))
)

model_order <- arimaorder(fit_arima)
arima_label <- paste0("ARIMA(", model_order[1], ",", model_order[2], ",", model_order[3], ")")

# Thêm thông tin dự báo ARIMA
arima_forecast_df <- data.frame(
  date = test_data$date,
  Price = arima_pred,
  Type = rep(paste("Dự báo", arima_label), n_test),
  lower80 = as.numeric(fc_arima$lower[, 1]),
  upper80 = as.numeric(fc_arima$upper[, 1]),
  lower95 = as.numeric(fc_arima$lower[, 2]),
  upper95 = as.numeric(fc_arima$upper[, 2])
)

# Biểu đồ ARIMA
p_arima <- ggplot() +
  # Vẽ phần giá thực tế lịch sử và tập test
  geom_line(data = plot_arima_df, aes(x = date, y = Price, color = Type), linewidth = 0.8) +
  # Vẽ khoảng tin cậy 95%
  geom_ribbon(data = arima_forecast_df, aes(x = date, ymin = lower95, ymax = upper95), fill = "#0056B3", alpha = 0.12) +
  # Vẽ khoảng tin cậy 80%
  geom_ribbon(data = arima_forecast_df, aes(x = date, ymin = lower80, ymax = upper80), fill = "#0056B3", alpha = 0.22) +
  # Vẽ đường dự báo
  geom_line(data = arima_forecast_df, aes(x = date, y = Price, color = Type), linewidth = 1, linetype = "dashed") +
  scale_color_manual(values = setNames(c("#7F8C8D", "#2C3E50", "#E74C3C"), c("Thực tế (Lịch sử)", "Thực tế (Tập Test)", paste("Dự báo", arima_label)))) +
  labs(
    title = paste("Dự báo giá cổ phiếu FPT bằng mô hình", arima_label),
    subtitle = paste("Tập test từ", min(test_data$date), "đến", max(test_data$date), " | MAPE =", round(arima_errors[2], 2), "%"),
    x = "Thời gian",
    y = "Giá đóng cửa (VNĐ)",
    color = "Chú thích"
  ) +
  scale_x_date(date_labels = "%d/%m/%Y", date_breaks = "1 month") +
  scale_y_continuous(labels = comma) +
  theme_forecast

ggsave(file.path(FIGURE_DIR, "arima_forecast.png"), plot = p_arima, width = 10, height = 6, dpi = 300)
print(paste("Đã lưu biểu đồ dự báo ARIMA vào:", file.path(FIGURE_DIR, "arima_forecast.png")))

# Thêm thông tin dự báo ETS
ets_label <- paste0("ETS (", fit_ets$method, ")")
ets_forecast_df <- data.frame(
  date = test_data$date,
  Price = ets_pred,
  Type = rep(paste("Dự báo", ets_label), n_test),
  lower80 = as.numeric(fc_ets$lower[, 1]),
  upper80 = as.numeric(fc_ets$upper[, 1]),
  lower95 = as.numeric(fc_ets$lower[, 2]),
  upper95 = as.numeric(fc_ets$upper[, 2])
)

# Biểu đồ ETS
p_ets <- ggplot() +
  geom_line(data = plot_arima_df, aes(x = date, y = Price, color = Type), linewidth = 0.8) +
  geom_ribbon(data = ets_forecast_df, aes(x = date, ymin = lower95, ymax = upper95), fill = "#2E7D32", alpha = 0.12) +
  geom_ribbon(data = ets_forecast_df, aes(x = date, ymin = lower80, ymax = upper80), fill = "#2E7D32", alpha = 0.22) +
  geom_line(data = ets_forecast_df, aes(x = date, y = Price, color = Type), linewidth = 1, linetype = "dashed") +
  scale_color_manual(values = setNames(c("#7F8C8D", "#2C3E50", "#27AE60"), c("Thực tế (Lịch sử)", "Thực tế (Tập Test)", paste("Dự báo", ets_label)))) +
  labs(
    title = paste("Dự báo giá cổ phiếu FPT bằng mô hình", ets_label),
    subtitle = paste("Tập test từ", min(test_data$date), "đến", max(test_data$date), " | MAPE =", round(ets_errors[2], 2), "%"),
    x = "Thời gian",
    y = "Giá đóng cửa (VNĐ)",
    color = "Chú thích"
  ) +
  scale_x_date(date_labels = "%d/%m/%Y", date_breaks = "1 month") +
  scale_y_continuous(labels = comma) +
  theme_forecast

ggsave(file.path(FIGURE_DIR, "ets_forecast.png"), plot = p_ets, width = 10, height = 6, dpi = 300)
print(paste("Đã lưu biểu đồ dự báo ETS vào:", file.path(FIGURE_DIR, "ets_forecast.png")))

print("--- Hoàn thành toàn bộ công việc của Người thứ 2! ---")
