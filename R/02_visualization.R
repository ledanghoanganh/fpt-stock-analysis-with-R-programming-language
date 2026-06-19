# 02_visualization.R
source("R/00_config.R")
library(scales)
library(forecast)

if (!file.exists(CLEAN_DATA_PATH)) {
  stop("Chạy R/01_data_cleaning.R trước.")
}

df <- readr::read_csv(CLEAN_DATA_PATH, show_col_types = FALSE) %>%
  mutate(
    date = as.Date(date),
    weekday = factor(
      lubridate::wday(date, week_start = 1),
      levels = 1:5,
      labels = c("Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu")
    )
  )

missing_report <- tibble::tibble(
  variable = names(df),
  missing_count = colSums(is.na(df)),
  missing_percentage = 100 * missing_count / nrow(df)
)
readr::write_csv(missing_report, file.path(TABLE_DIR, "missing_values.csv"))

summary_table <- tibble::tibble(
  variable = c("close", "volume", "return"),
  count = c(sum(!is.na(df$close)), sum(!is.na(df$volume)), sum(!is.na(df$return))),
  mean = c(mean(df$close), mean(df$volume), mean(df$return, na.rm = TRUE)),
  median = c(median(df$close), median(df$volume), median(df$return, na.rm = TRUE)),
  sd = c(sd(df$close), sd(df$volume), sd(df$return, na.rm = TRUE)),
  min = c(min(df$close), min(df$volume), min(df$return, na.rm = TRUE)),
  max = c(max(df$close), max(df$volume), max(df$return, na.rm = TRUE))
)
readr::write_csv(summary_table, file.path(TABLE_DIR, "data_summary.csv"))

theme_project <- ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
    plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "grey35"),
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    panel.grid.minor = ggplot2::element_blank(),
    legend.position = "bottom"
  )

save_plot <- function(filename, plot, width = 10, height = 6) {
  ggplot2::ggsave(
    file.path(FIGURE_DIR, filename), plot,
    width = width, height = height, dpi = 300, bg = "white"
  )
}

p_close <- ggplot2::ggplot(df, ggplot2::aes(date, close)) +
  ggplot2::geom_line(color = "#1565C0", linewidth = 0.6) +
  ggplot2::scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ggplot2::scale_y_continuous(labels = scales::label_number(big.mark = ",")) +
  ggplot2::labs(
    title = "Giá đóng cửa điều chỉnh của cổ phiếu FPT",
    subtitle = paste(min(df$date), "đến", max(df$date)),
    x = "Năm", y = "Giá đóng cửa điều chỉnh (VND)"
  ) + theme_project
save_plot("close_price.png", p_close)

p_volume <- ggplot2::ggplot(df, ggplot2::aes(date, volume)) +
  ggplot2::geom_col(fill = "#2E7D32", width = 1) +
  ggplot2::scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  ggplot2::labs(
    title = "Khối lượng giao dịch cổ phiếu FPT",
    x = "Năm", y = "Khối lượng"
  ) + theme_project
save_plot("volume.png", p_volume)

return_df <- df %>% filter(!is.na(return))

p_returns <- ggplot2::ggplot(return_df, ggplot2::aes(date, return)) +
  ggplot2::geom_line(color = "#B71C1C", linewidth = 0.35) +
  ggplot2::geom_hline(yintercept = 0, color = "grey40") +
  ggplot2::scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ggplot2::scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
  ggplot2::labs(
    title = "Lợi suất log hằng ngày của cổ phiếu FPT",
    subtitle = "Các cụm biên độ lớn gợi ý phương sai thay đổi theo thời gian",
    x = "Năm", y = "Log return"
  ) + theme_project
save_plot("returns.png", p_returns)

return_mean <- mean(return_df$return)
return_sd <- sd(return_df$return)
p_distribution <- ggplot2::ggplot(return_df, ggplot2::aes(return)) +
  ggplot2::geom_histogram(
    ggplot2::aes(y = after_stat(density)),
    bins = 60, fill = "#64B5F6", color = "white"
  ) +
  ggplot2::geom_density(color = "#D32F2F", linewidth = 0.8) +
  ggplot2::stat_function(
    fun = dnorm,
    args = list(mean = return_mean, sd = return_sd),
    color = "#212121", linetype = "dashed", linewidth = 0.8
  ) +
  ggplot2::scale_x_continuous(labels = scales::label_percent(accuracy = 1)) +
  ggplot2::labs(
    title = "Phân phối lợi suất log hằng ngày",
    subtitle = "Đỏ: mật độ thực nghiệm; đen đứt nét: phân phối chuẩn cùng mean và SD",
    x = "Log return", y = "Mật độ"
  ) + theme_project
save_plot("return_distribution.png", p_distribution)

p_qq <- ggplot2::ggplot(return_df, ggplot2::aes(sample = return)) +
  ggplot2::stat_qq(color = "#1565C0", alpha = 0.5) +
  ggplot2::stat_qq_line(color = "#D32F2F") +
  ggplot2::labs(
    title = "QQ-plot của lợi suất log",
    subtitle = "Độ lệch ở hai đuôi cho thấy cần cân nhắc phân phối đuôi dày",
    x = "Phân vị chuẩn lý thuyết", y = "Phân vị mẫu"
  ) + theme_project
save_plot("qqplot_return.png", p_qq)

p_squared <- ggplot2::ggplot(return_df, ggplot2::aes(date, return^2)) +
  ggplot2::geom_line(color = "#6A1B9A", linewidth = 0.35) +
  ggplot2::scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ggplot2::labs(
    title = "Bình phương lợi suất log",
    subtitle = "Dùng để quan sát volatility clustering",
    x = "Năm", y = expression(return^2)
  ) + theme_project
save_plot("squared_returns.png", p_squared)

p_weekday <- ggplot2::ggplot(return_df, ggplot2::aes(weekday, return)) +
  ggplot2::geom_boxplot(fill = "#80CBC4", outlier.alpha = 0.25) +
  ggplot2::scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
  ggplot2::labs(
    title = "Phân phối lợi suất theo ngày trong tuần",
    subtitle = "Chỉ dùng làm bằng chứng thăm dò cho mùa vụ tuần",
    x = NULL, y = "Log return"
  ) + theme_project
save_plot("return_by_weekday.png", p_weekday)

png(file.path(FIGURE_DIR, "acf_return.png"), width = 1800, height = 1100, res = 180)
forecast::Acf(return_df$return, lag.max = 40, main = "ACF của lợi suất log")
dev.off()

png(file.path(FIGURE_DIR, "pacf_return.png"), width = 1800, height = 1100, res = 180)
forecast::Pacf(return_df$return, lag.max = 40, main = "PACF của lợi suất log")
dev.off()

message("Đã xuất bảng và 9 biểu đồ vào output/.")