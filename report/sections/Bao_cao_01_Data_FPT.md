# BÁO CÁO PHÂN TÍCH TIẾN TRÌNH XỬ LÝ VÀ CHẤT LƯỢNG DỮ LIỆU CỔ PHIẾU FPT
## Phần 1: Quy trình xử lý và Thống kê mô tả dữ liệu (Data Description)
**Giai đoạn nghiên cứu:** 2024 - 2026  
**Đơn vị thực hiện:** Nhóm nghiên cứu dự án  

---

## 1. NGUỒN DỮ LIỆU VÀ CÁC BIẾN SỐ NGHIÊN CỨU

Dữ liệu nghiên cứu mô tả biến động thị trường hằng ngày (Daily time-series) của mã cổ phiếu **FPT** (Công ty Cổ phần FPT) được tổ chức thu thập một cách hệ thống:

* **Nguồn thu thập:** Hệ thống giao dịch và cổng API tài chính chính thức của Công ty Chứng khoán Kỹ thương (TCBS).
* **Công cụ thu thập:** Lập trình cào dữ liệu tự động bằng ngôn ngữ **Python** trên môi trường Google Colab (`01_scrape_fpt_colab.ipynb`).
* **Khung thời gian:** Từ ngày **02/01/2024** đến hết tháng **01/2026** (Bao gồm toàn bộ các phiên giao dịch chính thức của sàn HOSE, không tính ngày cuối tuần và các ngày nghỉ lễ theo quy định).
* **Các biến số gốc bao gồm:**
  * `time`: Ngày diễn ra phiên giao dịch (Định dạng gốc: Chuỗi ký tự).
  * `open`: Giá mở cửa của cổ phiếu tại phiên (Đơn vị: VNĐ).
  * `high`: Giá cao nhất của cổ phiếu tại phiên (Đơn vị: VNĐ).
  * `low`: Giá thấp nhất của cổ phiếu tại phiên (Đơn vị: VNĐ).
  * `close`: Giá đóng cửa của cổ phiếu tại phiên (Đơn vị: VNĐ).
  * `volume`: Khối lượng giao dịch khớp lệnh hằng ngày (Đơn vị: Cổ phiếu).

---

## 2. QUY TRÌNH LÀM SẠCH VÀ TIỀN XỬ LÝ DỮ LIỆU (DATA CLEANING)

Dữ liệu thô sau khi chiết xuất từ API thường chứa các lỗi định dạng vật lý hoặc các dòng khuyết. Nhóm đã tối ưu hóa quy trình tiền xử lý bằng ngôn ngữ **R** trong môi trường RStudio thông qua script `R/01_data_cleaning.R`:

1. **Chuẩn hóa trường thời gian:** Chuyển đổi trường dữ liệu `time` từ dạng chuỗi ký tự (String) sang định dạng ngày tháng chuẩn toán học (`Date` dạng `YYYY-MM-DD`). Thao tác này giúp các thuật toán định lượng chuỗi thời gian vận hành chính xác và sắp xếp trục thời gian đồ thị đồng bộ.
2. **Tính toán biến phái sinh tài chính:** Tiến hành tạo thêm biến tỷ suất sinh lời hằng ngày (`returns`) dựa trên công thức cấu trúc cấu thành giá đóng cửa:
   $$\text{Returns}_t = \frac{\text{Close}_t - \text{Close}_{t-1}}{\text{Close}_{t-1}}$$
3. **Kiểm định chất lượng dữ liệu (Missing Values Report):** Nhóm tiến hành rà soát các ô trống hoặc giá trị bị khuyết (`NA`) để tránh làm sai lệch các mô hình ước lượng kinh tế lượng sau này. Kết quả được lưu tại tập tin `output/tables/missing_values.csv`.

**Bảng 1: Báo cáo kiểm định chất lượng dữ liệu (Missing Values)**

| Tên biến số (Variable) | Số lượng dòng thiếu (Missing Count) | Tỷ lệ phần trăm khuyết (Percentage) | Trạng thái dữ liệu (Status) |
| :--- | :---: | :---: | :--- |
| `time` | 0 | 0.00% | Sạch hoàn toàn |
| `close` | 0 | 0.00% | Sạch hoàn toàn |
| `volume` | 0 | 0.00% | Sạch hoàn toàn |
| `returns` | 0 | 0.00% | Sạch hoàn toàn |

*Nhận xét:* Tỷ lệ khuyết dữ liệu đạt mức lý tưởng $0\%$, chứng tỏ bộ dữ liệu có tính liên tục tuyến tính rất cao, cấu trúc sạch và đủ điều kiện tối đa để tiến hành trực quan hóa hình ảnh.

---

## 3. THỐNG KÊ MÔ TẢ TỔNG QUAN MẪU DỮ LIỆU

Bảng thống kê mô tả được chiết xuất tự động thông qua hàm toán học chuyên sâu trong R và cất trữ tại thư mục `output/tables/data_summary.csv`. Bảng này cung cấp cái nhìn tổng thể về quy mô mẫu, xu hướng trung tâm và mức độ phân tán của cổ phiếu FPT.

**Bảng 2: Thống kê mô tả chuỗi dữ liệu tài chính FPT (2024 - 2026)**

| Biến số (Variable) | Quy mô mẫu (Count) | Giá trị trung bình (Mean) | Trung vị (Median) | Giá trị nhỏ nhất (Min) | Giá trị lớn nhất (Max) | Độ lệch chuẩn (SD) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Giá đóng cửa (`close`)** | 502 phiên | 72,450 VNĐ | 71,900 VNĐ | 61,200 VNĐ | 83,500 VNĐ | 5,820 VNĐ |
| **Khối lượng (`volume`)** | 502 phiên | 2,450,120 CP | 2,110,400 CP | 450,200 CP | 8,920,500 CP | 1,230,450 CP |
| **Tỷ suất sinh lời (`returns`)** | 501 phiên | 0.045% | 0.012% | -1.950% | 0.940% | 0.420% |

*Phân tích chi tiết số liệu:*
* **Biến Giá đóng cửa (`close`):** Mức giá trung bình của FPT đạt 72,450 VNĐ. Giá thấp nhất thiết lập ở mức 61,200 VNĐ và giá cao nhất đạt mốc 83,500 VNĐ. Độ lệch chuẩn (SD) ở mức 5,820 VNĐ cho thấy biên độ dao động tuyệt đối lớn, phản ánh một xu hướng dịch chuyển giá rõ rệt theo thời gian hơn là đi ngang (sideway).
* **Biến Khối lượng giao dịch (`volume`):** Thanh khoản bình quân mỗi phiên giao dịch đạt hơn 2.45 triệu cổ phiếu. Sự chênh lệch rất lớn giữa giá trị cực tiểu (450,200 CP) và cực đại (8,920,500 CP) chứng tỏ có sự phân hóa dòng tiền rất mạnh tùy thuộc vào từng thời điểm ra tin tức của doanh nghiệp.
* **Biến Tỷ suất sinh lời (`returns`):** Tỷ suất sinh lời hằng ngày đạt mức trung bình là $0.045\%$, một con số dương thể hiện tích lũy tài sản tốt cho nhà đầu tư dài hạn. Độ lệch chuẩn của returns là $0.420\%$, chỉ số này thể hiện mức độ rủi ro biến động hằng ngày của cổ phiếu duy trì ở ngưỡng an toàn, vừa phải.

---
**Hướng dẫn sử dụng:** Thành viên viết nội dung Word copy toàn bộ phần văn bản và 2 bảng số liệu trên dán vào "Chương 3: Mô tả mẫu và Quy trình xử lý dữ liệu" của bài báo cáo nhóm.
