# Kết luận

Đề tài đã thực hiện quy trình phân tích và dự báo giá cổ phiếu FPT bằng các mô hình chuỗi thời gian. Dữ liệu được thu thập bằng thư viện vnstock, sau đó được xử lý và phân tích trong R.

Kết quả phân tích cho thấy giá cổ phiếu FPT có xu hướng biến động theo thời gian và chuỗi giá gốc thường không dừng. Sau khi log transform và differencing, chuỗi trở nên phù hợp hơn cho mô hình hóa.

Mô hình ARIMA và ETS được sử dụng để dự báo giá đóng cửa. Hai mô hình này được đánh giá thông qua RMSE và MAPE. Mô hình có sai số nhỏ hơn được xem là phù hợp hơn cho bài toán dự báo ngắn hạn.

Bên cạnh đó, mô hình GARCH(1,1) được sử dụng để phân tích volatility của cổ phiếu FPT. Kết quả từ GARCH cho phép nhận diện các giai đoạn biến động mạnh và hỗ trợ đánh giá rủi ro của cổ phiếu.

Nhìn chung, ARIMA và ETS phù hợp cho mục tiêu dự báo giá, trong khi GARCH phù hợp cho mục tiêu phân tích biến động và rủi ro. Việc kết hợp các mô hình này giúp bài báo cáo có cái nhìn toàn diện hơn về cổ phiếu FPT.

Trong các nghiên cứu tiếp theo, nhóm có thể mở rộng bằng các mô hình nâng cao như SARIMA, Prophet, Random Forest, XGBoost hoặc LSTM. Ngoài ra, nhóm có thể bổ sung thêm dữ liệu vĩ mô, chỉ số VN-Index hoặc dữ liệu tin tức để cải thiện độ chính xác dự báo.