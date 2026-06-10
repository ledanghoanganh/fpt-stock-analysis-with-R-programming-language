# BÁO CÁO QUY TRÌNH XỬ LÝ VÀ LÀM SẠCH DỮ LIỆU CHUỖI THỜI GIAN (FPT 2015 - 2026)

## 1. Nguồn dữ liệu và Phạm vi nghiên cứu
* **Mã cổ phiếu:** FPT (Công ty Cổ phần FPT).
* **Sàn giao dịch:** Sở Giao dịch Chứng khoán Thành phố Hồ Chí Minh (HOSE).
* **Nguồn thu thập:** Dữ liệu lịch sử chuẩn hóa quốc tế từ Yahoo Finance (mã định danh: `FPT.VN`).
* **Khoảng thời gian:** Từ ngày 01/01/2015 đến ngày 09/06/2026 (Tổng cộng gần 11.5 năm).
* **Tần suất quan sát:** Theo ngày giao dịch thực tế (Daily).

## 2. Quy trình Kỹ thuật & Làm sạch dữ liệu trong R
Dữ liệu thô sau khi cào từ Google Colab được đưa vào tập lệnh `R/01_data_cleaning.R` để thực hiện các bước chuẩn hóa bắt buộc nhằm phục vụ phân tích định lượng chuỗi thời gian:
1. **Đồng bộ hóa nhãn thời gian:** Chuyển đổi cột `date` về định dạng `Date` chuẩn dạng `YYYY-MM-DD`.
2. **Lọc bỏ ngày nghỉ:** Loại bỏ hoàn toàn các ngày cuối tuần (Thứ Bảy, Chủ Nhật) và các ngày lễ Tết không phát sinh giao dịch để tránh hiện tượng chuỗi thời gian bị đi ngang ảo (giá đứng im, volume bằng 0).
3. **Tính toán Tỷ suất sinh lời hằng ngày (Daily Returns):** Định lượng phần trăm thay đổi giá hằng ngày dựa trên Giá đóng cửa đã điều chỉnh chia tách và cổ tức (`adj close`), áp dụng công thức:
   $$R_t = \frac{P_t - P_{t-1}}{P_{t-1}}$$

## 3. Thống kê tỷ lệ khuyết thiếu (Missing Values)
Kết quả kiểm tra từ tệp cấu trúc `missing_values_clean.csv` cho thấy trạng thái dữ liệu đạt độ sạch lý tưởng:

| Biến số | Số lượng dòng khuyết thiếu (NA) | Tỷ lệ khuyết thiếu (%) | Biện pháp xử lý |
| :--- | :---: | :---: | :--- |
| `date` | 0 | 0.00% | Không cần xử lý |
| `open` | 0 | 0.00% | Không cần xử lý |
| `high` | 0 | 0.00% | Không cần xử lý |
| `low` | 0 | 0.00% | Không cần xử lý |
| `close` | 0 | 0.00% | Không cần xử lý (Đã đồng bộ giá Adj Close) |
| `volume` | 0 | 0.00% | Không cần xử lý |
| `returns` | 1 | 0.03% | Bị khuyết duy nhất ở phiên đầu tiên (01/01/2015) do không có giá t-1 để đối chiếu tính tỷ suất sinh lời. Tiến hành loại bỏ dòng đầu tiên này khi đưa vào mô hình định lượng. |

## 4. Thống kê mô tả chuỗi dữ liệu làm sạch
Bảng số liệu tổng hợp từ `data_summary_clean.csv` mô tả các đặc tính thống kê cốt lõi của mã FPT qua 2.960 phiên giao dịch thực tế:

| Biến số | Số quan sát | Trung bình | Trung vị | Thấp nhất | Cao nhất | Độ lệch chuẩn |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Giá đóng cửa (VNĐ)** | 2.960 | 40.914,68 | 21.598,69 | 6.955,45 | 129.855,73 | 34.715,05 |
| **Khối lượng giao dịch** | 2.960 | 3.943.219 | 2.738.958 | 0 | 415.709.889 | 9.680.991 |
| **Tỷ suất sinh lời ngày** | 2.959 | 0,0009 (0.09%) | 0,0000 (0.00%) | -0,0699 (-6.99%) | 0,0926 (9.26%) | 0,0161 (1.61%) |

* **Nhận xét sơ bộ:**
  * Giá đóng cửa có độ lệch chuẩn rất lớn (34.715,05 VNĐ) so với mức trung bình, chứng tỏ FPT là một cổ phiếu có xu hướng tăng trưởng bứt phá rất mạnh (Bull-trend kéo dài từ năm 2015 đến năm 2026).
  * Tỷ suất sinh lời hằng ngày trung bình đạt mức dương (+0.09%/ngày). Biên độ biến động hằng ngày dao động từ giảm sàn sát mức -7.0% cho đến tăng trần sát mức +9.3%, thể hiện tính động lực cao của chuỗi thời gian tài chính này.
