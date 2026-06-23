# MODULE 02 - PHÂN TÍCH KHÁM PHÁ VÀ TRỰC QUAN HÓA
source("R/00_config.R")
require_packages(c("scales", "forecast"))
if (!file.exists(CLEAN_DATA_PATH)) stop("Hãy chạy R/01_data_cleaning.R trước.")

# Weekday chỉ phục vụ EDA; model input vẫn giữ schema tám cột trong CSV sạch.
data <- readr::read_csv(CLEAN_DATA_PATH, show_col_types = FALSE) %>%
  mutate(
    date = as.Date(date),
    weekday = factor(
      lubridate::wday(date, week_start = 1),
      levels = 1:5,
      labels = c("Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu")
    )
  )
returns <- filter(data, !is.na(return))

# Bảng missing cho biết số lượng và tỷ lệ NA của từng biến đang phân tích.
missing_table <- tibble(
  variable = names(data),
  missing_count = colSums(is.na(data)),
  missing_percentage = 100 * missing_count / nrow(data)
)
write_project_csv(missing_table, "missing_values.csv")

#' Tính sáu thống kê mô tả cho một biến số
#'
#' @param values Numeric vector; giá trị `NA` được loại trước khi tính.
#' @param name Tên biến sẽ xuất hiện trong cột `variable`.
#' @return Tibble một hàng gồm count, mean, median, sd, min và max.
summarise_variable <- function(values, name) {
  valid <- values[!is.na(values)]
  tibble(
    variable = name,
    count = length(valid),
    mean = mean(valid), median = median(valid), sd = sd(valid),
    min = min(valid), max = max(valid)
  )
}
summary_table <- bind_rows(
  summarise_variable(data$close, "close"),
  summarise_variable(data$volume, "volume"),
  summarise_variable(data$return, "return")
)
write_project_csv(summary_table, "data_summary.csv")

# Dùng một theme và một hàm save để mọi hình có định dạng thống nhất.
project_theme <- ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, color = "grey35"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )
#' Lưu một biểu đồ ggplot theo chuẩn chung của dự án
#'
#' @param name Tên file PNG trong `output/figures`.
#' @param plot Đối tượng ggplot cần lưu.
#' @param width Chiều rộng hình tính bằng inch.
#' @param height Chiều cao hình tính bằng inch.
#' @return Kết quả vô hình từ `ggsave()`.
#' @details Side effect: ghi PNG 300 DPI, nền trắng và ghi đè file cùng tên.
save_plot <- function(name, plot, width = 10, height = 6) {
  ggsave(file.path(FIGURE_DIR, name), plot, width = width, height = height,
         dpi = 300, bg = "white")
}

# Giá level cho thấy trend dài hạn; ADF ở script 03 mới kiểm định tính dừng.
save_plot("close_price.png", ggplot(data, aes(date, close)) +
  geom_line(color = "#1565C0", linewidth = 0.6) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(big.mark = ",")) +
  labs(title = "Giá đóng cửa điều chỉnh của cổ phiếu FPT",
       subtitle = paste(min(data$date), "đến", max(data$date)),
       x = "Năm", y = "Giá đóng cửa điều chỉnh (VND)") + project_theme)

# Volume mô tả thanh khoản và các quan sát cực trị theo thời gian.
save_plot("volume.png", ggplot(data, aes(date, volume)) +
  geom_col(fill = "#2E7D32", width = 1) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  labs(title = "Khối lượng giao dịch cổ phiếu FPT", x = "Năm", y = "Khối lượng") +
  project_theme)

# Return quanh 0 nhưng biên độ thay đổi theo thời gian, gợi ý volatility clustering.
save_plot("returns.png", ggplot(returns, aes(date, return)) +
  geom_line(color = "#B71C1C", linewidth = 0.35) +
  geom_hline(yintercept = 0, color = "grey40") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
  labs(title = "Lợi suất log hằng ngày của cổ phiếu FPT",
       subtitle = "Các cụm biên độ lớn gợi ý phương sai thay đổi theo thời gian",
       x = "Năm", y = "Log return") + project_theme)

# So sánh mật độ thực nghiệm với Normal có cùng mean và standard deviation.
save_plot("return_distribution.png", ggplot(returns, aes(return)) +
  geom_histogram(aes(y = after_stat(density)), bins = 60,
                 fill = "#64B5F6", color = "white") +
  geom_density(color = "#D32F2F", linewidth = 0.8) +
  stat_function(fun = dnorm,
                args = list(mean = mean(returns$return), sd = sd(returns$return)),
                color = "#212121", linetype = "dashed", linewidth = 0.8) +
  scale_x_continuous(labels = scales::label_percent(accuracy = 1)) +
  labs(title = "Phân phối lợi suất log hằng ngày",
       subtitle = "Đỏ: mật độ thực nghiệm; đen đứt nét: Normal cùng mean và SD",
       x = "Log return", y = "Mật độ") + project_theme)

# Q-Q plot làm rõ độ lệch ở hai đuôi so với phân phối Normal.
save_plot("qqplot_return.png", ggplot(returns, aes(sample = return)) +
  stat_qq(color = "#1565C0", alpha = 0.5) +
  stat_qq_line(color = "#D32F2F") +
  labs(title = "Q-Q plot của lợi suất log",
       subtitle = "Độ lệch ở hai đuôi gợi ý phân phối đuôi dày",
       x = "Phân vị Normal lý thuyết", y = "Phân vị mẫu") + project_theme)

# Bình phương bỏ dấu return để biểu diễn độ lớn biến động theo thời gian.
save_plot("squared_returns.png", ggplot(returns, aes(date, return^2)) +
  geom_line(color = "#6A1B9A", linewidth = 0.35) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Bình phương lợi suất log",
       subtitle = "Các spike theo cụm minh họa volatility clustering",
       x = "Năm", y = expression(return^2)) + project_theme)

#' Lưu biểu đồ ACF hoặc PACF bằng base graphics
#'
#' @param name Tên file PNG trong `output/figures`.
#' @param plot_function Hàm vẽ nhận vector return, ví dụ `forecast::Acf`.
#' @param title Tiêu đề hiển thị trên biểu đồ.
#' @return Không trả dữ liệu; hàm được gọi vì side effect tạo file PNG.
#' @details `on.exit()` bảo đảm thiết bị đồ họa được đóng kể cả khi hàm vẽ lỗi.
save_correlation_plot <- function(name, plot_function, title) {
  png(file.path(FIGURE_DIR, name), width = 1800, height = 1100, res = 180)
  on.exit(dev.off(), add = TRUE)
  plot_function(returns$return, lag.max = 40, main = title)
}
save_correlation_plot("acf_return.png", forecast::Acf, "ACF của lợi suất log")
save_correlation_plot("pacf_return.png", forecast::Pacf, "PACF của lợi suất log")

message("Đã xuất 2 bảng mô tả và 8 biểu đồ EDA.")
