# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 05_model_comparison.R
# PURPOSE: Tổng hợp, so sánh kết quả các mô hình ARIMA, ETS và GARCH
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN & CẤU HÌNH ----------------------------------------------
source("R/00_config.R")
library(dplyr)
library(tidyr)

# 2. ĐỌC DỮ LIỆU ĐẦU VÀO TỪ CÁC MÔ HÌNH TRƯỚC ĐÓ -------------------------------
forecast_metrics_path <- file.path(TABLE_DIR, "forecast_metrics.csv")
garch_summary_path <- file.path(TABLE_DIR, "garch_summary.csv")

if (!file.exists(forecast_metrics_path) || !file.exists(garch_summary_path)) {
  stop("Thiếu file kết quả. Vui lòng đảm bảo đã chạy 03_stationarity_arima_ets.R và 04_garch_volatility.R")
}

forecast_metrics <- read.csv(forecast_metrics_path)
garch_summary <- read.csv(garch_summary_path)

print("--- Đã tải kết quả của ARIMA, ETS và GARCH thành công ---")

# 3. XỬ LÝ VÀ CHUẨN HÓA BẢNG SO SÁNH -------------------------------------------
# Xử lý kết quả từ ARIMA và ETS (RMSE, MAPE)
# Cấu trúc hiện tại: model, rmse, mape
forecast_summary <- forecast_metrics %>%
  mutate(
    Model_Type = "Dự báo mức giá trung bình (Mean Forecast)",
    Key_Metric_1 = paste0("RMSE: ", format(round(rmse, 2), big.mark=",")),
    Key_Metric_2 = paste0("MAPE: ", round(mape, 2), "%")
  ) %>%
  rename(Model = model) %>%
  select(Model, Model_Type, Key_Metric_1, Key_Metric_2)

# Xử lý kết quả từ GARCH (AIC, BIC)
# Các mô hình biến động (Volatility) không đo bằng RMSE hay MAPE, 
# mà đánh giá mức độ phù hợp thông qua AIC/BIC
aic_val <- garch_summary %>% filter(Parameter == "AIC") %>% pull(Estimate)
bic_val <- garch_summary %>% filter(Parameter == "BIC") %>% pull(Estimate)

garch_row <- data.frame(
  Model = "ARMA(0,0)-GARCH(1,1)",
  Model_Type = "Dự báo mức độ biến động (Volatility Forecast)",
  Key_Metric_1 = paste0("AIC: ", round(as.numeric(aic_val), 4)),
  Key_Metric_2 = paste0("BIC: ", round(as.numeric(bic_val), 4))
)

# 4. GỘP KẾT QUẢ VÀ XUẤT RA FILE -----------------------------------------------
model_comparison <- bind_rows(forecast_summary, garch_row)

write.csv(model_comparison, file.path(TABLE_DIR, "model_comparison.csv"), row.names = FALSE)

print("--- BẢNG TỔNG HỢP ĐÁNH GIÁ MÔ HÌNH ---")
print(model_comparison)
print("---------------------------------------")
print(paste("Đã xuất bảng tổng hợp vào:", file.path(TABLE_DIR, "model_comparison.csv")))
