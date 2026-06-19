# 4. Mô hình hóa dữ liệu chuỗi thời gian (ARIMA & ETS)

## 4.1. Phân chia dữ liệu (Train/Test Split)
Trong dự án này, chuỗi dữ liệu lịch sử giá cổ phiếu FPT được phân chia theo cấu trúc thời gian (time-based split) thay vì lấy mẫu ngẫu nhiên (random shuffle) như các thuật toán học máy cổ điển. Phương pháp chia này đảm bảo nguyên lý bảo toàn cấu trúc chuỗi thời gian, ngăn chặn hiện tượng rò rỉ dữ liệu (data leakage) khi các điểm dữ liệu trong tương lai bị lọt vào tập huấn luyện. Tập huấn luyện (Train set) sẽ bao gồm các quan sát trong quá khứ để xây dựng và tinh chỉnh mô hình, trong khi tập kiểm thử (Test set) sẽ bao gồm các điểm dữ liệu mới nhất đóng vai trò đánh giá khả năng dự báo ngoài mẫu (out-of-sample forecast).

## 4.2. Các mô hình dự báo
Để đảm bảo tính khách quan trong việc đánh giá hiệu năng, dự án sử dụng các mô hình cơ sở (benchmark) làm thước đo, sau đó so sánh với các mô hình phức tạp hơn.

### 4.2.1. Các mô hình cơ sở (Benchmarks)
- **Mô hình Naive (Random Walk):** Dự báo mức giá tương lai bằng đúng giá trị ở quan sát cuối cùng của tập huấn luyện. Mô hình này giả định giá cổ phiếu là một bước đi ngẫu nhiên không thể dự báo.
  $$ \hat{y}_{t+h|t} = y_t $$
- **Mô hình Drift:** Một biến thể của Random Walk có tính đến độ trượt (drift), tức là cho phép dự báo có xu hướng tăng hoặc giảm tương ứng với tốc độ tăng trưởng trung bình trong tập huấn luyện.
  $$ \hat{y}_{t+h|t} = y_t + h \left( \frac{y_t - y_1}{t - 1} \right) $$

### 4.2.2. Mô hình ARIMA
ARIMA (AutoRegressive Integrated Moving Average) là mô hình tuyến tính phân tích chuỗi thời gian thông qua 3 thành phần:
- **Tự hồi quy (AR - p):** Dự báo giá trị hiện tại dựa trên $p$ giá trị độ trễ trong quá khứ.
- **Sai phân (I - d):** Số lần lấy sai phân $d$ cần thiết để chuỗi đạt trạng thái dừng.
- **Trung bình trượt (MA - q):** Dự báo dựa trên $q$ sai số ngẫu nhiên trong quá khứ.

Phương trình tổng quát của mô hình ARIMA(p,d,q):
$$ (1 - \phi_1 B - \dots - \phi_p B^p)(1 - B)^d y_t = c + (1 + \theta_1 B + \dots + \theta_q B^q)\varepsilon_t $$
Trong đó, $B$ là toán tử trễ (Backshift operator), $\phi_i$ là hệ số tự hồi quy, $\theta_i$ là hệ số trung bình trượt, và $\varepsilon_t$ là sai số ngẫu nhiên (nhiễu trắng).
Mô hình sẽ tự động tìm kiếm bộ tham số (p,d,q) tối ưu bằng hàm `auto.arima()` dựa trên tiêu chí AICc nhỏ nhất.

### 4.2.3. Các mô hình San bằng mũ (ETS)
- **ETS cơ bản:** Lựa chọn tự động cấu trúc Error (Sai số), Trend (Xu hướng), và Seasonality (Mùa vụ). Mô hình giúp làm mịn các biến động để nhận diện xu hướng dài hạn. Ví dụ, mô hình ETS(M,A,N) (Sai số nhân, Xu hướng cộng, Không mùa vụ) có phương trình:
  $$ \hat{y}_{t+h|t} = (l_t + h b_t) $$
  Với $l_t$ là mức (level) và $b_t$ là xu hướng (trend).
- **ETS Damped (Xu hướng tắt dần):** Áp dụng một tham số giảm chấn (damped) $\phi$ ($0 < \phi < 1$) nhằm triệt tiêu lực tăng/giảm vô hạn. Phương trình dự báo trở thành:
  $$ \hat{y}_{t+h|t} = l_t + (\phi + \phi^2 + \dots + \phi^h) b_t $$
  Mô hình này ngăn ngừa xu hướng tiếp tục kéo dài mãi mãi theo thời gian, phù hợp hơn với thực tế biến động thị trường.

## 4.3. Phương pháp đánh giá mô hình

### 4.3.1. Đánh giá sai số (Metrics)
Độ chính xác của các mô hình được đo lường bằng 3 tiêu chí:
1. **RMSE (Root Mean Squared Error):** Đo lường độ lệch tuyệt đối. RMSE phạt nặng các dự báo có sai số lớn.
2. **MAE (Mean Absolute Error):** Trung bình độ lệch tuyệt đối, không nhạy cảm với các nhiễu đột biến như RMSE.
3. **MAPE (Mean Absolute Percentage Error):** Sai số phần trăm tương đối, giúp đánh giá độ chênh lệch theo tỷ lệ % so với giá gốc.

<!-- TABLE: output/tables/forecast_metrics.csv -->

### 4.3.2. Rolling-origin Cross Validation
Thay vì chỉ kiểm tra trên một điểm cắt (single split) duy nhất, dự án áp dụng kỹ thuật kiểm chứng chéo trên chuỗi thời gian gọi là **Rolling-Origin Cross Validation**. 
Theo phương pháp này, điểm xuất phát (origin) của tập huấn luyện được cuộn dần về phía trước. Tại mỗi điểm chia (fold), mô hình sẽ được huấn luyện trên dữ liệu quá khứ và dự báo một khoảng thời gian (horizon) cố định trong tương lai. Kỹ thuật này giúp:
- Đánh giá sự ổn định của hiệu năng mô hình qua nhiều chu kỳ thị trường khác nhau.
- Ngăn ngừa tình trạng mô hình chỉ vô tình dự báo tốt tại một đoạn dữ liệu kiểm thử duy nhất.

<!-- TABLE: output/tables/forecast_cv_metrics_summary.csv -->

## 4.4. Chẩn đoán phần dư (Residual Diagnostics)
Một mô hình dự báo chuỗi thời gian đạt chuẩn phải nắm bắt được toàn bộ cấu trúc tín hiệu, để lại phần dư (residuals) không chứa bất kỳ thông tin nào và hoạt động tương tự như nhiễu trắng (White Noise).
Quy trình kiểm tra phần dư bao gồm:
1. **Đồ thị tự tương quan (ACF plot):** Kiểm tra xem có hiện tượng tự tương quan giữa các phần dư ở các độ trễ khác nhau hay không.
2. **Kiểm định Ljung-Box:** 
   - **Giả thuyết $H_0$:** Chuỗi phần dư không có sự tự tương quan (phần dư là nhiễu trắng).
   - Nếu $p$-value của kiểm định $> 0.05$, ta không có cơ sở bác bỏ $H_0$ và có thể tự tin khẳng định mô hình đã khớp tốt.

<!-- TABLE: output/tables/forecast_diagnostics.csv -->

Kết quả trực quan hóa phần dư của mô hình:
<!-- FIGURE: output/figures/arima_residual_diagnostics.png -->
<!-- FIGURE: output/figures/ets_residual_diagnostics.png -->
<!-- FIGURE: output/figures/ets_damped_residual_diagnostics.png -->

## 4.5. Lựa chọn mô hình tối ưu
Tiêu chí cuối cùng để chọn mô hình dự báo chuỗi thời gian tối ưu là sự kết hợp giữa:
- Sai số RMSE và MAPE thấp nhất trên tập kiểm chứng chéo (CV).
- Hiệu năng vượt trội hơn các mô hình Naive Benchmarks.
- Trải qua thành công các kiểm định Ljung-Box trên phần dư.
