# DANH MỤC TỪ VIẾT TẮT

Tổng hợp từ `report/report.Rmd`, sắp xếp theo thứ tự alphabet. Bảng đầu tiên là
bản nên đưa vào báo cáo chính thức.

| Viết tắt | Tên đầy đủ tiếng Anh | Nghĩa/Cách dùng trong báo cáo |
|---|---|---|
| ACF | Autocorrelation Function | Hàm tự tương quan |
| ADF | Augmented Dickey-Fuller | Kiểm định Dickey-Fuller mở rộng dùng để kiểm tra unit root |
| AIC | Akaike Information Criterion | Tiêu chí thông tin Akaike |
| AR | Autoregressive | Thành phần tự hồi quy |
| ARCH | Autoregressive Conditional Heteroskedasticity | Phương sai có điều kiện thay đổi và phụ thuộc squared shock quá khứ |
| ARCH-LM | Autoregressive Conditional Heteroskedasticity Lagrange Multiplier | Kiểm định nhân tử Lagrange cho hiệu ứng ARCH |
| ARIMA | Autoregressive Integrated Moving Average | Mô hình tự hồi quy tích hợp trung bình trượt |
| ARIMAX | Autoregressive Integrated Moving Average with Exogenous Variables | ARIMA có biến giải thích ngoại sinh |
| ARMA | Autoregressive Moving Average | Mô hình tự hồi quy trung bình trượt |
| BIC | Bayesian Information Criterion | Tiêu chí thông tin Bayes |
| CSV | Comma-Separated Values | Định dạng dữ liệu phân tách bằng dấu phẩy |
| CV | Cross-Validation | Đánh giá chéo; dự án dùng rolling-origin CV |
| EDA | Exploratory Data Analysis | Phân tích dữ liệu khám phá |
| ETS | Error, Trend, Seasonality | Mô hình state-space gồm sai số, xu hướng và mùa vụ |
| FPT | FPT Corporation / Công ty Cổ phần FPT | Doanh nghiệp và mã cổ phiếu được phân tích |
| GARCH | Generalized Autoregressive Conditional Heteroskedasticity | Mô hình ARCH tổng quát hóa |
| GED | Generalized Error Distribution | Phân phối sai số tổng quát hóa |
| GJR | Glosten-Jagannathan-Runkle | Tên ba tác giả của mô hình GJR-GARCH |
| GJR-GARCH | Glosten-Jagannathan-Runkle GARCH | GARCH bất đối xứng có indicator cho shock âm |
| GOF | Goodness-of-Fit | Mức độ phù hợp của phân phối/mô hình |
| HOSE | Ho Chi Minh Stock Exchange | Sở Giao dịch Chứng khoán Thành phố Hồ Chí Minh |
| MA | Moving Average | Thành phần trung bình trượt |
| MAE | Mean Absolute Error | Sai số tuyệt đối trung bình |
| MAPE | Mean Absolute Percentage Error | Sai số phần trăm tuyệt đối trung bình |
| MASE | Mean Absolute Scaled Error | Sai số tuyệt đối trung bình đã chuẩn hóa theo benchmark |
| MSE | Mean Squared Error | Sai số bình phương trung bình |
| OHLC | Open, High, Low, Close | Giá mở cửa, cao nhất, thấp nhất và đóng cửa |
| OHLCV | Open, High, Low, Close, Volume | Dữ liệu OHLC kèm khối lượng giao dịch |
| PACF | Partial Autocorrelation Function | Hàm tự tương quan riêng phần |
| QLIKE | Quasi-Likelihood Loss | Hàm mất mát quasi-likelihood dùng đánh giá dự báo volatility |
| Q-Q | Quantile-Quantile | Biểu đồ so sánh các phân vị của hai phân phối |
| RMSE | Root Mean Squared Error | Căn bậc hai của sai số bình phương trung bình |
| SARIMA | Seasonal Autoregressive Integrated Moving Average | ARIMA có thành phần mùa vụ |
| SD | Standard Deviation | Độ lệch chuẩn |
| sGARCH | Standard GARCH | GARCH chuẩn, đối xứng |
| eGARCH | Exponential GARCH | GARCH dạng log variance, hỗ trợ bất đối xứng |
| VaR | Value at Risk | Giá trị rủi ro tại một mức xác suất và thời hạn xác định |

## Ký hiệu nên giải thích riêng

Các mục dưới đây xuất hiện trong báo cáo nhưng không nhất thiết đặt chung với
“từ viết tắt”. Có thể tạo bảng **Danh mục ký hiệu** riêng.

| Ký hiệu | Tên/Ý nghĩa |
|---|---|
| H₀ | Null hypothesis - giả thuyết không |
| H₁ | Alternative hypothesis - giả thuyết đối |
| NA | Not Available/Not Applicable; trong R thường biểu thị giá trị thiếu |
| `μ` | Conditional mean của return |
| `εₜ` | Innovation/shock return tại thời điểm `t` |
| `σₜ²` | Conditional variance tại thời điểm `t` |
| `σₜ` | Conditional volatility tại thời điểm `t` |
| `zₜ` | Standardized innovation |
| `ω` | Intercept/mức nền trong variance equation |
| `α` | Mức phản ứng với squared shock mới trong sGARCH |
| `β` | Mức ghi nhớ conditional variance quá khứ |
| `γ` | Tham số bất đối xứng; cách đọc phụ thuộc specification |

## Mục không cần đưa vào danh mục

- `TRUE`, `FALSE`: giá trị logic trong R, chỉ xuất hiện trong code/output.
- `P-value`: thuật ngữ thống kê, không phải từ viết tắt cần bung tên.
- Student-t: tên phân phối, không phải chữ viết tắt.
- `VN-Index`: tên riêng của chỉ số thị trường, có thể giải thích trong nội dung
  thay vì danh mục viết tắt.
- `R`, Word, PNG, RDS: chỉ cần thêm nếu trường yêu cầu liệt kê cả phần mềm và
  định dạng tệp.

## Bản rút gọn nếu báo cáo giới hạn một trang

Nếu danh mục chỉ được phép dài một trang, ưu tiên:

`ACF`, `ADF`, `AIC`, `ARCH`, `ARCH-LM`, `ARIMA`, `ARIMAX`, `BIC`, `CV`, `EDA`,
`ETS`, `GARCH`, `GJR-GARCH`, `GOF`, `MAE`, `MAPE`, `OHLCV`, `PACF`, `Q-Q`,
`RMSE`, `SARIMA`, `sGARCH`, `eGARCH`, `VaR`.
