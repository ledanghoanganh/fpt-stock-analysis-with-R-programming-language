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

raw_high_error <- sum(df_checked$high < pmax(df_checked$open, df_checked$close), na.rm = TRUE)
raw_low_error <- sum(df_checked$low > pmin(df_checked$open, df_checked$close), na.rm = TRUE)

df_nonzero_volume <- df_checked %>%
  filter(volume > 0)

nonzero_high_error <- sum(df_nonzero_volume$high < pmax(df_nonzero_volume$open, df_nonzero_volume$close), na.rm = TRUE)
nonzero_low_error <- sum(df_nonzero_volume$low > pmin(df_nonzero_volume$open, df_nonzero_volume$close), na.rm = TRUE)

quality_report <- tibble::tibble(
  check = c(
    "raw_rows",
    "invalid_date",
    "duplicate_date",
    "missing_ohlcv",
    "non_positive_price",
    "negative_volume",
    "zero_volume",
    "raw_high_below_open_or_close",
    "raw_low_above_open_or_close",
    "high_below_open_or_close_after_volume_filter",
    "low_above_open_or_close_after_volume_filter",
    "ohlc_rows_repaired_after_volume_filter"
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
    raw_high_error,
    raw_low_error,
    nonzero_high_error,
    nonzero_low_error,
    sum(
      df_nonzero_volume$high < pmax(df_nonzero_volume$open, df_nonzero_volume$close) |
        df_nonzero_volume$low > pmin(df_nonzero_volume$open, df_nonzero_volume$close),
      na.rm = TRUE
    )
  )
)

readr::write_csv(quality_report, file.path(TABLE_DIR, "data_quality_report.csv"))

fatal_checks <- quality_report %>%
  filter(check %in% c(
    "invalid_date", "duplicate_date", "missing_ohlcv",
    "non_positive_price", "negative_volume"
  ))

if (any(fatal_checks$count > 0)) {
  print(quality_report)
  stop("Dữ liệu thô có lỗi nghiêm trọng. Không được chạy model.")
}

# Loại volume = 0 vì không phải phiên giao dịch hữu ích.
# Sau đó sửa OHLC để high/low bao phủ open, close trong dữ liệu sạch.
df_clean <- df_nonzero_volume %>%
  distinct(date, .keep_all = TRUE) %>%
  arrange(date) %>%
  mutate(
    high = pmax(open, high, low, close),
    low = pmin(open, high, low, close),
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
if (any(df_clean$high < pmax(df_clean$open, df_clean$close), na.rm = TRUE)) {
  stop("Dữ liệu sạch còn lỗi high.")
}
if (any(df_clean$low > pmin(df_clean$open, df_clean$close), na.rm = TRUE)) {
  stop("Dữ liệu sạch còn lỗi low.")
}

readr::write_csv(df_clean, CLEAN_DATA_PATH, na = "NA")

message("Hoàn tất làm sạch dữ liệu")
message("Raw rows: ", nrow(df_checked))
message("Removed zero-volume rows: ", sum(df_checked$volume == 0))
message("Repaired OHLC rows after volume filter: ", quality_report$count[quality_report$check == "ohlc_rows_repaired_after_volume_filter"])
message("Clean rows: ", nrow(df_clean))
message("Period: ", min(df_clean$date), " to ", max(df_clean$date))