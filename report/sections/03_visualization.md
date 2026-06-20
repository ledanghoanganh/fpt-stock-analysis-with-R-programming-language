# Trực quan hóa dữ liệu

Phần trực quan hóa được thực hiện sau khi dữ liệu đã được làm sạch. Các hình được tạo bằng `R/02_visualization.R` và lưu trong thư mục `output/figures`.

Hình `close_price.png` thể hiện giá đóng cửa đã điều chỉnh của cổ phiếu FPT trong giai đoạn từ 2015-01-05 đến 2026-06-08. Biểu đồ cho thấy xu hướng biến động dài hạn của giá, nhưng không dùng riêng biểu đồ này để kết luận về khả năng sinh lời hay đưa ra khuyến nghị đầu tư.

Hình `volume.png` thể hiện khối lượng giao dịch theo thời gian. Biểu đồ giúp quan sát sự thay đổi về mức độ giao dịch giữa các giai đoạn. Tuy nhiên, biểu đồ này chỉ có ý nghĩa mô tả và không đủ để giải thích nguyên nhân kinh tế nếu không có nguồn bổ sung.

Hình `returns.png` thể hiện lợi suất log hằng ngày. Các giá trị dao động quanh mức 0 và có những giai đoạn biên độ dao động lớn hơn. Quan sát này gợi ý khả năng phương sai thay đổi theo thời gian, nhưng cần kiểm định và mô hình hóa ở các phần sau.

Hình `return_distribution.png` trình bày histogram của lợi suất log, kèm đường mật độ thực nghiệm và đường phân phối chuẩn có cùng trung bình và độ lệch chuẩn. Nếu phân phối thực nghiệm lệch khỏi đường chuẩn, điều này gợi ý lợi suất có thể không tuân theo phân phối chuẩn hoàn toàn.

Hình `qqplot_return.png` là QQ-plot của lợi suất log so với phân phối chuẩn. Nếu các điểm lệch khỏi đường thẳng ở hai đuôi, điều này gợi ý khả năng tồn tại đuôi dày. Đây là cơ sở thăm dò để cân nhắc phân phối Student-t trong mô hình biến động, nhưng chưa phải kết luận cuối cùng.

Hình `acf_return.png` và `pacf_return.png` thể hiện tự tương quan và tự tương quan riêng phần của lợi suất log. Hai biểu đồ này được dùng để quan sát cấu trúc phụ thuộc tuyến tính trong chuỗi lợi suất, hỗ trợ bước lựa chọn mô hình chuỗi thời gian ở phần sau.

Hình `squared_returns.png` thể hiện bình phương lợi suất log. Biểu đồ này giúp quan sát các cụm biến động lớn. Nếu các cụm này xuất hiện, đó là dấu hiệu thăm dò của hiện tượng volatility clustering.

Hình `return_by_weekday.png` so sánh phân phối lợi suất theo ngày trong tuần. Biểu đồ này chỉ dùng để quan sát sơ bộ. Nếu khác biệt giữa các ngày không rõ ràng, không nên kết luận có yếu tố mùa vụ theo ngày trong tuần.

Nhìn chung, các biểu đồ trong phần này cho thấy dữ liệu lợi suất cần được xem xét cẩn thận bằng các kiểm định và mô hình ở các phần tiếp theo, đặc biệt là kiểm định tính dừng, tự tương quan và mô hình hóa phương sai thay đổi.