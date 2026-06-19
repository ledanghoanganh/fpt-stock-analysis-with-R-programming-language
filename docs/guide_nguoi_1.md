# Hướng dẫn cầm tay chỉ việc cho Thành viên 1

> Phạm vi: nguồn dữ liệu, làm sạch, kiểm tra chất lượng, trực quan hóa và viết phần Data/Visualization.  
> Dành cho người chỉ quen dùng ChatGPT trên web. Không cần tự nghĩ code, nhưng phải tự chạy, đọc kết quả và kiểm tra checklist.  
> Khi hoàn thành tài liệu này, Người 2 và Người 3 nhận được một bộ dữ liệu đã chốt để xây dựng mô hình.

## 0. Kết quả cuối cùng phải bàn giao

Người 1 chỉ được xem là hoàn thành khi repository có đủ:

```text
notebooks/01_scrape_fpt_colab.ipynb
data/raw/FPT_stock_data.csv
data/processed/fpt_clean.csv
data/README_data.md
R/01_data_cleaning.R
R/02_visualization.R
output/tables/data_quality_report.csv
output/tables/data_summary.csv
output/tables/missing_values.csv
output/figures/close_price.png
output/figures/volume.png
output/figures/returns.png
output/figures/return_distribution.png
output/figures/qqplot_return.png
output/figures/acf_return.png
output/figures/pacf_return.png
output/figures/squared_returns.png
output/figures/return_by_weekday.png
report/sections/02_data.md
report/sections/03_visualization.md
```

Quy ước dữ liệu bàn giao:

- Nguồn duy nhất: **Yahoo Finance**, mã `FPT.VN`.
- Khoảng dữ liệu: `2015-01-01` đến `2026-06-08`.
- `close` là giá đóng cửa đã điều chỉnh do notebook dùng `auto_adjust=True`.
- Chỉ giữ phiên có `volume > 0`; các dòng ngày nghỉ/không giao dịch bị loại.
- Không có ngày trùng, ngày lỗi, giá không dương hoặc OHLC vô lý.
- Biến lợi suất duy nhất là `return = log(close_t) - log(close_{t-1})`.
- Dòng đầu tiên của `return` được phép là `NA`; các dòng còn lại không được thiếu.

Nếu nhóm hoặc giảng viên bắt buộc dùng `vnstock`, dừng ở đây và hỏi trưởng nhóm. Không trộn Yahoo, TCBS và vnstock trong cùng báo cáo.

## 1. Công cụ cần mở

Mở bốn tab trình duyệt:

1. Repository GitHub của nhóm.
2. [Google Colab](https://colab.research.google.com/) để tải dữ liệu.
3. ChatGPT web để hỏi khi gặp lỗi.
4. Posit Cloud hoặc RStudio trên máy để chạy R.

Tải repository về máy bằng nút **Code > Download ZIP**, giải nén vào một thư mục dễ tìm. Không sửa trực tiếp file của Người 2 hoặc Người 3.

## 2. Prompt mở đầu dành cho ChatGPT

Mở một cuộc trò chuyện ChatGPT mới, dán prompt sau:

```text
Bạn là trợ giảng môn Lập trình R. Tôi là người mới, đang phụ trách phần dữ liệu và trực quan hóa của dự án phân tích cổ phiếu FPT.

Quy ước cố định của dự án:
- Nguồn: Yahoo Finance, ticker FPT.VN.
- Giai đoạn: 2015-01-01 đến hết 2026-06-08.
- close là adjusted close do yfinance auto_adjust=True.
- File thô có đúng 6 cột: date, open, high, low, close, volume.
- File sạch loại volume <= 0, loại ngày trùng/lỗi, kiểm tra OHLC, tạo log_close và log return tên return.
- Không được tự bịa số liệu hoặc kết quả chạy.
- Không đổi tên file/output nếu tôi chưa yêu cầu.

Khi tôi gửi ảnh lỗi, hãy giải thích bằng tiếng Việt rất đơn giản, chỉ rõ tôi phải mở file nào, tìm dòng nào và thay bằng đoạn nào. Luôn yêu cầu tôi chạy lại và gửi kết quả, không được nói đã thành công khi tôi chưa chạy.

Hãy trả lời: "Đã hiểu quy ước dữ liệu" và chờ yêu cầu tiếp theo.
```

Không dùng cùng cuộc chat để nhờ ChatGPT viết ARIMA/GARCH. Phạm vi Người 1 kết thúc trước phần mô hình.

## 3. Bước A - Tạo lại dữ liệu thô trên Google Colab

### A1. Tạo notebook

1. Vào Google Colab.
2. Chọn **File > New notebook**.
3. Đổi tên thành `01_scrape_fpt_colab.ipynb`.
4. Tạo một code cell, dán nguyên khối dưới đây.

```python
!pip -q install yfinance

from pathlib import Path
import pandas as pd
import yfinance as yf
from google.colab import files

TICKER = "FPT.VN"
START_DATE = "2015-01-01"
# yfinance không bao gồm end date, nên dùng ngày kế tiếp.
END_DATE_EXCLUSIVE = "2026-06-09"

raw = yf.download(
    TICKER,
    start=START_DATE,
    end=END_DATE_EXCLUSIVE,
    auto_adjust=True,
    progress=False,
    actions=False,
)

if raw.empty:
    raise RuntimeError("Yahoo Finance không trả về dữ liệu FPT.VN.")

# Một số phiên bản yfinance trả về MultiIndex.
if isinstance(raw.columns, pd.MultiIndex):
    raw.columns = raw.columns.get_level_values(0)

df = raw.reset_index().rename(columns={
    "Date": "date",
    "Open": "open",
    "High": "high",
    "Low": "low",
    "Close": "close",
    "Volume": "volume",
})

required = ["date", "open", "high", "low", "close", "volume"]
missing = [column for column in required if column not in df.columns]
if missing:
    raise RuntimeError(f"Thiếu cột sau khi tải: {missing}")

df = df[required].copy()
df["date"] = pd.to_datetime(df["date"]).dt.strftime("%Y-%m-%d")
for column in ["open", "high", "low", "close", "volume"]:
    df[column] = pd.to_numeric(df[column], errors="coerce")

df = df.sort_values("date").reset_index(drop=True)

print("Số dòng tải về:", len(df))
print("Giai đoạn:", df["date"].min(), "đến", df["date"].max())
print("Số ngày trùng:", df["date"].duplicated().sum())
print("Số dòng volume <= 0:", (df["volume"] <= 0).sum())
print(df.head())
print(df.tail())

assert df["date"].min() >= START_DATE
assert df["date"].max() <= "2026-06-08"
assert df["date"].duplicated().sum() == 0

output_name = "FPT_stock_data.csv"
df.to_csv(output_name, index=False)
files.download(output_name)
```

### A2. Chạy và kiểm tra

Nhấn nút tam giác bên trái cell. Chờ trình duyệt tải `FPT_stock_data.csv`.

Kết quả hợp lệ phải có:

- `Số ngày trùng: 0`.
- Ngày cuối không vượt quá `2026-06-08`.
- Sáu cột đúng tên và không có `Adj Close`.
- File CSV được tải xuống máy.

Số dòng có thể thay đổi nhẹ nếu Yahoo hiệu chỉnh lịch sử. Không sửa số bằng tay để ép về 2,960.

Nếu lỗi, dán prompt này vào ChatGPT và đính kèm ảnh màn hình:

```text
Tôi đang làm Bước A trong guide Người 1. Đây là toàn bộ lỗi Google Colab của đoạn yfinance. Hãy tìm nguyên nhân, đưa đúng đoạn cần thay, và giữ nguyên schema date/open/high/low/close/volume. Không đổi nguồn dữ liệu và không bịa kết quả.
```

### A3. Đưa file vào project

Trong thư mục đã giải nén, thay file:

```text
data/raw/FPT_stock_data.csv
```

bằng file vừa tải. Không mở rồi Save bằng Excel vì Excel có thể đổi định dạng ngày/số.

## 4. Bước B - Thay mã làm sạch dữ liệu

Mở `R/01_data_cleaning.R`, chọn toàn bộ nội dung và thay bằng đoạn sau:

```r
# 01_data_cleaning.R
source("R/00_config.R")

required_columns <- c("date", "open", "high", "low", "close", "volume")

if (!file.exists(RAW_DATA_PATH)) {
  stop("Không tìm thấy data/raw/FPT_stock_data.csv")
}

df_raw <- readr::read_csv(RAW_DATA_PATH, show_col_types = FALSE)
names(df_raw) <- tolower(trimws(names(df_raw)))

missing_columns <- setdiff(required_columns, names(df_raw))
if (length(missing_columns) > 0) {
  stop("Dữ liệu thô thiếu cột: ", paste(missing_columns, collapse = ", "))
}

df_checked <- df_raw %>%
  transmute(
    date = as.Date(date),
    open = as.numeric(open),
    high = as.numeric(high),
    low = as.numeric(low),
    close = as.numeric(close),
    volume = as.numeric(volume)
  ) %>%
  arrange(date)

quality_report <- tibble::tibble(
  check = c(
    "raw_rows",
    "invalid_date",
    "duplicate_date",
    "missing_ohlcv",
    "non_positive_price",
    "negative_volume",
    "zero_volume",
    "high_below_open_or_close",
    "low_above_open_or_close"
  ),
  count = c(
    nrow(df_checked),
    sum(is.na(df_checked$date)),
    sum(duplicated(df_checked$date)),
    sum(!complete.cases(df_checked[, c("open", "high", "low", "close", "volume")])),
    sum(df_checked$open <= 0 | df_checked$high <= 0 |
          df_checked$low <= 0 | df_checked$close <= 0, na.rm = TRUE),
    sum(df_checked$volume < 0, na.rm = TRUE),
    sum(df_checked$volume == 0, na.rm = TRUE),
    sum(df_checked$high < pmax(df_checked$open, df_checked$close), na.rm = TRUE),
    sum(df_checked$low > pmin(df_checked$open, df_checked$close), na.rm = TRUE)
  )
)

readr::write_csv(quality_report, file.path(TABLE_DIR, "data_quality_report.csv"))

fatal_checks <- quality_report %>%
  filter(check %in% c(
    "invalid_date", "duplicate_date", "missing_ohlcv",
    "non_positive_price", "negative_volume",
    "high_below_open_or_close", "low_above_open_or_close"
  ))

if (any(fatal_checks$count > 0)) {
  print(quality_report)
  stop("Dữ liệu thô không đạt kiểm tra chất lượng. Không được chạy model.")
}

# volume == 0 không phải phiên giao dịch hữu ích và tạo return bằng 0 giả.
df_clean <- df_checked %>%
  filter(volume > 0) %>%
  distinct(date, .keep_all = TRUE) %>%
  arrange(date) %>%
  mutate(
    log_close = log(close),
    return = log_close - lag(log_close)
  )

if (nrow(df_clean) < 500) {
  stop("Dữ liệu sạch có quá ít quan sát.")
}
if (sum(is.na(df_clean$return)) != 1) {
  stop("Cột return phải chỉ có đúng một NA ở dòng đầu tiên.")
}
if (anyDuplicated(df_clean$date) > 0) {
  stop("Dữ liệu sạch còn ngày trùng.")
}

readr::write_csv(df_clean, CLEAN_DATA_PATH, na = "NA")

message("Hoàn tất làm sạch dữ liệu")
message("Raw rows: ", nrow(df_checked))
message("Removed zero-volume rows: ", sum(df_checked$volume == 0))
message("Clean rows: ", nrow(df_clean))
message("Period: ", min(df_clean$date), " to ", max(df_clean$date))
```

## 5. Bước C - Thay mã trực quan hóa

Mở `R/02_visualization.R`, chọn toàn bộ nội dung và thay bằng đoạn sau:

```r
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
  ggplot2::scale_y_continuous(labels = scales::label_number_si()) +
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
```

## 6. Bước D - Chạy R bằng giao diện

### Cách dùng RStudio trên máy

1. Mở file `FPT_Stock_TimeSeries.Rproj` bằng RStudio.
2. Chọn **Session > Restart R**.
3. Trong ô Console, dán:

```r
install.packages(c("tidyverse", "lubridate", "scales", "forecast"))
```

Chỉ cần cài một lần. Sau đó chạy:

```r
source("R/01_data_cleaning.R")
source("R/02_visualization.R")
```

### Cách dùng Posit Cloud

1. Tạo project mới tại Posit Cloud.
2. Upload toàn bộ project dưới dạng ZIP.
3. Mở project và chạy hai lệnh `source()` giống phía trên.
4. Sau khi chạy xong, chọn các file output và tải về để đưa lại vào repository trên máy.

### Kết quả Console phải thấy

```text
Hoàn tất làm sạch dữ liệu
Raw rows: ...
Removed zero-volume rows: ...
Clean rows: ...
Period: ... to ...
Đã xuất bảng và 9 biểu đồ vào output/.
```

Không điền các dấu `...` bằng tay; đó là kết quả R tự in.

Nếu R báo lỗi, dán prompt sau vào cuộc chat đã mở và đính kèm ảnh lỗi cùng file R:

```text
Tôi đang chạy Bước D của guide Người 1. Đây là ảnh Console và file R hiện tại. Hãy xác định lỗi đầu tiên, giải thích đơn giản và đưa đúng đoạn cần sửa. Không viết lại phần mô hình, không đổi schema, không bỏ các validation để né lỗi. Sau khi sửa hãy cho tôi đúng hai lệnh source() để chạy lại.
```

## 7. Bước E - Kiểm tra dữ liệu trước khi bàn giao

Mở Console RStudio và dán nguyên khối:

```r
library(tidyverse)

d <- read_csv("data/processed/fpt_clean.csv", show_col_types = FALSE)
stopifnot(
  identical(names(d), c("date", "open", "high", "low", "close", "volume", "log_close", "return")),
  nrow(d) >= 500,
  sum(is.na(d$return)) == 1,
  is.na(d$return[1]),
  sum(duplicated(d$date)) == 0,
  all(d$volume > 0),
  all(d$open > 0),
  all(d$high >= pmax(d$open, d$close)),
  all(d$low <= pmin(d$open, d$close)),
  max(abs(d$return[-1] - diff(log(d$close)))) < 1e-10
)

cat("DATA HANDOFF PASSED\n")
cat("Rows:", nrow(d), "\n")
cat("Period:", min(d$date), "to", max(d$date), "\n")
```

Chỉ bàn giao nếu Console in:

```text
DATA HANDOFF PASSED
```

Chụp màn hình kết quả này để đưa vào mô tả pull request.

## 8. Bước F - Soạn tài liệu bằng ChatGPT nhưng không bịa số

### F1. Cập nhật `data/README_data.md`

Upload ba file sau vào ChatGPT:

- `data/processed/fpt_clean.csv`
- `output/tables/data_quality_report.csv`
- `output/tables/data_summary.csv`

Dán prompt:

```text
Hãy viết lại data/README_data.md bằng tiếng Việt dựa CHỈ trên ba file tôi đã upload.

Bắt buộc có:
1. Nguồn Yahoo Finance, ticker FPT.VN, ngày truy cập hôm nay.
2. Giải thích auto_adjust=True và close là giá đóng cửa điều chỉnh.
3. Khoảng ngày và số quan sát lấy trực tiếp từ CSV.
4. Schema 8 cột của fpt_clean.csv.
5. Số dòng volume bằng 0 đã loại, lấy từ data_quality_report.csv.
6. Công thức log_close và return.
7. Hạn chế của nguồn và lưu ý dữ liệu có thể được nhà cung cấp điều chỉnh lịch sử.

Không được bịa nguồn vnstock/TCBS, không được dùng số cũ 2,960 nếu file mới khác, không được đưa nhận định đầu tư. Trả về toàn bộ Markdown hoàn chỉnh trong một code block.
```

Dán kết quả vào `data/README_data.md`.

### F2. Viết `report/sections/02_data.md`

Trong cùng chat có ba CSV, dán:

```text
Viết report/sections/02_data.md cho báo cáo học thuật môn R.

Chỉ dùng số trong các CSV đã upload. Nội dung gồm: nguồn và phạm vi, mô tả biến, quy trình làm sạch bằng R, kiểm tra chất lượng, xử lý volume=0, missing values, thống kê mô tả và hạn chế dữ liệu. Dùng giọng văn thận trọng. Không nói đã loại cuối tuần nếu code chỉ loại volume <= 0. Không bịa nguyên nhân kinh tế. Trả về Markdown hoàn chỉnh trong một code block.
```

### F3. Viết `report/sections/03_visualization.md`

Upload chín hình vừa tạo và dán:

```text
Viết report/sections/03_visualization.md dựa trên đúng các hình tôi upload.

Với mỗi hình: ghi đúng tên file, mô tả điều nhìn thấy, ý nghĩa thống kê và giới hạn của suy luận. Phân biệt "quan sát/gợi ý" với "chứng minh". Không suy diễn COVID, quỹ đầu tư, chip, chính sách hay tin tức nếu không có nguồn. Với histogram và QQ-plot, giải thích vì sao Student-t có thể đáng thử nhưng không kết luận trước khi fit. Với weekday boxplot, không tuyên bố seasonality nếu khác biệt không rõ. Kết thúc bằng các giả thuyết cần kiểm định ở bước mô hình. Trả về Markdown hoàn chỉnh trong một code block.
```

### F4. Kiểm tra chéo văn bản

Upload ba file Markdown mới và `fpt_clean.csv`, rồi dán:

```text
Audit ba file Markdown này với fpt_clean.csv. Lập bảng mọi con số, tên cột, nguồn, khoảng ngày và tên hình không khớp. Không viết lại ngay. Nếu không có lỗi, ghi "CONTENT CHECK PASSED". Nếu có lỗi, đưa câu gốc và câu sửa tương ứng.
```

Chỉ chuyển sang bước commit khi nhận `CONTENT CHECK PASSED` và đã tự mở các file kiểm tra.

## 9. Bước G - Commit bằng giao diện GitHub

Không cần terminal. Làm như sau:

1. Vào repository GitHub.
2. Chọn nhánh dành cho Người 1. Nếu chưa có, bấm danh sách branch, nhập `person1-data-visualization`, chọn **Create branch**.
3. Với file văn bản/code: mở file, bấm biểu tượng bút chì, dán nội dung mới, chọn **Commit changes**.
4. Với CSV/PNG/notebook: vào đúng thư mục, chọn **Add file > Upload files**, kéo file vào và commit.
5. Không upload file ngoài danh sách ở Mục 0.

Nên chia thành bốn commit thật, phản ánh đúng quá trình làm:

```text
Reproduce FPT data from Yahoo Finance
Add validated FPT data cleaning pipeline
Improve exploratory visualizations and data checks
Document FPT data and visualization findings
```

Không tạo commit giả chỉ để tăng số đóng góp. GitHub đã ghi nhận đóng góp thật khi Người 1 chạy, kiểm tra, sửa và commit phần mình phụ trách.

Sau đó mở Pull Request với nội dung:

```text
## Phạm vi
- Chuẩn hóa nguồn Yahoo Finance và notebook tái lập dữ liệu.
- Làm sạch, loại phiên volume <= 0 và kiểm tra OHLC/ngày trùng/missing.
- Tạo dữ liệu sạch, bảng quality report và 9 biểu đồ EDA.
- Cập nhật tài liệu Data và Visualization.

## Kiểm thử
- [x] R/01_data_cleaning.R chạy thành công
- [x] R/02_visualization.R chạy thành công
- [x] DATA HANDOFF PASSED
- [x] CONTENT CHECK PASSED

## Dữ liệu bàn giao
- Số dòng sạch: ĐIỀN KẾT QUẢ THẬT
- Giai đoạn: ĐIỀN KẾT QUẢ THẬT
- Số dòng volume=0 đã loại: ĐIỀN KẾT QUẢ THẬT

## Lưu ý cho Người 2 và Người 3
Sau khi merge, phải chạy lại toàn bộ ARIMA/ETS/GARCH vì số dòng và tập train/test có thể thay đổi.
```

## 10. Tin nhắn bàn giao cho nhóm

Sau khi pull request được merge, gửi vào nhóm:

```text
Mình đã hoàn thành phần dữ liệu và trực quan hóa.

Nguồn đã chốt: Yahoo Finance, FPT.VN, auto-adjusted.
File model input: data/processed/fpt_clean.csv
Validation: DATA HANDOFF PASSED
Số dòng sạch: [điền số thật]
Giai đoạn: [điền ngày thật]
Số dòng volume=0 đã loại: [điền số thật]

Người 2 và Người 3 vui lòng pull commit mới và chạy lại model từ đầu, không sử dụng các CSV/model/output cũ.
```

## 11. Checklist cuối dành cho Người 1

- [ ] Notebook tự tải được dữ liệu và có nguồn rõ ràng.
- [ ] Không còn chỗ nào trong phần mình ghi vnstock hoặc TCBS.
- [ ] `fpt_clean.csv` chỉ có 8 cột chuẩn.
- [ ] `DATA HANDOFF PASSED` xuất hiện khi chạy validation.
- [ ] `data_quality_report.csv` tồn tại và không có fatal check lớn hơn 0.
- [ ] Có đủ 9 hình, trục thời gian đọc được, không có nhãn chồng kín.
- [ ] README Data và hai section báo cáo dùng số mới, không dùng số chép từ báo cáo cũ.
- [ ] Không có câu khuyến nghị mua/bán hoặc suy diễn nguyên nhân không có nguồn.
- [ ] Có bốn commit đúng nội dung công việc và một pull request.
- [ ] Người 2 hoặc Người 3 tải branch về và chạy lại `R/01_data_cleaning.R` thành công.

Khi tất cả ô trên được đánh dấu, nhiệm vụ của Người 1 kết thúc. Sau đó chỉ cần học cách giải thích: nguồn dữ liệu, adjusted price, log return, missing values, biểu đồ phân phối, ACF/PACF và volatility clustering để chuẩn bị thuyết trình.

## 12. Prompt học nhanh trước khi báo cáo

Upload `data/README_data.md`, hai section báo cáo và các hình, rồi dán:

```text
Hãy đóng vai giảng viên vấn đáp phần Data và Visualization của đồ án này.

1. Dạy tôi bằng ngôn ngữ rất đơn giản: adjusted close, log return, vì sao loại volume=0, histogram, QQ-plot, ACF/PACF và volatility clustering.
2. Tạo 15 câu hỏi giảng viên có thể hỏi kèm câu trả lời ngắn 30-45 giây.
3. Chỉ dùng nội dung trong file tôi upload; chỉ ra câu nào tôi không nên nói vì vượt quá bằng chứng.
4. Cuối cùng hỏi từng câu một để tôi luyện trả lời, không đưa đáp án trước.
```

