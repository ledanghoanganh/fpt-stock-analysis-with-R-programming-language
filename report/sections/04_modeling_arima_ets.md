# 4. Mô hình hóa dữ liệu chuỗi thời gian (ARIMA & ETS)

## 4.1. Phân tích tính dừng và biến đổi chuỗi dữ liệu

### 4.1.1. Tầm quan trọng của tính dừng
Trong phân tích chuỗi thời gian, tính dừng (stationarity) là một điều kiện tiên quyết quan trọng đối với các mô hình hồi quy và dự báo như ARIMA. Một chuỗi thời gian được coi là dừng nếu các đặc trưng thống kê của nó như kỳ vọng (mean), phương sai (variance) và hiệp phương sai (covariance) không thay đổi theo thời gian. 
* Nếu chuỗi không dừng, việc xây dựng mô hình trực tiếp có thể dẫn đến hiện tượng hồi quy giả mạo (spurious regression), khiến các ước lượng thống kê mất đi độ tin cậy và các khoảng dự báo bị sai lệch nghiêm trọng.
* Việc kiểm định tính dừng giúp xác định xem liệu chuỗi dữ liệu có cần thực hiện lấy sai phân (differencing) hay không, và bậc sai phân ($d$) cần thiết là bao nhiêu để đưa chuỗi về trạng thái dừng.

### 4.1.2. Biến đổi Logarit (Log Transform) và lấy sai phân (Differencing)
* **Biến đổi Logarit:** Giá cổ phiếu thường có xu hướng tăng trưởng theo quy mô nhân (exponential growth) và biên độ dao động lớn dần khi giá trị tăng lên. Việc áp dụng biến đổi logarit tự nhiên ($log\_close = \ln(close)$) giúp ổn định phương sai, giảm bớt hiện tượng bất đồng nhất phương sai (heteroskedasticity) và đưa chuỗi dữ liệu về dạng tuyến tính hơn.
* **Lấy sai phân:** Khi chuỗi giá gốc hoặc chuỗi logarit có xu hướng rõ rệt (không dừng), việc lấy sai phân bậc 1 ($return_t = \ln(close_t) - \ln(close_{t-1})$) sẽ loại bỏ xu hướng thời gian, đưa chuỗi về trạng thái dừng quanh mức trung bình không đổi. Lợi suất log (Log Return) chính là sai phân bậc 1 của log giá đóng cửa, đại diện cho tốc độ sinh lời liên tục của cổ phiếu.

### 4.1.3. Kết quả kiểm định nghiệm đơn vị ADF (Augmented Dickey-Fuller Test)
Để kiểm tra tính dừng một cách khách quan, dự án sử dụng kiểm định ADF với giả thuyết không ($H_0$): *Chuỗi thời gian chứa nghiệm đơn vị (không dừng)* và giả thuyết đối ($H_1$): *Chuỗi thời gian là dừng*. Kết quả kiểm định thu được từ tập dữ liệu FPT (giai đoạn 01/01/2015 đến 08/06/2026) được tổng hợp dưới đây:

| Chuỗi dữ liệu | Thống kê ADF | Giá trị P (P-Value) | Kết luận |
| :--- | :---: | :---: | :--- |
| **Giá đóng cửa gốc (`close`)** | -1.7312 | 0.6921 | Không dừng (Chấp nhận $H_0$) |
| **Log giá đóng cửa (`log_close`)** | -1.2655 | 0.8893 | Không dừng (Chấp nhận $H_0$) |
| **Lợi suất Log (`return`)** | -13.8526 | < 0.01 | **Dừng** (Bác bỏ $H_0$ ở mức ý nghĩa 1%) |

*Bảng 4.1: Kết quả kiểm định tính dừng ADF cho chuỗi cổ phiếu FPT*

**Nhận xét:**
* Chuỗi giá đóng cửa gốc và chuỗi log giá đóng cửa đều có giá trị p-value rất lớn (> 0.05), do đó không thể bác bỏ giả thuyết $H_0$. Điều này chứng minh rằng giá cổ phiếu FPT chứa xu hướng ngẫu nhiên (random walk) và không dừng.
* Sau khi lấy sai phân bậc 1 (chuỗi lợi suất log), thống kê ADF giảm mạnh xuống -13.8526 với p-value nhỏ hơn 0.01 (mức ý nghĩa 1%). Ta bác bỏ hoàn toàn giả thuyết $H_0$ và kết luận chuỗi lợi suất dừng hoàn toàn. Bậc sai phân phù hợp để mô hình hóa ARIMA là $d = 1$.

---

## 4.2. Xây dựng mô hình dự báo

Dữ liệu lịch sử gồm 2960 quan sát được chia thành hai tập:
* **Tập huấn luyện (Train set):** 2930 quan sát (từ 01/01/2015 đến 27/04/2026) dùng để ước lượng tham số mô hình.
* **Tập kiểm thử (Test set):** 30 quan sát (từ 28/04/2026 đến 08/06/2026) dùng để đánh giá khả năng dự báo ngoài mẫu (out-of-sample forecast).

### 4.2.1. Mô hình tự hồi quy tích hợp trung bình trượt (ARIMA)
Sử dụng thuật toán tìm kiếm tối ưu tự động dựa trên tiêu chí thông tin AICc nhỏ nhất (thông qua hàm `auto.arima`), mô hình ARIMA tốt nhất được lựa chọn cho chuỗi giá đóng cửa của FPT là **ARIMA(3,1,2)**.

* **Cấu trúc mô hình:**
  * Bậc tự hồi quy $p = 3$: Giá trị hiện tại phụ thuộc vào giá trị của 3 ngày giao dịch trước đó.
  * Bậc sai phân $d = 1$: Chuỗi dữ liệu cần lấy sai phân bậc 1 để đạt tính dừng (phù hợp với kết quả ADF).
  * Bậc trung bình trượt $q = 2$: Sai số hiện tại phụ thuộc vào sai số ngẫu nhiên của 2 ngày trước đó.
* **Phương trình toán học mô tả:**
  $$\Delta Y_t = c + \phi_1 \Delta Y_{t-1} + \phi_2 \Delta Y_{t-2} + \phi_3 \Delta Y_{t-3} + \theta_1 \epsilon_{t-1} + \theta_2 \epsilon_{t-2} + \epsilon_t$$
  Trong đó $\Delta Y_t = Y_t - Y_{t-1}$ là giá đóng cửa đã lấy sai phân bậc 1.
* **Các tham số ước lượng:**
  * Hệ số tự hồi quy: $\phi_1 = -0.5334$; $\phi_2 = 0.2747$; $\phi_3 = -0.0514$
  * Hệ số trung bình trượt: $\theta_1 = 0.5642$; $\theta_2 = -0.3330$
  * Phương sai sai số ngẫu nhiên: $\sigma^2 = 849,973$
  * Tiêu chuẩn thông tin AIC: 48308.69; BIC: 48344.58

### 4.2.2. Mô hình San bằng mũ trạng thái không gian (ETS)
Mô hình ETS được tự động xây dựng bằng cách tối ưu hóa các trạng thái lỗi, xu hướng và mùa vụ. Mô hình tốt nhất được chọn là **ETS(M,A,N)**.

* **Cấu trúc mô hình:**
  * **M (Multiplicative Error):** Sai số có tính chất nhân tỉ lệ với mức độ của chuỗi.
  * **A (Additive Trend):** Xu hướng tăng trưởng tuyến tính cộng dồn (mô hình tuyến tính Holt).
  * **N (No Seasonality):** Không có yếu tố mùa vụ (phù hợp với đặc thù dữ liệu chứng khoán theo ngày).
* **Các tham số làm mịn ước lượng:**
  * Hệ số làm mịn mức độ (Level smoothing coefficient) $\alpha = 0.9999$ (gần bằng 1, cho thấy mô hình đặt trọng số cực kỳ lớn vào các quan sát gần nhất).
  * Hệ số làm mịn xu hướng (Trend smoothing coefficient) $\beta = 0.0016$ (rất nhỏ, phản ánh độ dốc xu hướng thay đổi rất chậm theo thời gian).
  * Tiêu chuẩn thông tin AIC: 59067.73; BIC: 59097.64

---

## 4.3. Đánh giá và so sánh kết quả dự báo

Để đánh giá độ chính xác của mô hình trên tập kiểm thử ngoài mẫu (30 ngày giao dịch cuối), dự án sử dụng hai chỉ số đo lường sai số phổ biến:
1. **RMSE (Root Mean Squared Error - Căn phương sai sai số trung bình):** Đo lường độ lệch tuyệt đối giữa giá trị thực tế và dự báo, phạt nặng các sai số lớn.
2. **MAPE (Mean Absolute Percentage Error - Sai số phần trăm tuyệt đối trung bình):** Đo lường mức độ sai số theo tỷ lệ phần trăm, giúp dễ hình dung quy mô sai sót so với giá trị thực tế.

Kết quả sai số dự báo trên tập kiểm thử ngoài mẫu được tổng hợp như sau:

| Mô hình | RMSE (VNĐ) | MAPE (%) | Nhận xét độ chính xác |
| :--- | :---: | :---: | :--- |
| **ARIMA(3,1,2)** | **2016.99** | **2.19%** | Dự báo rất chính xác (MAPE < 5%) |
| **ETS(M,A,N)** | 2099.80 | 2.29% | Dự báo rất chính xác (MAPE < 5%) |

*Bảng 4.2: So sánh sai số dự báo ngoài mẫu giữa ARIMA và ETS*

**Nhận xét:**
* Cả hai mô hình **ARIMA(3,1,2)** và **ETS(M,A,N)** đều cho kết quả dự báo rất tốt trên tập kiểm thử kéo dài 30 ngày giao dịch, với sai số phần trăm tuyệt đối trung bình (MAPE) chỉ dao động quanh mức **2.19% - 2.29%**. Đây là mức sai số rất thấp đối với chuỗi tài chính có độ biến động cao như giá cổ phiếu.
* So sánh tương quan, mô hình **ARIMA(3,1,2)** cho hiệu năng dự báo vượt trội hơn mô hình **ETS(M,A,N)** trên cả hai tiêu chí:
  * Chỉ số RMSE của ARIMA thấp hơn ETS khoảng 82.81 VNĐ (2016.99 so với 2099.80).
  * Chỉ số MAPE của ARIMA thấp hơn ETS 0.10% (2.19% so với 2.29%).
* Sự vượt trội của ARIMA có thể giải thích bởi khả năng tích hợp các thành phần tự hồi quy (AR) và trung bình trượt (MA) trên chuỗi sai phân dừng, giúp bắt kịp tốt hơn các dao động ngắn hạn của thị trường. Trong khi đó, ETS(M,A,N) hoạt động tương tự như mô hình Holt tuyến tính, có xu hướng kéo dài đường xu hướng thẳng mà không nắm bắt được các biến động uốn lượn ngắn hạn của chu kỳ giá.

Kết quả trực quan hóa dự báo của hai mô hình so với giá thực tế (bao gồm cả khoảng tin cậy 80% và 95%) được thể hiện chi tiết tại các biểu đồ tương ứng:
* Biểu đồ dự báo ARIMA: `output/figures/arima_forecast.png`
* Biểu đồ dự báo ETS: `output/figures/ets_forecast.png`
