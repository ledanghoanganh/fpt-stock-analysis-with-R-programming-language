# 6. Kết luận và Định hướng Phát triển

## 6.1. Kết luận chung
Dự án đã hoàn thành toàn diện quy trình phân tích chuỗi thời gian cho cổ phiếu Công ty Cổ phần FPT từ năm 2015 đến năm 2026. Các kết luận chính rút ra từ quá trình nghiên cứu bao gồm:
1. **Xu hướng tăng trưởng:** FPT là một cổ phiếu có xu hướng tăng trưởng bền vững trong dài hạn, đặc biệt bùng nổ từ sau đại dịch nhờ lợi thế cốt lõi về công nghệ và chuyển đổi số. Chuỗi giá trị mang tính không dừng rõ rệt.
2. **Khả năng dự báo giá:** Cả hai mô hình ARIMA và ETS đều nắm bắt tốt quỹ đạo tăng trưởng của giá cổ phiếu. Trong đó, mô hình ARIMA có phần nhỉnh hơn với mức sai số rất thấp (MAPE ~ 2.19%), thích hợp để làm kim chỉ nam dự báo trung hạn.
3. **Đặc tính rủi ro:** Lợi suất cổ phiếu FPT tồn tại hiệu ứng biến động cụm. Mô hình GARCH(1,1) đã chứng minh được tính dai dẳng của biến động ($\beta_1 > 0.9$), giúp hệ thống hóa rủi ro của cổ phiếu trong những giai đoạn thị trường hoảng loạn.

## 6.2. Hạn chế của đề tài
Dù mô hình đạt độ chính xác cao, đề tài vẫn còn tồn đọng một số hạn chế:
* **Hạn chế về dữ liệu:** Chỉ sử dụng duy nhất dữ liệu lịch sử giá. Trong thực tế, giá cổ phiếu FPT còn chịu tác động rất lớn từ tin tức vĩ mô (lãi suất FED, tỷ giá), chính sách doanh nghiệp, và kết quả kinh doanh hàng quý.
* **Giới hạn mô hình tuyến tính:** Cả ARIMA và GARCH vẫn là các tiếp cận thống kê truyền thống, có thể gặp khó khăn trong việc bắt đỉnh/đáy (black swan events) nếu thị trường thay đổi cơ cấu đột ngột.

## 6.3. Hướng phát triển trong tương lai
Để mở rộng đề tài và nâng cao độ chính xác, nhóm đề xuất các hướng đi sau:
* Đưa các biến ngoại sinh (Exogenous variables) như VN-Index, lãi suất liên ngân hàng vào mô hình (ARIMAX, GARCH-X).
* Thử nghiệm các kiến trúc Học máy sâu (Deep Learning) chuyên dụng cho chuỗi thời gian như Long Short-Term Memory (LSTM), GRU hay Time Series Transformer để so sánh với các kỹ thuật thống kê cổ điển.
* Phân tích sâu hơn bằng Sentiment Analysis (Phân tích cảm xúc) từ các diễn đàn chứng khoán để xem xét yếu tố tâm lý tác động lên thanh khoản.