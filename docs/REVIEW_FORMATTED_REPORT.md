# REVIEW `formatted_report.docx`

Ngày kiểm tra: 21/06/2026  
File: `report/formatted_report.docx`

## 1. Kết luận nhanh

Bản format đã có đầy đủ trang bìa, nhận xét giảng viên, lời cảm ơn, danh mục từ
viết tắt, danh mục ký hiệu, danh sách hình, danh sách bảng, nội dung chính, phụ
lục, đóng góp thành viên và tài liệu tham khảo. Font thân bài là Times New Roman
13 pt, căn đều hai lề. Hệ thống Heading, Caption và field danh mục đã được dùng,
đây là nền tảng tốt để cập nhật tự động.

Tuy nhiên, file **chưa nên nộp ngay** vì còn các lỗi định dạng/nội dung sau.

## 2. Lỗi cần sửa trước khi nộp

### 2.1 Khổ giấy đang là Letter, không phải A4

Open XML ghi nhận kích thước `12240 × 15840 twips`, tương ứng Letter
`8,5 × 11 inch`. Báo cáo học thuật tại Việt Nam thường yêu cầu A4.

Sửa trong Word:

1. `Layout` → `Size` → `A4 (21 × 29,7 cm)`.
2. Chọn `Apply to: Whole document`.
3. Kiểm tra lại toàn bộ page break, bảng và hình sau khi đổi.

Lề hiện tại hợp lý:

- trái: 3 cm;
- phải: 2 cm;
- trên: 3 cm;
- dưới: 2,5 cm;
- header/footer: khoảng 1,27 cm.

### 2.2 Hai hình chưa có tên

Danh sách hình hiện chỉ hiển thị:

- `Hình 3.4.1`;
- `Hình 3.4.2`.

Tên đúng nên là:

- **Hình 3.4.1. Hàm tự tương quan (ACF) của log return FPT**.
- **Hình 3.4.2. Hàm tự tương quan riêng phần (PACF) của log return FPT**.

Không đặt cùng caption “ACF (trái) và PACF (phải)” vì trong Word chúng đang là
hai ảnh và hai số hình riêng biệt.

### 2.3 Bốn bảng chưa có tên

- **Bảng 2.1. Mô tả các biến trong dữ liệu OHLCV của FPT**.
- **Bảng 4.2. Các mô hình dự báo giá và ý tưởng chính**.
- **Bảng 5.1. Các specification GARCH được so sánh trong dự án**.
- **Bảng 8.1. Phân công công việc và tỷ lệ đóng góp của thành viên**.

### 2.4 Danh sách bảng có dòng rỗng

Có một paragraph style `Table Caption` rỗng sau Bảng 2.3 và một entry rỗng ở
đầu danh sách bảng. Xóa caption rỗng, sau đó cập nhật field.

### 2.5 Tiêu đề chương kết luận bị ghép sai

Hiện tại:

> KẾT LUẬN, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN KẾT QUẢ, ĐÁNH GIÁ MÔ PHỎNG

Nên đổi thành:

> **KẾT LUẬN, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN**

Cụm “Kết quả, đánh giá mô phỏng” không phù hợp vì chương đã có kết quả forecast
và GARCH riêng, đồng thời dự án không phải nghiên cứu mô phỏng dữ liệu.

### 2.6 Thiếu phần Tóm tắt và Từ khóa

Nguồn `report.Rmd` có Tóm tắt và Từ khóa, nhưng bản formatted không còn hai mục
này. Nên đặt sau Lời cảm ơn, trước Mục lục/Danh mục:

- `TÓM TẮT`;
- đoạn tóm tắt nghiên cứu;
- `Từ khóa: FPT, chuỗi thời gian, ARIMA, ETS, GARCH, volatility, R.`

Nếu mẫu của khoa quy định Tóm tắt sau danh mục, làm theo mẫu khoa; không nên bỏ.

### 2.7 Cần cập nhật toàn bộ field trước khi xuất PDF

Sau khi sửa caption và đổi A4:

1. Nhấn `Ctrl + A`.
2. Nhấn `F9`.
3. Chọn `Update entire table` cho Mục lục.
4. Làm tương tự cho Danh sách hình và Danh sách bảng.
5. Kiểm tra lại số trang và số thứ tự.

## 3. Các điểm nên chỉnh để tài liệu chuyên nghiệp hơn

### 3.1 Tên trường và bộ môn

Trang bìa đang ghi:

- `TRƯỜNG ĐẠI HỌC CÔNG NGHỆ KỸ THUẬT TP. HỒ CHÍ MINH`;
- `BỘ MÔN LẬP TRÌNH R CHO PHÂN TÍCH`.

Cần đối chiếu đúng tên pháp lý trên mẫu bìa của trường. “Lập trình R cho phân
tích” là tên môn học, chưa chắc là tên bộ môn. Nếu không có bộ môn mang tên này,
nên ghi tên khoa/bộ môn chính thức và đặt tên môn ở dòng riêng.

### 3.2 Lời cảm ơn dùng đại từ số ít

Trang ghi ba thành viên nhưng Lời cảm ơn dùng “em” và phần ký ghi “Sinh viên”.
Nên thống nhất thành “nhóm chúng em” và “Nhóm sinh viên thực hiện”, hoặc làm theo
mẫu bắt buộc của khoa.

### 3.3 Dấu phân cách số

Báo cáo tiếng Việt đang dùng cả:

- `2,960` cho số lượng;
- `0.6676` cho số thập phân;
- `1,939.13` cho RMSE.

Nếu theo quy ước tiếng Việt, nên dùng `2.960`, `0,6676`, `1.939,13`. Nếu giữ
quy ước output tiếng Anh, phải ghi chú và thống nhất toàn tài liệu. Không trộn
hai chuẩn trong cùng bảng/đoạn.

### 3.4 Tên cột bảng còn dạng code

Các bảng hiện dùng tên như `rmse`, `cv_mean_rmse`, `parameter_stability_pass`.
Đây là output tốt cho audit nhưng chưa đẹp trong báo cáo chính thức. Nên đổi nhãn
hiển thị, không đổi CSV:

- `rmse` → `RMSE`;
- `mae` → `MAE`;
- `mape` → `MAPE (%)`;
- `cv_mean_rmse` → `RMSE CV trung bình`;
- `parameter_stability_pass` → `Ổn định tham số`;
- `distribution_fit_pass` → `Phân phối phù hợp`.

### 3.5 Ngôn ngữ Việt-Anh

Việc dùng thuật ngữ Anh là hợp lý, nhưng nên thống nhất dạng lần đầu:

> phương sai có điều kiện (conditional variance)

Các lần sau chỉ dùng một dạng. Tránh câu pha quá nhiều từ như “broadly đồng biến”.
Nên đổi thành “nhìn chung biến động cùng chiều”.

### 3.6 Caption phải cùng một quy tắc dấu câu

Nên dùng:

> Hình 3.1.1. Giá đóng cửa điều chỉnh của FPT

thay vì thiếu dấu chấm sau số. Áp dụng tương tự cho `Bảng` và `Phương trình`.

### 3.7 Vị trí caption

- Caption bảng đặt **trên bảng**.
- Caption hình đặt **dưới hình**.
- Không để caption nằm một mình ở cuối trang, còn bảng/hình sang trang sau.
- Bật `Keep with next` cho caption bảng và `Keep with previous` hoặc nhóm hình
  với caption hình khi cần.

### 3.8 Alt text của hình

Alt text hiện có cho phần lớn hình phân tích, đây là điểm tốt. Hai logo đầu tài
liệu chưa có alt text; không bắt buộc khi in, nhưng có thể thêm để tăng khả năng
tiếp cận.

## 4. Bộ caption hình hoàn chỉnh đề xuất

| Số | Caption đề xuất |
|---|---|
| Hình 3.1.1 | Giá đóng cửa điều chỉnh của cổ phiếu FPT giai đoạn 2015-2026 |
| Hình 3.1.2 | Khối lượng giao dịch cổ phiếu FPT giai đoạn 2015-2026 |
| Hình 3.2.1 | Log return hằng ngày của cổ phiếu FPT |
| Hình 3.2.2 | Bình phương log return và hiện tượng volatility clustering |
| Hình 3.3.1 | Phân phối thực nghiệm của log return FPT so với phân phối chuẩn |
| Hình 3.3.2 | Biểu đồ Q-Q của log return FPT so với phân phối chuẩn |
| Hình 3.4.1 | Hàm tự tương quan (ACF) của log return FPT |
| Hình 3.4.2 | Hàm tự tương quan riêng phần (PACF) của log return FPT |
| Hình 3.4.3 | Phân phối log return FPT theo ngày trong tuần |
| Hình 4.4.1 | Dự báo ETS Damped và giá thực tế trên holdout 30 phiên |
| Hình 4.4.2 | Chẩn đoán phần dư của mô hình ETS Damped |
| Hình 5.5.1 | Conditional volatility ước lượng từ bốn specification GARCH |
| Hình 5.5.2 | ACF của standardized residual và squared standardized residual |
| Hình 5.5.3 | News-impact curves của eGARCH-t và GJR-GARCH-t |

Lưu ý: DOCX có 16 media vì hai media đầu là logo; danh sách nội dung có 14 hình
phân tích, đúng với danh sách trên.

## 5. Bộ caption bảng hoàn chỉnh đề xuất

| Số | Caption đề xuất |
|---|---|
| Bảng 2.1 | Mô tả các biến trong dữ liệu OHLCV của FPT |
| Bảng 2.2 | Tóm tắt kết quả kiểm tra chất lượng dữ liệu |
| Bảng 2.3 | Giá trị thiếu trong các biến của dữ liệu mô hình |
| Bảng 2.4 | Thống kê mô tả dữ liệu FPT sau làm sạch |
| Bảng 4.1 | Kết quả kiểm định ADF trên dữ liệu FPT sau làm sạch |
| Bảng 4.2 | Các mô hình dự báo giá và ý tưởng chính |
| Bảng 4.3 | So sánh mô hình dự báo bằng holdout, rolling-origin CV và Ljung-Box |
| Bảng 4.4 | Kết quả Ljung-Box trên phần dư của các mô hình dự báo |
| Bảng 5.1 | Các specification GARCH được so sánh trong dự án |
| Bảng 5.2 | So sánh GARCH theo độ phù hợp, diagnostics, stability và GOF |
| Bảng 5.3 | Kết quả các kiểm định chẩn đoán GARCH |
| Bảng 5.4 | Tham số eGARCH-Student-t theo conventional và robust inference |
| Bảng 8.1 | Phân công công việc và tỷ lệ đóng góp của thành viên |

DOCX có 15 bảng vật lý vì hai bảng đầu là Danh mục viết tắt và Danh mục ký hiệu;
13 bảng nội dung được đánh số như trên.

## 6. Tên phương trình đề xuất

| Số | Tên đề xuất |
|---|---|
| Phương trình 2.3.1 | Công thức tính log return |
| Phương trình 4.3.1 | Các chỉ tiêu RMSE, MAE và MAPE |
| Phương trình 5.1.1 | Phương trình mean và innovation của mô hình volatility |
| Phương trình 5.1.2 | Phương trình phương sai của sGARCH(1,1) |

## 7. Checklist sửa trong Word

- [ ] Đổi toàn bộ tài liệu sang A4.
- [ ] Xác nhận tên trường, khoa và bộ môn theo mẫu chính thức.
- [ ] Khôi phục Tóm tắt và Từ khóa.
- [ ] Sửa tiêu đề chương kết luận bị ghép.
- [ ] Điền caption Hình 3.4.1 và 3.4.2.
- [ ] Điền caption Bảng 2.1, 4.2, 5.1 và 8.1.
- [ ] Xóa caption bảng rỗng.
- [ ] Thống nhất dấu chấm sau số caption.
- [ ] Việt hóa tên cột hiển thị trong bảng.
- [ ] Thống nhất định dạng số.
- [ ] Cập nhật toàn bộ field bằng `Ctrl + A`, `F9`.
- [ ] Xuất PDF và kiểm tra orphan caption, bảng tràn, hình mờ.
