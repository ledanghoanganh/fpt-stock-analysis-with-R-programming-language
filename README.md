# FPT Stock Time Series Project

## Đề tài
Dự báo giá và phân tích biến động cổ phiếu FPT bằng mô hình chuỗi thời gian.

## Phân công

### Người 1 - Data + Visualization
- Thu thập dữ liệu bằng notebook Python/Colab.
- Làm sạch dữ liệu.
- Kiểm tra dữ liệu thiếu.
- Thống kê mô tả.
- Trực quan hóa dữ liệu.
- Viết mục Data và Visualization.

File phụ trách:
- notebooks/01_scrape_fpt_colab.ipynb
- R/01_data_cleaning.R
- R/02_visualization.R
- report/sections/02_data.md
- report/sections/03_visualization.md

Output cần tạo:
- data/processed/fpt_clean.csv
- output/tables/data_summary.csv
- output/figures/close_price.png
- output/figures/returns.png

### Người 2 - Modeling ARIMA/ETS
- Kiểm định ADF.
- Log transform.
- Differencing.
- Xây dựng mô hình ARIMA.
- Xây dựng mô hình ETS.
- Tính RMSE, MAPE.
- Viết mục Modeling ARIMA/ETS.

File phụ trách:
- R/03_stationarity_arima_ets.R
- report/sections/04_modeling_arima_ets.md

Output cần tạo:
- output/tables/stationarity_tests.csv
- output/tables/forecast_metrics.csv
- output/figures/arima_forecast.png
- output/figures/ets_forecast.png
- output/models/arima_model.rds
- output/models/ets_model.rds

### Người 3 - GARCH + Results & Discussion + Tổng hợp báo cáo
- Xây dựng mô hình GARCH.
- Phân tích volatility.
- So sánh mô hình.
- Viết Results & Discussion.
- Viết kết luận.
- Ghép báo cáo cuối.

File phụ trách:
- R/04_garch_volatility.R
- R/05_model_comparison.R
- R/06_export_report_tables.R
- report/sections/05_garch_results_discussion.md
- report/sections/06_conclusion.md
- report/report.Rmd

Output cần tạo:
- output/tables/garch_summary.csv
- output/tables/model_comparison.csv
- output/figures/garch_volatility.png
- output/models/garch_model.rds
- report/report.docx