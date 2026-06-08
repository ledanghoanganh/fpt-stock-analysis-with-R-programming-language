# Results & Discussion: Phân tích biến động bằng mô hình GARCH

## 1. Mục tiêu của mô hình GARCH

Mô hình GARCH được sử dụng để phân tích sự biến động của lợi suất cổ phiếu FPT theo thời gian. Khác với ARIMA và ETS, GARCH không tập trung trực tiếp vào dự báo giá đóng cửa mà tập trung vào mô hình hóa phương sai có điều kiện, hay còn gọi là volatility.

## 2. Lý do sử dụng log return

Giá cổ phiếu thường không dừng và có xu hướng thay đổi theo thời gian. Do đó, trước khi xây dựng mô hình GARCH, ta chuyển giá đóng cửa sang log return:

$$
r_t = log(P_t) - log(P_{t-1})
$$

Trong đó:
- $P_t$ là giá đóng cửa tại thời điểm $t$
- $r_t$ là lợi suất log tại thời điểm $t$

Log return thường ổn định hơn chuỗi giá gốc và phù hợp hơn cho phân tích volatility.

## 3. Kết quả mô hình GARCH(1,1)

Mô hình GARCH(1,1) được ước lượng trên chuỗi log return của cổ phiếu FPT. Các tham số chính gồm:

- omega: thành phần phương sai nền
- alpha1: mức độ phản ứng của volatility với cú sốc mới
- beta1: mức độ duy trì của volatility trong quá khứ

Nếu alpha1 và beta1 đều có ý nghĩa, điều này cho thấy volatility của cổ phiếu FPT không ngẫu nhiên hoàn toàn mà có xu hướng phụ thuộc vào các giai đoạn biến động trước đó.

## 4. Phân tích volatility

Biểu đồ volatility có điều kiện cho thấy các giai đoạn thị trường biến động mạnh và yếu. Những giai đoạn conditional volatility tăng cao phản ánh rủi ro biến động lớn hơn. Đây là thông tin quan trọng đối với nhà đầu tư khi đánh giá mức độ rủi ro của cổ phiếu FPT.

![](../output/figures/garch_volatility.png)

## 5. So sánh mô hình

ARIMA và ETS được sử dụng để dự báo giá đóng cửa, do đó có thể so sánh bằng RMSE và MAPE. Mô hình có RMSE và MAPE thấp hơn được xem là có khả năng dự báo tốt hơn trên tập kiểm tra.

GARCH có mục tiêu khác, chủ yếu dùng để phân tích volatility. Vì vậy, GARCH không nên được so sánh trực tiếp với ARIMA và ETS bằng RMSE/MAPE nếu nhóm chưa xây dựng dự báo giá từ GARCH.

## 6. Thảo luận

Kết quả cho thấy dữ liệu cổ phiếu FPT có đặc điểm phù hợp với phân tích chuỗi thời gian tài chính: giá gốc thường không dừng, trong khi log return phù hợp hơn cho mô hình volatility. Mô hình GARCH(1,1) giúp nhận diện các giai đoạn biến động mạnh, qua đó hỗ trợ đánh giá rủi ro khi đầu tư cổ phiếu FPT.