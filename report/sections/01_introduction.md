# Giới thiệu

## Bối cảnh

Giá cổ phiếu là chuỗi thời gian có thứ tự, thường chứa xu hướng dài hạn và mức biến động thay đổi theo từng giai đoạn. Vì vậy, dự án không xem “dự báo giá” và “đo lường biến động” là cùng một bài toán. Dự báo giá tập trung vào conditional mean của mức giá, còn GARCH tập trung vào conditional variance của log return.

FPT được chọn vì repository có chuỗi OHLCV dài hơn 11 năm và đủ quan sát để thực hành cleaning, kiểm định, đánh giá ngoài mẫu và mô hình hóa volatility. Việc chọn FPT chỉ phục vụ mục tiêu học thuật; dự án không đánh giá giá trị nội tại và không đưa ra khuyến nghị mua bán.

## Câu hỏi nghiên cứu

1. `close`, `log_close` và `return` có dừng hay không?
2. ARIMA, SARIMA, ETS, ETS Damped hoặc ARIMAX có cải thiện Naive/Drift ngoài mẫu không?
3. Kết luận từ một holdout 30 phiên có ổn định qua rolling-origin CV không?
4. Return có ARCH effect và volatility clustering không?
5. Student-t và cấu trúc bất đối xứng có cải thiện sGARCH-Normal không?
6. Sau khi fit GARCH, residual dynamics, sign bias, parameter instability hoặc distribution misfit còn tồn tại không?

## Mục tiêu và phạm vi

Dự án xây dựng pipeline R tái lập từ raw CSV đến Word: kiểm tra dữ liệu, tạo log return, EDA, ADF, forecast evaluation, GARCH comparison và diagnostics. Phạm vi chỉ sử dụng lịch sử `FPT.VN`; dự án chưa đưa VN-Index, biến vĩ mô, tin tức hoặc dữ liệu intraday vào mô hình.

## Nguyên tắc phương pháp

- Không shuffle chuỗi thời gian.
- Mọi model trong cùng bảng holdout dùng cùng train/test split.
- Model phức tạp phải được so với benchmark đơn giản.
- Không chọn model chỉ bằng một metric hoặc AIC.
- P-value được diễn giải theo giả thuyết của từng test, không dùng như xác suất model đúng.
- Kết luận phải đi kèm giới hạn và không được chuyển thành khuyến nghị đầu tư.
