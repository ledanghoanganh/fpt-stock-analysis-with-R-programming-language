# MODULE 01 - LÀM SẠCH DỮ LIỆU
source("R/00_config.R")

# Sáu cột này là hợp đồng dữ liệu giữa notebook và pipeline R.
raw_columns <- c("date", "open", "high", "low", "close", "volume")
if (!file.exists(RAW_DATA_PATH)) stop("Không tìm thấy ", RAW_DATA_PATH)

# Đọc raw, chuẩn hóa tên cột rồi xác nhận schema trước khi tính toán.
raw <- readr::read_csv(RAW_DATA_PATH, show_col_types = FALSE)
names(raw) <- tolower(trimws(names(raw)))
assert_columns(raw, raw_columns, "Dữ liệu thô")

# Chỉ giữ schema chính thức, ép kiểu và sắp xếp theo thời gian.
checked <- raw %>%
  transmute(
    date = as.Date(date),
    across(all_of(raw_columns[-1]), as.numeric)
  ) %>%
  arrange(date)

# Bỏ qua chênh lệch floating-point nhỏ hơn 1e-8 khi kiểm tra quan hệ OHLC.
OHLC_TOLERANCE <- 1e-8

#' Phát hiện hàng có high thấp hơn open hoặc close
#'
#' @param data Bảng có các cột `open`, `high` và `close`.
#' @return Logical vector; `TRUE` tại hàng vi phạm vượt tolerance.
invalid_high <- function(data) data$high + OHLC_TOLERANCE < pmax(data$open, data$close)

#' Phát hiện hàng có low cao hơn open hoặc close
#'
#' @param data Bảng có các cột `open`, `low` và `close`.
#' @return Logical vector; `TRUE` tại hàng vi phạm vượt tolerance.
invalid_low <- function(data) data$low - OHLC_TOLERANCE > pmin(data$open, data$close)

# Tạo một hàng quality report cho mỗi điều kiện để dễ audit và trình bày.
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

# Loại các hàng không có giao dịch trước khi kiểm tra/sửa OHLC cho model input.
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

# Các lỗi này làm dữ liệu không còn đáng tin, vì vậy pipeline phải dừng.
fatal_checks <- c(
  "invalid_date", "duplicate_date", "missing_ohlcv",
  "non_positive_price", "negative_volume"
)
if (any(quality_report$count[quality_report$check %in% fatal_checks] > 0)) {
  print(quality_report)
  stop("Dữ liệu thô có lỗi nghiêm trọng; không được chạy mô hình.")
}

# Sửa đúng các quan hệ OHLC vượt tolerance, rồi tạo log-price và log return.
clean <- nonzero %>%
  distinct(date, .keep_all = TRUE) %>%
  arrange(date) %>%
  mutate(
    high = if_else(invalid_high(pick(everything())), pmax(open, high, close), high),
    low = if_else(invalid_low(pick(everything())), pmin(open, low, close), low),
    log_close = log(close),
    return = log_close - lag(log_close)
  )

# Assertions biến các giả định cuối thành điều kiện máy có thể kiểm chứng.
if (nrow(clean) < 500) stop("Dữ liệu sạch có quá ít quan sát.")
if (sum(is.na(clean$return)) != 1) stop("Return phải có đúng một NA ở dòng đầu.")
if (anyDuplicated(clean$date)) stop("Dữ liệu sạch còn ngày trùng.")
if (any(invalid_high(clean), na.rm = TRUE) || any(invalid_low(clean), na.rm = TRUE)) {
  stop("Dữ liệu sạch còn vi phạm quan hệ OHLC.")
}

# Đây là input duy nhất cho EDA, forecast và GARCH.
readr::write_csv(clean, CLEAN_DATA_PATH, na = "NA")
message(
  "Hoàn tất cleaning: ", nrow(checked), " raw -> ", nrow(clean),
  " clean; loại ", sum(checked$volume == 0), " zero-volume; sửa ",
  sum(repair_rows), " OHLC row."
)
