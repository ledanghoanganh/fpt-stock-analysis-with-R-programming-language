# 5. Phân tích Phương sai và Đánh giá Mô hình GARCH(1,1)

Dựa trên việc phát hiện ra hiện tượng "biến động cụm" (volatility clustering) ở phần phân tích thăm dò, chúng tôi đã tiến hành mô hình hóa phương sai sai số bằng mô hình GARCH(1,1) kết hợp phương trình trung bình ARMA(0,0). Kết quả chạy mô hình từ file `04_garch_volatility.R` cung cấp các tham số như sau (trích xuất từ bảng `garch_summary.csv`):

## 5.1. Phân tích các tham số cốt lõi của GARCH
* **Hệ số $\alpha_1$ (ARCH effect - 0.0673):** Đại diện cho tác động của các cú sốc (shock) trong quá khứ đối với biến động hiện tại. Hệ số này mang ý nghĩa thống kê ($p-value \approx 0$), chứng tỏ những thông tin mới trên thị trường có ảnh hưởng ngay lập tức đến mức độ rủi ro của cổ phiếu FPT.
* **Hệ số $\beta_1$ (GARCH effect - 0.9021):** Đại diện cho "sự dai dẳng" (persistence) của biến động phương sai. Với giá trị rất cao (lớn hơn 0.9) và có ý nghĩa thống kê cao ($p-value \approx 0$), điều này chứng minh rằng một khi thị trường có biến động mạnh (do khủng hoảng, dịch bệnh, hoặc thay đổi chính sách), biên độ dao động của FPT sẽ duy trì ở mức cao trong nhiều phiên giao dịch liên tiếp trước khi có thể dịu lại.
* **Điều kiện dừng của phương sai (Stationarity):** Tổng $\alpha_1 + \beta_1 = 0.0673 + 0.9021 = 0.9694 < 1$. Khẳng định mô hình GARCH(1,1) hoàn toàn phù hợp và ổn định (covariance stationary), phương sai sai số hữu hạn trong dài hạn.

## 5.2. Biểu đồ bao quát mức độ biến động (Volatility Plot)
Tham chiếu hình ảnh `garch_volatility.png`, có thể quan sát thấy rõ hai đường ranh giới màu đỏ (thể hiện sai số chuẩn có điều kiện - conditional standard deviation) bao bọc rất sát các biến động lợi suất thực tế. 
Vào các giai đoạn bình ổn (2015-2019), biên độ biến động co hẹp. Khi xảy ra các đợt sụt giảm mạnh trên toàn cầu như COVID-19 (2020) hay thị trường chứng khoán trong nước sập sâu (2022), đường ranh giới đỏ lập tức "phình to" để bao phủ rủi ro. Điều này một lần nữa khẳng định mô hình GARCH(1,1) cực kỳ nhạy bén và ưu việt trong việc đo lường rủi ro (risk measurement) của cổ phiếu FPT.

## 5.3. Bàn luận và So sánh Mô hình (Results & Discussion)
Kết hợp số liệu từ `model_comparison.csv`:
* Đối với bài toán **dự báo mức giá trung bình (Mean Forecast)**: Thuật toán ARIMA (RMSE: 2,016.99, MAPE: 2.19%) cho độ chính xác cao hơn so với mô hình Exponential Smoothing - ETS (RMSE: 2,099.80, MAPE: 2.29%). 
* Đối với bài toán **dự báo rủi ro (Volatility Forecast)**: Mô hình GARCH(1,1) cho điểm số thông tin (AIC: -5.5589, BIC: -5.5508) cực kỳ nhỏ và âm sâu, minh chứng cho một mô hình vừa vặn (goodness-of-fit) và tối ưu.

=> **Khuyến nghị áp dụng:** Trong thực tiễn đầu tư, nên sử dụng kết hợp ARIMA để định hướng giá mua/bán kỳ vọng, đồng thời sử dụng ranh giới của GARCH(1,1) để tính toán Value at Risk (VaR), quản trị rủi ro và xác định mức cắt lỗ hợp lý.