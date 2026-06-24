source("R/00_config.R")

raw_columns <- c("date", "open", "high", "low", "close", "volume")
if (!file.exists(RAW_DATA_PATH)) stop("Không tìm thấy ", RAW_DATA_PATH)

raw <- readr::read_csv(RAW_DATA_PATH, show_col_types = FALSE)
names(raw) <- tolower(trimws(names(raw)))
assert_columns(raw, raw_columns, "Dữ liệu thô")

checked <- raw %>%
  transmute(
    date = as.Date(date),
    across(all_of(raw_columns[-1]), as.numeric)
  ) %>%
  arrange(date)

OHLC_TOLERANCE <- 1e-8
invalid_high <- function(data) data$high + OHLC_TOLERANCE < pmax(data$open, data$close)
invalid_low <- function(data) data$low - OHLC_TOLERANCE > pmin(data$open, data$close)

quality_report <- tibble(
  check = c(
    "raw_rows", "invalid_date", "duplicate_date", "missing_ohlcv",
    "non_positive_price", "negative_volume", "zero_volume",
    "raw_high_below_open_or_close", "raw_low_above_open_or_close"
  ),
  count = c(
    nrow(checked),
    sum(is.na(checked$date)),
    sum(duplicated(checked$date)),
    sum(!complete.cases(checked[raw_columns[-1]])),
    sum(rowSums(checked[c("open", "high", "low", "close")] <= 0, na.rm = TRUE) > 0),
    sum(checked$volume < 0, na.rm = TRUE),
    sum(checked$volume == 0, na.rm = TRUE),
    sum(invalid_high(checked), na.rm = TRUE),
    sum(invalid_low(checked), na.rm = TRUE)
  )
)

nonzero <- filter(checked, volume > 0)
repair_rows <- invalid_high(nonzero) | invalid_low(nonzero)
quality_report <- bind_rows(
  quality_report,
  tibble(
    check = c(
      "high_below_open_or_close_after_volume_filter",
      "low_above_open_or_close_after_volume_filter",
      "ohlc_rows_repaired_after_volume_filter"
    ),
    count = c(
      sum(invalid_high(nonzero), na.rm = TRUE),
      sum(invalid_low(nonzero), na.rm = TRUE),
      sum(repair_rows, na.rm = TRUE)
    )
  )
)
write_project_csv(quality_report, "data_quality_report.csv")

fatal_checks <- c(
  "invalid_date", "duplicate_date", "missing_ohlcv",
  "non_positive_price", "negative_volume"
)
if (any(quality_report$count[quality_report$check %in% fatal_checks] > 0)) {
  print(quality_report)
  stop("Dữ liệu thô có lỗi nghiêm trọng; không được chạy mô hình.")
}

clean <- nonzero %>%
  distinct(date, .keep_all = TRUE) %>%
  arrange(date) %>%
  mutate(
    high = if_else(invalid_high(pick(everything())), pmax(open, high, close), high),
    low = if_else(invalid_low(pick(everything())), pmin(open, low, close), low),
    log_close = log(close),
    return = log_close - lag(log_close)
  )

if (nrow(clean) < 500) stop("Dữ liệu sạch có quá ít quan sát.")
if (sum(is.na(clean$return)) != 1) stop("Return phải có đúng một NA ở dòng đầu.")
if (anyDuplicated(clean$date)) stop("Dữ liệu sạch còn ngày trùng.")
if (any(invalid_high(clean), na.rm = TRUE) || any(invalid_low(clean), na.rm = TRUE)) {
  stop("Dữ liệu sạch còn vi phạm quan hệ OHLC.")
}

readr::write_csv(clean, CLEAN_DATA_PATH, na = "NA")
message(
  "Hoàn tất cleaning: ", nrow(checked), " raw -> ", nrow(clean),
  " clean; loại ", sum(checked$volume == 0), " zero-volume; sửa ",
  sum(repair_rows), " OHLC row."
)
