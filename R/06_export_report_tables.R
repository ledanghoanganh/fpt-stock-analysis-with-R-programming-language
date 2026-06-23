# MODULE 06 - XUẤT WORKBOOK KIỂM TRA
source("R/00_config.R")
require_packages("openxlsx")

tables <- list(
  Thong_Ke_Mo_Ta = read.csv(file.path(TABLE_DIR, "data_summary.csv"),
                            check.names = FALSE),
  Missing_Values = read.csv(file.path(TABLE_DIR, "missing_values.csv"),
                            check.names = FALSE),
  So_Sanh_Mo_Hinh = read.csv(file.path(TABLE_DIR, "model_comparison.csv"),
                             check.names = FALSE),
  Tham_So_GARCH = read.csv(file.path(TABLE_DIR, "garch_parameters.csv"),
                           check.names = FALSE)
)
# Giữ đúng tên sheet 1-4 của workbook hiện tại để output không thay đổi.
names(tables) <- as.character(seq_along(tables))

workbook <- openxlsx::createWorkbook()
header_style <- openxlsx::createStyle(
  fontSize = 12, fontColour = "#FFFFFF", fgFill = "#4F81BD",
  textDecoration = "bold", halign = "center", valign = "center",
  border = "TopBottomLeftRight"
)
body_style <- openxlsx::createStyle(halign = "center", valign = "center")

#' Thêm một bảng vào workbook và áp style chung
#'
#' @param data Data frame cần ghi.
#' @param sheet Tên worksheet.
#' @return Không trả dữ liệu; cập nhật `workbook` ở parent environment.
#' @details Side effects: tạo sheet, ghi bảng, style header/body và chỉnh độ rộng.
add_table_sheet <- function(data, sheet) {
  rows <- seq_len(nrow(data)) + 1
  cols <- seq_len(ncol(data))
  openxlsx::addWorksheet(workbook, sheet)
  openxlsx::writeData(workbook, sheet, data, borders = "all")
  openxlsx::addStyle(workbook, sheet, header_style, 1, cols, gridExpand = TRUE)
  openxlsx::addStyle(workbook, sheet, body_style, rows, cols, gridExpand = TRUE)
  openxlsx::setColWidths(workbook, sheet, cols, widths = "auto")
}

purrr::iwalk(tables, add_table_sheet)
output_path <- file.path(TABLE_DIR, "report_tables.xlsx")
openxlsx::saveWorkbook(workbook, output_path, overwrite = TRUE)
message("Đã xuất workbook: ", output_path)
