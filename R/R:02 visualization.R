# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 02_visualization.R
# PURPOSE: Thống kê mô tả và trực quan hóa chuỗi dữ liệu FPT (2024 - 2026)
# ==============================================================================

# 1. KHAI BÁO THƯ VIỆN ---------------------------------------------------------
library(tidyverse)
library(scales) 

# 2. ĐỌC DỮ LIỆU ĐÃ LÀM SẠCH ---------------------------------------------------
data_path <- "data/processed/fpt_clean.csv"

if (!file.exists(data_path)) {
  stop("Không tìm thấy file fpt_clean.csv! Vui lòng chạy file R/01_data_cleaning.R trước.")
}

df <- read.csv(data_path)

# Ép lại định dạng ngày tháng để vẽ biểu đồ không bị lỗi trục X
df$time <- as.Date(df$time)

# Tính toán tỷ suất sinh lời hằng ngày (daily returns) dựa trên cột close viết thường
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
print("--- Đã xuất báo cáo Missing Values thành công ---")

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
print("--- Đã xuất bảng Thống kê mô tả thành công ---")

# 5. TRỰC QUAN HÓA DỮ LIỆU (VẼ BIỂU ĐỒ) ---------------------------------------
if (!dir.exists("output/figures")) dir.create("output/figures", recursive = TRUE)

# Thiết lập phông nền, cỡ chữ chung chuẩn học thuật cho biểu đồ
theme_set(theme_minimal() + 
            theme(plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
                  plot.subtitle = element_text(size = 10, hjust = 0.5),
                  axis.title = element_text(face = "bold", size = 10),
                  panel.grid.minor = element_blank()))

# --- Biểu đồ 1: Biểu đồ Giá đóng cửa (Close Price) ---
p_close <- ggplot(df, aes(x = time, y = close)) +
  geom_line(color = "#0056B3", linewidth = 0.8) +
  labs(
    title = "Xu Hướng Giá Đóng Cửa Cổ Phiếu FPT",
    subtitle = paste("Giai đoạn lịch sử:", min(df$time), "đến", max(df$time)),
    x = "Thời gian",
    y = "Giá đóng cửa (VNĐ)"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(labels = comma) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))

ggsave("output/figures/close_price.png", plot = p_close, width = 10, height = 6, dpi = 300)

# --- Biểu đồ 2: Biểu đồ Khối lượng giao dịch (Volume) ---
p_volume <- ggplot(df, aes(x = time, y = volume)) +
  geom_bar(stat = "identity", fill = "#28A745", alpha = 0.6) +
  labs(
    title = "Khối Lượng Giao Dịch Cổ Phiếu FPT Qua Thời Gian",
    subtitle = paste("Giai đoạn lịch sử:", min(df$time), "đến", max(df$time)),
    x = "Thời gian",
    y = "Khối lượng giao dịch (Cổ phiếu)"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(labels = comma) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))

ggsave("output/figures/volume.png", plot = p_volume, width = 10, height = 6, dpi = 300)

# --- Biểu đồ 3: Biểu đồ Tỷ suất sinh lời (Returns) ---
p_returns <- ggplot(df %>% filter(!is.na(returns)), aes(x = time, y = returns)) +
  geom_line(color = "#DC3545", linewidth = 0.4) +
  labs(
    title = "Biến Động Tỷ Suất Sinh Lời Hằng Ngày Của Cổ Phiếu FPT",
    subtitle = "Daily Returns (Kiểm tra hiện tượng biến động cụm - Volatility Clustering)",
    x = "Thời gian",
    y = "Tỷ suất sinh lời"
  ) +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months") +
  scale_y_continuous(labels = percent) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))

ggsave("output/figures/returns.png", plot = p_returns, width = 10, height = 6, dpi = 300)

print("--- Đã vẽ và xuất toàn bộ 3 biểu đồ (300 DPI) vào mục output/figures/ ---")
# Thêm 3 dòng này vào cuối cùng file R/02 để ép RStudio hiển thị biểu đồ lên màn hình:
print(p_close)   # Hiện biểu đồ đường lên xuống của Giá đóng cửa
print(p_volume)  # Hiện biểu đồ cột của Khối lượng
print(p_returns) # Hiện biểu đồ răng cưa của Tỷ suất sinh lời