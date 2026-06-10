# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 02_visualization.R
# PURPOSE: Xuất bảng thống kê mô tả & Trực quan hóa chuỗi dữ liệu chuẩn học thuật
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN & CẤU HÌNH PHÔNG ĐỒ THỊ ----------------------------------
library(tidyverse)
library(scales) 
library(extrafont) # Thư viện giúp đồng bộ phông chữ Arial sắc nét

# Tự động kiểm tra và cấu hình phông chữ hệ thống
if(!any(fonts() == "Arial")) { font_import(prompt = FALSE); loadfonts() }

# 2. ĐỌC DỮ LIỆU ĐÃ LÀM SẠCH ---------------------------------------------------
data_path <- "data/processed/fpt_clean.csv"

if (!file.exists(data_path)) {
  stop("Không tìm thấy file fpt_clean.csv! Vui lòng chạy file R/01_data_cleaning.R trước.")
}

df <- read.csv(data_path)

# Ép lại định dạng ngày tháng để vẽ biểu đồ không bị lỗi trục X
df$time <- as.Date(df$time)

# Tính toán tỷ suất sinh lời hằng ngày (daily returns) dựa trên cột close
df <- df %>%
  arrange(time) %>%
  mutate(returns = (close - lag(close)) / lag(close)) 

# 3. KIỂM TRA VÀ XUẤT BÁO CÁO GIÁ TRỊ THIẾU (MISSING VALUES) --------------------
missing_report <- data.frame(
  Variable = colnames(df),
  Missing_Count = colSums(is.na(df)),
  Missing_Percentage = (colSums(is.na(df)) / nrow(df)) * 100
)

if (!dir.exists("output/tables")) dir.create("output/tables", recursive = TRUE)
write.csv(missing_report, "output/tables/missing_values.csv", row.names = FALSE)
print("--- Đã xuất báo cáo Missing Values vào output/tables/ ---")

# 4. TÍNH TOÁN VÀ XUẤT BẢNG THỐNG KÊ MÔ TẢ --------------------------------------
summary_table <- df %>%
  summarise(
    across(c(close, volume, returns), list(
      Count  = ~sum(!is.na(.)),
      Mean   = ~mean(., na.rm = TRUE),
      Median = ~median(., na.rm = TRUE),
      Min    = ~min(., na.rm = TRUE),
      Max    = ~max(., na.rm = TRUE),
      SD     = ~sd(., na.rm = TRUE)
    ), .names = "{.col}_{.fn}")
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = c("Variable", "Statistic"),
    names_pattern = "(.*)_(.*)"
  ) %>%
  pivot_wider(
    names_from = "Statistic",
    values_from = "value"
  )

write.csv(summary_table, "output/tables/data_summary.csv", row.names = FALSE)
print("--- Đã xuất bảng Thống kê mô tả vào output/tables/ ---")

# 5. THIẾT LẬP PHÔNG NỀN ĐỒ THỊ CHUẨN NGHÊN CỨU (THEME) ------------------------
if (!dir.exists("output/figures")) dir.create("output/figures", recursive = TRUE)

theme_academic <- theme_minimal() + 
  theme(
    plot.title = element_text(family = "Arial", face = "bold", size = 15, color = "#111111", hjust = 0.5),
    plot.subtitle = element_text(family = "Arial", size = 10.5, color = "#444444", hjust = 0.5),
    axis.title = element_text(family = "Arial", face = "bold", size = 11, color = "#111111"),
    axis.title.y = element_text(vjust = 2.5),
    axis.title.x = element_text(vjust = -1),
    axis.text = element_text(family = "Arial", size = 9.5, color = "#333333"),
    axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1),
    panel.grid.major = element_line(color = "#E5E5E5", linewidth = 0.5),
    panel.grid.major.x = element_blank(), # Tối giản đường lưới dọc để làm nổi bật dòng thời gian
    panel.grid.minor = element_line(color = "#F5F5F5", linewidth = 0.35),
    plot.margin = margin(15, 15, 15, 15)
  )

# 6. TRỰC QUAN HÓA DỮ LIỆU VÀ XUẤT ĐỒ THỊ CHẤT LƯỢNG CAO -----------------------

# --- Biểu đồ 1: Biểu đồ Giá đóng cửa (Đường lên xuống sắc nét) ---
p_close <- ggplot(df, aes(x = time, y = close)) +
  geom_line(color = "#0056B3", linewidth = 0.75) +
  labs(
    title = "Xu Hướng Giá Đóng Cửa Cổ Phiếu FPT",
    subtitle = paste("Giai đoạn lịch sử:", min(df$time), "đến", max(df$time)),
    x = "Thời gian",
    y = "Giá đóng cửa (VNĐ)"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(labels = comma, breaks = seq(60000, 80000, by = 2500)) +
  theme_academic

ggsave("output/figures/close_price.png", plot = p_close, width = 11, height = 6.5, dpi = 300)


# --- Biểu đồ 2: Biểu đồ Khối lượng giao dịch (Dạng cột trực quan) ---
p_volume <- ggplot(df, aes(x = time, y = volume)) +
  geom_bar(stat = "identity", fill = "#2E7D32", alpha = 0.7) +
  labs(
    title = "Khối Lượng Giao Dịch Cổ Phiếu FPT Qua Thời Gian",
    subtitle = paste("Giai đoạn lịch sử:", min(df$time), "đến", max(df$time)),
    x = "Thời gian",
    y = "Khối lượng giao dịch (Cổ phiếu)"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(labels = comma) +
  theme_academic

ggsave("output/figures/volume.png", plot = p_volume, width = 11, height = 6.5, dpi = 300)


# --- Biểu đồ 3: Biểu đồ Tỷ suất sinh lời (Đường răng cưa học thuật) ---
p_returns <- ggplot(df %>% filter(!is.na(returns)), aes(x = time, y = returns)) +
  geom_line(color = "#C0392B", linewidth = 0.45) +
  labs(
    title = "Biến Động Tỷ Suất Sinh Lời Hằng Ngày Của Cổ Phiếu FPT",
    subtitle = "Daily Returns (Kiểm tra hiện tượng biến động cụm - Volatility Clustering | 2024 - 2026)",
    x = "Thời gian",
    y = "Tỷ suất sinh lời (%)"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(
    labels = percent_format(accuracy = 0.5),
    breaks = seq(-0.02, 0.015, by = 0.005),
    minor_breaks = seq(-0.02, 0.015, by = 0.0025)
  ) +
  theme_academic

ggsave("output/figures/returns.png", plot = p_returns, width = 11, height = 6.5, dpi = 300)

# --- Biểu đồ 4: Phân phối tỷ suất sinh lời (Histogram & Density) ---
p_return_dist <- ggplot(df %>% filter(!is.na(returns)), aes(x = returns)) +
  geom_histogram(aes(y = ..density..), bins = 50, fill = "#3498DB", color = "white", alpha = 0.7) +
  geom_density(color = "#E74C3C", size = 1) +
  labs(
    title = "Phân Phối Tỷ Suất Sinh Lời Hằng Ngày Cổ Phiếu FPT",
    subtitle = "So sánh với phân phối chuẩn (Đường cong mật độ)",
    x = "Tỷ suất sinh lời",
    y = "Mật độ (Density)"
  ) +
  scale_x_continuous(labels = percent_format(accuracy = 0.1)) +
  theme_academic


ggsave("output/figures/return_distribution.png", plot = p_return_dist, width = 11, height = 6.5, dpi = 300)

print("--- Đã vẽ và xuất toàn bộ 4 biểu đồ nâng cao (300 DPI) vào mục output/figures/ ---")

# 7. ÉP RSTUDIO HIỂN THỊ BIỂU ĐỒ LÊN MÀNH HÌNH PLOTS ---------------------------
print(p_close)       # Hiện biểu đồ xu hướng giá lên xuống
print(p_volume)      # Hiện biểu đồ khối lượng giao dịch dạng cột
print(p_returns)     # Hiện biểu đồ tỷ suất sinh lời nâng cao
print(p_return_dist) # Hiện biểu đồ phân phối tỷ suất sinh lời

