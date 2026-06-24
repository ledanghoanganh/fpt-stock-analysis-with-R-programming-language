source("R/00_config.R")
require_packages("openxlsx")

sheet_registry <- c(
  Thong_Ke_Mo_Ta = "data_summary.csv",
  Missing_Values = "missing_values.csv",
  So_Sanh_Mo_Hinh = "model_comparison.csv",
  Tham_So_GARCH = "garch_summary.csv"
)
paths <- file.path(TABLE_DIR, sheet_registry)
if (any(!file.exists(paths))) stop("Thiếu CSV: ", paste(paths[!file.exists(paths)], collapse = ", "))

tables <- purrr::map(paths, read.csv, check.names = FALSE)
workbook <- openxlsx::createWorkbook()
header_style <- openxlsx::createStyle(
  fontSize = 12, fontColour = "#FFFFFF", fgFill = "#4F81BD",
  textDecoration = "bold", halign = "center", valign = "center",
  border = "TopBottomLeftRight"
)
body_style <- openxlsx::createStyle(halign = "center", valign = "center")

add_table_sheet <- function(data, sheet) {
  openxlsx::addWorksheet(workbook, sheet)
  openxlsx::writeData(workbook, sheet, data, borders = "all")
  openxlsx::addStyle(workbook, sheet, header_style, rows = 1,
                     cols = seq_len(ncol(data)), gridExpand = TRUE)
  if (nrow(data)) {
    openxlsx::addStyle(workbook, sheet, body_style, rows = 2:(nrow(data) + 1),
                       cols = seq_len(ncol(data)), gridExpand = TRUE)
  }
  openxlsx::setColWidths(workbook, sheet, cols = seq_len(ncol(data)), widths = "auto")
}
purrr::iwalk(tables, add_table_sheet)

output_path <- file.path(TABLE_DIR, "report_tables.xlsx")
openxlsx::saveWorkbook(workbook, output_path, overwrite = TRUE)
message("Đã xuất workbook: ", output_path)
