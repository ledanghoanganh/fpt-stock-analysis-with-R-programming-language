# 🔥 DANH SÁCH CÔNG VIỆC CHỐT SỔ DỰ ÁN (FINAL TASKS)

Chào anh em, hiện tại giai đoạn **Code (Lập trình và Xuất dữ liệu) đã hoàn thành 100%**. Tiến độ dự án đang ở mức **90%**.
Dưới đây là 10% công việc cuối cùng (lắp ráp số liệu vào báo cáo Word và cập nhật README). Mọi người check tên mình và làm đúng theo task nhé để chuẩn bị nộp bài tập lớn.

---

## 👤 Người 1: Data & Visualization
*Phụ trách: [Điền tên Người 1]*

- [ ] **Kiểm tra biểu đồ trên Word:** Mở bản báo cáo Word cuối cùng, rà soát lại 4 biểu đồ (`close_price.png`, `volume.png`, `returns.png`, `return_distribution.png`) xem hiển thị có bị mờ, đè chữ hay sai tỷ lệ không.
- [ ] **Rà soát nội dung phân tích:** Đọc lại phần nội dung trong file `report/sections/03_visualization.md` để đảm bảo văn phong phù hợp với toàn bài.
- [ ] **Cập nhật README.md (Mục 12.1):** Mở file Excel `FPT_Final_Report_Tables.xlsx` -> Sheet `Thong_Ke_Mo_Ta` để lấy các số liệu thực tế (min, max, mean, độ lệch chuẩn...) và điền vào Mục 12.1 của `README.md`.

---

## 👤 Người 2: Modeling ARIMA/ETS
*Phụ trách: [Điền tên Người 2]*

- [ ] **Hoàn thiện nội dung Word (Chương 4):** Mở file Excel `FPT_Final_Report_Tables.xlsx` -> Sheet `So_Sanh_Mo_Hinh`, copy bảng đó dán vào phần báo cáo `04_modeling_arima_ets.md`.
- [ ] **Bổ sung nhận xét đánh giá:** Ghi chú rõ ràng vào báo cáo luận điểm chọn mô hình: *"ARIMA cho kết quả dự báo ưu việt hơn ETS nhờ chỉ số sai số MAPE thấp hơn (2.19% so với 2.29%)"*.
- [ ] **Cập nhật README.md (Mục 12.2 & 12.3):** Điền kết quả ADF Test (Tính dừng) và chèn lại bảng RMSE/MAPE vào tài liệu README chung.

---

## 👤 Người 3: GARCH & Tổng hợp Report
*Phụ trách: [Điền tên Người 3]*

- [ ] **Hoàn thiện Chương 5 & 6:** Các file `05_garch_results_discussion.md` và `06_conclusion.md` đã được soạn thảo sẵn nội dung phân tích cực kỳ chi tiết (ý nghĩa AIC, BIC, tính dai dẳng của biến động). Chỉ cần đọc lại cho trơn tru và copy bảng `Tham_So_GARCH` từ Excel dán vào để minh họa.
- [ ] **Cập nhật README.md (Mục 12.4, 12.5 & 16):** Điền số liệu tham số GARCH (omega, alpha, beta), chốt lại kết luận và điền Bảng Đóng góp thành viên (Peer Assessment).
- [ ] **XUẤT BÁO CÁO CUỐI CÙNG (KNIT TO WORD):** Mở file `report/report.Rmd` bằng RStudio, nhấn nút **Knit to Word** để hệ thống tự động gom tất cả các file markdown thành bản `report.docx` hoàn chỉnh. Tinh chỉnh lại lề, font chữ nếu cần trước khi đem nộp.

---

💡 **Lưu ý chung cho cả team:**
- Tất cả các bảng biểu đều lấy từ file **`output/tables/FPT_Final_Report_Tables.xlsx`** (đã được tự động tô màu xanh học thuật và kẻ viền, chỉ cần Ctrl+C & Ctrl+V thẳng vào Word là auto đẹp).
- Sau khi xong task nhớ đánh dấu [x] và push lên Git báo lại cho cả nhóm. Chúc team mình lấy điểm tuyệt đối! 🎯
