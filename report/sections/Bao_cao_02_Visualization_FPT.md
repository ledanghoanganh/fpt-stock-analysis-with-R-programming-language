# BÁO CÁO PHÂN TÍCH KẾT QUẢ TRỰC QUAN HÓA CHUỖI DỮ LIỆU CỔ PHIẾU FPT
## Phần 2: Trực quan hóa và Lời bình luận phân tích biểu đồ (Data Visualization)
**Giai đoạn nghiên cứu:** 2024 - 2026  
**Đơn vị thực hiện:** Nhóm nghiên cứu dự án  

---

## 1. PHÂN TÍCH XU HƯỚNG GIÁ ĐÓNG CỬA (ĐỒ THỊ DẠNG ĐƯỜNG - LINE CHART)
*Đường dẫn tệp đồ thị chất lượng cao:* `output/figures/close_price_professional.png`

Biểu đồ đường thể hiện diễn biến giá đóng cửa của cổ phiếu FPT từ đầu năm 2024 đến đầu năm 2026 cung cấp các luận điểm phân tích kinh tế quan trọng sau:

* **Xu hướng tăng giá chủ đạo dài hạn (Primary Uptrend):** Khi phân tích cấu trúc hình học của đồ thị từ trái sang phải, đường giá thiết lập một xu hướng đi lên vô cùng bền vững. Cổ phiếu liên tục hình thành cấu trúc kinh điển của một xu hướng tăng mạnh: Đáy sau cao hơn đáy trước và Đỉnh sau cao hơn đỉnh trước. Giá trị dịch chuyển thành công từ vùng nền đáy cũ quanh 61,000 VNĐ lên bứt phá các cột mốc mới trên 80,000 VNĐ vào giai đoạn cuối chu kỳ.
* **Các nhịp điều chỉnh lành mạnh:** Trên đồ thị xuất hiện các làn sóng răng cưa sụt giảm ngắn hạn (Điển hình là giai đoạn giữa năm 2024). Tuy nhiên, các nhịp giảm này đóng vai trò là các đợt tích lũy thay máu dòng tiền. Lực cầu đối ứng mạnh mẽ luôn xuất hiện tại các vùng hỗ trợ kỹ thuật giúp cổ phiếu nhanh chóng phục hồi. Xu hướng tăng này minh chứng cho niềm tin chiến lược và đánh giá tích cực của thị trường đối với triển vọng tăng trưởng công nghệ cốt lõi, phần mềm, dịch vụ AI và chuyển đổi số của Tập đoàn FPT.

---

## 2. PHÂN TÍCH THANH KHOẢN QUA KHỐI LƯỢNG GIAO DỊCH (ĐỒ THỊ DẠNG CỘT - BAR CHART)
*Đường dẫn tệp đồ thị chất lượng cao:* `output/figures/volume_professional.png`

Biểu đồ cột (Volume Bar Chart) cho phép nhóm nghiên cứu bóc tách hành vi của các luồng vốn tham gia vào thị trường:

* **Độ sâu thị trường và tính ổn định:** Khối lượng giao dịch hằng ngày chủ yếu phân bổ đậm đặc xung quanh đường kỳ vọng trung bình từ 1.5 triệu đến 3 triệu cổ phiếu/phiên. Điều này khẳng định FPT sở hữu tính thanh khoản cực kỳ cao và ổn định, rủi ro mất thanh khoản (đóng băng giao dịch) gần như bằng không, rất phù hợp cho các quỹ đầu tư lớn giải ngân.
* **Dấu vết của dòng tiền lớn (Institutional Money):** Đồ thị làm nổi bật một số phiên giao dịch có cột khối lượng xanh cao vọt lên một cách cô lập (vượt ngưỡng 7 triệu đến gần 9 triệu cổ phiếu). Khi đối chiếu hình học sang biểu đồ giá, các phiên đột biến khối lượng này trùng khớp hoàn toàn với các phiên giá tăng mạnh bứt phá khỏi nền tích lũy (Breakout) hoặc các phiên sụt giảm sâu do hoảng loạn. Đây là minh chứng kỹ thuật rõ ràng cho thấy hành vi gom hàng chủ động hoặc kích giá của các nhà đầu tư tổ chức (quỹ ngoại, tự doanh) tại các bước ngoặt của xu hướng.

---

## 3. PHÂN TÍCH TỶ SUẤT SINH LỜI VÀ HIỆN TƯỢNG BIẾN ĐỘNG CỤM (VOLATILITY CLUSTERING)
*Đường dẫn tệp đồ thị chất lượng cao:* `output/figures/returns_professional.png`

Biểu đồ tỷ suất sinh lời hằng ngày (Daily Returns) dao động răng cưa nhọn quanh trục trung tâm cân bằng $0\%$, mang lại giá trị phát hiện thực nghiệm rất lớn trong phân tích tài chính:

* **Kiểm soát biên độ rủi ro ổn định:** Phần lớn các đường răng cưa dao động ổn định trong biên độ hẹp từ $-2\%$ đến $+1\%$, cực kỳ hiếm khi xuất hiện các hiện tượng biến động kịch trần hoặc kịch sàn biên độ sàn HOSE. Điều này chỉ ra FPT là cấu trúc cổ phiếu có độ an toàn cao, biên độ sụt giảm bất ngờ thấp, giúp bảo vệ danh mục đầu tư ngắn hạn.
* **Bằng chứng thực nghiệm về hiện tượng Biến động cụm (Volatility Clustering):** Hình ảnh biểu đồ cung cấp một minh chứng trực quan hoàn hảo cho lý thuyết kinh tế lượng tài chính của Engle (1982). Ta thấy rõ các giai đoạn biến động mạnh (đường răng cưa nhấp nhô biên độ lớn) có xu hướng quần tụ, tập trung lại với nhau thành từng cụm thời gian dài nhiều tuần (ví dụ giai đoạn thị trường hấp thụ thông tin tiêu cực vào giữa năm 2024). Ngược lại, những giai đoạn thị trường bình ổn, ít tin tức, các răng cưa thu nhỏ biên độ và đi liền với nhau thành một dải phẳng mịn. Việc phát hiện quy luật biến động cụm này là cơ sở khoa học để nhóm đề xuất ứng dụng các mô hình tài chính nâng cao như **ARCH/GARCH** nhằm dự báo chính xác phương sai thay đổi và quản trị rủi ro danh mục cổ phiếu một cách tối ưu.

---
**Hướng dẫn sử dụng:** Thành viên thiết kế Slide PowerPoint chèn trực tiếp 3 file ảnh tương ứng vào 3 trang slide riêng biệt. Sử dụng các đề mục và cụm từ in đậm (Uptrend, Dòng tiền lớn, Biến động cụm) để làm luận điểm trình bày trước lớp.
