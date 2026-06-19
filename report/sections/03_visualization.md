# CHƯƠNG 2: MÔ TẢ DỮ LIỆU VÀ PHÂN TÍCH TRỰC QUAN HÓA

Tập lệnh `R/02_visualization.R` sử dụng thư viện `ggplot2` nâng cao và cấu hình hệ phông chữ `extrafont (Arial)` để xuất các đồ thị chất lượng cao với độ phân giải 300 DPI (`output/figures/`). Dưới đây là phân tích chi tiết dựa trên các kết quả trực quan hóa thu được.

## 2.1. Biểu đồ 1: Chuỗi thời gian Giá đóng cửa điều chỉnh (close_price.png)

* **Mô tả trực quan:** Đồ thị biểu diễn diễn biến đường giá đóng cửa điều chỉnh của cổ phiếu FPT một cách liên tục từ năm 2015 đến tháng 06/2026.
* **Phân tích kinh tế lượng:**
  * **Giai đoạn 2015 - 2020:** Cổ phiếu FPT duy trì đà tăng trưởng ổn định và bền vững tại vùng giá thấp (dưới 25.000 VNĐ).
  * **Giai đoạn 2020 - 2022:** Giá cổ phiếu thiết lập xu hướng tăng mạnh, bứt phá nhờ làn sóng chuyển đổi số toàn cầu trong đại dịch COVID-19 và sự gia tăng thanh khoản (dòng tiền rẻ) trên thị trường chứng khoán.
  * **Giai đoạn 2023 - 2026:** Đây là chu kỳ tăng trưởng mạnh mẽ nhất của FPT. Đường giá thiết lập đỉnh lịch sử tại mốc **129.855,73 VNĐ** vào nửa đầu năm 2026, nhờ động lực tăng trưởng cốt lõi từ mảng Công nghệ thông tin, xuất khẩu phần mềm và công nghiệp chip bán dẫn. 
  * **Đặc tính chuỗi thời gian:** Chuỗi dữ liệu mang tính **không dừng (Non-stationary)** rõ rệt, thể hiện xu hướng (trend) tăng trưởng dài hạn. Đặc điểm này đòi hỏi phải thực hiện biến đổi sai phân (chuyển sang chuỗi tỷ suất sinh lời) trước khi tiến hành ước lượng các mô hình ARMA/ARIMA tại các chương sau.

## 2.2. Biểu đồ 2: Khối lượng giao dịch hằng ngày (volume.png)

* **Mô tả trực quan:** Các cột dọc thể hiện mức thanh khoản của từng phiên giao dịch, với khối lượng kỷ lục đạt **415.709.889 cổ phiếu/phiên** và mức trung vị duy trì ở mức hơn 2,7 triệu cổ phiếu.
* **Phân tích kinh tế lượng:**
  * Trong giai đoạn 2015 - 2019, thanh khoản của FPT tương đối thấp và biến động đều đặn. 
  * Từ năm 2021 đến 2026, khối lượng giao dịch tăng vọt kèm theo biên độ dao động lớn. Điều này minh chứng cho sự tham gia mạnh mẽ của các quỹ đầu tư tổ chức và dòng tiền từ nhà đầu tư cá nhân, đưa FPT trở thành một trong những mã cổ phiếu có tính đại chúng và quy mô thanh khoản cao nhất hệ thống.

## 2.3. Biểu đồ 3: Hiện tượng Biến động cụm của Tỷ suất sinh lời (returns_professional.png)

* **Mô tả trực quan:** Đồ thị đường thể hiện sự dao động quanh trục hoành 0 của biến tỷ suất sinh lời (`returns`).
* **Phân tích kinh tế lượng (Luận cứ khoa học cho mô hình hóa phương sai):**
  * Biểu đồ chỉ ra hiện tượng **Biến động cụm (Volatility Clustering)** – một đặc tính kinh tế lượng kinh điển của chuỗi thời gian tài chính.
  * **Biểu hiện cụ thể:** Những giai đoạn thị trường ổn định (năm 2015 - 2017) có biên độ dao động nhỏ và tập trung quy tụ. Ngược lại, vào các giai đoạn khủng hoảng hoặc chuyển giao chu kỳ lớn (như đợt bùng phát dịch COVID-19 năm 2020, nhịp điều chỉnh mạnh của thị trường chứng khoán Việt Nam năm 2022, và các biến động đầu năm 2026), các đường dao động có biên độ lớn (từ -6,99% đến +9,26%) xuất hiện liên tục và tập trung thành các cụm lớn.
  * **Ý nghĩa mô hình hóa:** Hiện tượng này khẳng định chuỗi tỷ suất sinh lời của FPT tồn tại hiệu ứng **ARCH/GARCH** (phương sai thay đổi theo thời gian). Việc trực quan hóa thành công hiện tượng này là cơ sở khoa học cốt lõi để nghiên cứu đề xuất áp dụng mô hình GARCH nhằm dự báo rủi ro phương sai ở phần sau của bài tập lớn.
