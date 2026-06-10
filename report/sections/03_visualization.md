# BÁO CÁO PHÂN TÍCH TRỰC QUAN HÓA CHUỖI THỜI GIAN CỔ PHIẾU FPT (2015 - 2026)

Tập lệnh `R/02_visualization.R` sử dụng thư viện `ggplot2` nâng cao và hệ phông chữ cấu hình `extrafont (Arial)` để xuất các biểu đồ chất lượng cao 300 DPI (`output/figures/`). Dưới đây là phân tích chi tiết dựa trên các kết quả đồ thị thu được.

## 1. Biểu đồ 1: Chuỗi thời gian Giá đóng cửa (close_price.png)
* **Mô tả trực quan:** Biểu đồ thể hiện diễn biến đường giá đóng cửa điều chỉnh của FPT chạy liên tục từ năm 2015 đến tháng 06/2026.
* **Phân tích kinh tế lượng:**
  * Giai đoạn 2015 - 2020: Cổ phiếu FPT duy trì đà tăng trưởng ổn định, bền vững ở vùng giá thấp (dưới 25.000 VNĐ).
  * Giai đoạn 2020 - 2022: Giá cổ phiếu tăng dốc mạnh mẽ, bứt phá nhờ làn sóng chuyển đổi số toàn cầu trong đại dịch COVID-19 và dòng tiền rẻ trên thị trường chứng khoán.
  * Giai đoạn 2023 - 2026: Đây là chu kỳ bùng nổ mạnh nhất của FPT, đường giá thiết lập đỉnh lịch sử tại mốc **129.855,73 VNĐ** vào giai đoạn nửa đầu năm 2026 nhờ động lực tăng trưởng cốt lõi từ mảng Công nghệ thông tin, xuất khẩu phần mềm và chip bán dẫn. 
  * Chuỗi thời gian mang tính **không dừng (Non-stationary)** rõ rệt, có xu hướng (trend) tăng trưởng dài hạn, đòi hỏi phải lấy sai phân (biến đổi sang tỷ suất sinh lời) trước khi chạy mô hình ARMA/ARIMA.

## 2. Biểu đồ 2: Khối lượng giao dịch hằng ngày (volume.png)
* **Mô tả trực quan:** Các cột dọc thể hiện thanh khoản phiên giao dịch, với mức kỷ lục đạt tới **415.709.889 cổ phiếu/phiên** và mức trung vị đạt hơn 2.7 triệu cổ phiếu.
* **Phân tích kinh tế lượng:**
  * Thanh khoản giai đoạn 2015-2019 tương đối thấp và đều đặn. 
  * Từ năm 2021 đến 2026, khối lượng giao dịch tăng vọt kèm theo biên độ dao động lớn. Điều này chứng tỏ dòng tiền lớn của các quỹ đầu tư tổ chức và nhà đầu tư cá nhân liên tục luân chuyển, biến FPT thành một trong những mã cổ phiếu có tính đại chúng và thanh khoản cao nhất hệ thống.

## 3. Biểu đồ 3: Hiện tượng Biến động cụm của Tỷ suất sinh lời (returns_professional.png)
* **Mô tả trực quan:** Đồ thị đường dao động quanh trục hoành 0 của biến `returns`.
* **Phân tích kinh tế lượng (Luận cứ khoa học quan trọng cho Bài tập lớn):**
  * Biểu đồ chỉ ra rất rõ hiện tượng **Biến động cụm (Volatility Clustering)** - một đặc tính kinh tế lượng kinh điển của chuỗi thời gian tài chính.
  * *Biểu hiện cụ thể:* Những khoảng thời gian thị trường bình yên (năm 2015 - 2017) có biên độ răng cưa rất nhỏ và tụ lại với nhau. Ngược lại, vào những giai đoạn khủng hoảng hoặc chuyển giao chu kỳ lớn (như đợt bùng phát COVID-19 năm 2020, đợt sụt giảm mạnh của thị trường chứng khoán Việt Nam năm 2022, và các nhịp điều chỉnh mạnh đầu năm 2026), các đường răng cưa kéo dài nhọn hoắt (biến động mạnh từ -6.99% đến +9.26%) xuất hiện liên tục và gộp thành cụm lớn.
  * *Ý nghĩa mô hình:* Hiện tượng này khẳng định chuỗi tỷ suất sinh lời của FPT có sự tồn tại của hiệu ứng **ARCH/GARCH** (phương sai thay đổi theo thời gian). Việc trực quan hóa thành công hiện tượng này là tiền đề cốt lõi để nhóm đề xuất sử dụng mô hình GARCH để dự báo rủi ro phương sai ở các chương sau của bài tập lớn.
