# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 04_garch_volatility.R
# PURPOSE: Xây dựng mô hình GARCH(1,1), phân tích biến động (volatility)
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN & CẤU HÌNH ----------------------------------------------
source("R/00_config.R")
library(rugarch)
library(ggplot2)
library(scales)
library(extrafont)

# Tự động kiểm tra và cấu hình phông chữ hệ thống
if(!any(fonts() == "Arial")) { suppressMessages(font_import(prompt = FALSE)); loadfonts() }

# Thiết lập phông nền đồ thị chuẩn học thuật (Theme)
theme_academic <- theme_minimal() + 
  theme(
    plot.title = element_text(family = "Arial", face = "bold", size = 15, color = "#111111", hjust = 0.5),
    plot.subtitle = element_text(family = "Arial", size = 10.5, color = "#444444", hjust = 0.5),
    axis.title = element_text(family = "Arial", face = "bold", size = 11, color = "#111111"),
    axis.text = element_text(family = "Arial", size = 9.5, color = "#333333"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    panel.grid.minor = element_line(color = "#F5F5F5", linewidth = 0.35),
    plot.margin = margin(15, 15, 15, 15)
  )

# 2. ĐỌC DỮ LIỆU ĐÃ LÀM SẠCH ---------------------------------------------------
if (!file.exists(CLEAN_DATA_PATH)) {
  stop(paste("Không tìm thấy file dữ liệu sạch tại:", CLEAN_DATA_PATH))
}

df <- read.csv(CLEAN_DATA_PATH)
df$date <- as.Date(df$date)

# Lọc bỏ giá trị NA của chuỗi return (do dòng đầu tiên bị NA)
df_valid <- df %>% filter(!is.na(return))
returns <- df_valid$return

print(paste("Đọc dữ liệu thành công! Tổng số quan sát hợp lệ:", nrow(df_valid)))

# 3. XÂY DỰNG MÔ HÌNH GARCH(1,1) -----------------------------------------------
print("--- Xây dựng mô hình GARCH(1,1) ---")

# Khởi tạo tham số mô hình GARCH(1,1) với mean equation là ARMA(0,0) (chỉ có hằng số)
garch_spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "norm"
)

# Huấn luyện mô hình
garch_fit <- ugarchfit(spec = garch_spec, data = returns)

# Hiển thị tóm tắt mô hình
print(garch_fit)

# Lưu mô hình đã huấn luyện
saveRDS(garch_fit, file.path(MODEL_DIR, "garch_model.rds"))
print(paste("Đã lưu mô hình GARCH vào:", file.path(MODEL_DIR, "garch_model.rds")))

# 4. XUẤT BẢNG THAM SỐ MÔ HÌNH -------------------------------------------------
# Trích xuất ma trận hệ số 
coef_mat <- garch_fit@fit$matcoef
garch_summary <- data.frame(
  Parameter = rownames(coef_mat),
  Estimate = coef_mat[, " Estimate"],
  StdError = coef_mat[, " Std. Error"],
  t_value = coef_mat[, " t value"],
  Pr_z = coef_mat[, "Pr(>|t|)"]
)

# Thêm thông tin mô hình cơ bản (log likelihood, AIC, BIC)
info_df <- data.frame(
  Parameter = c("Log-Likelihood", "AIC", "BIC"),
  Estimate = c(likelihood(garch_fit), infocriteria(garch_fit)[1], infocriteria(garch_fit)[2]),
  StdError = NA, t_value = NA, Pr_z = NA
)

garch_summary_final <- rbind(garch_summary, info_df)

write.csv(garch_summary_final, file.path(TABLE_DIR, "garch_summary.csv"), row.names = FALSE)
print(paste("Đã xuất bảng tham số mô hình vào:", file.path(TABLE_DIR, "garch_summary.csv")))

# 5. PHÂN TÍCH VÀ XUẤT BẢNG ĐỘ BIẾN ĐỘNG (VOLATILITY) --------------------------
# Trích xuất chuỗi độ lệch chuẩn có điều kiện (conditional volatility - sigma)
volatility_series <- sigma(garch_fit)

# Ghép với chuỗi ngày tương ứng
vol_df <- data.frame(
  date = df_valid$date,
  return = returns,
  volatility = as.numeric(volatility_series)
)

write.csv(vol_df, file.path(TABLE_DIR, "garch_volatility.csv"), row.names = FALSE)
print(paste("Đã xuất bảng dữ liệu độ biến động vào:", file.path(TABLE_DIR, "garch_volatility.csv")))

# 6. TRỰC QUAN HÓA ĐỘ BIẾN ĐỘNG VÀ XUẤT ĐỒ THỊ ----------------------------------
print("--- Vẽ biểu đồ biến động ---")

p_volatility <- ggplot(vol_df, aes(x = date)) +
  geom_line(aes(y = return), color = "#BDC3C7", linewidth = 0.5, alpha = 0.8) +
  geom_line(aes(y = volatility), color = "#C0392B", linewidth = 0.8) +
  geom_line(aes(y = -volatility), color = "#C0392B", linewidth = 0.8) +
  labs(
    title = "Mức Độ Biến Động (Volatility) Cổ Phiếu FPT Qua Thời Gian",
    subtitle = "Dự đoán bởi mô hình GARCH(1,1) (Đường màu đỏ bọc ngoài mức sinh lời thực tế)",
    x = "Thời gian",
    y = "Tỷ suất sinh lời / Độ biến động"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  theme_academic

ggsave(file.path(FIGURE_DIR, "garch_volatility.png"), plot = p_volatility, width = 11, height = 6.5, dpi = 300)
print(paste("Đã lưu biểu đồ biến động GARCH vào:", file.path(FIGURE_DIR, "garch_volatility.png")))

print("--- Hoàn thành module GARCH! ---")
