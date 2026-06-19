# Hướng dẫn hoàn thành đồ án FPT Stock Analysis

> Cập nhật sau khi audit toàn bộ repository ngày 19/06/2026.  
> Mục tiêu: tạo một bài nộp tái lập được, đúng rubric và có khả năng đạt từ 85/100 trở lên.

## 1. Kết luận nhanh

Dự án **đúng hướng về chủ đề và quy trình**: có dữ liệu thực tế, làm sạch bằng R, trực quan hóa, kiểm định tính dừng, hai mô hình dự báo giá và một mô hình volatility. Tuy nhiên, dự án **chưa ở trạng thái có thể nộp** vì báo cáo Word hiện là file rỗng, `report.Rmd` chưa ghép nội dung, thiếu PowerPoint, nguồn dữ liệu không nhất quán và quy trình thu thập không tái lập được.

Nếu chấm repository ở trạng thái hiện tại, điểm hợp lý chỉ khoảng **58-65/100**. Nếu hoàn thành toàn bộ mục P0 và P1 trong tài liệu này, mức khả thi là **85-92/100**. Đây là ước lượng, không phải điểm chính thức của giảng viên.

## 2. Chấm thử theo rubric

| Tiêu chí | Trọng số | Điểm hiện tại | Sau khi sửa | Nhận định chính |
|---|---:|---:|---:|---|
| Hình thức báo cáo | 10 | 2 | 9 | `report.docx` 0 byte; Rmd rỗng; thiếu nhiều mục bắt buộc và PPTX |
| Làm việc nhóm | 10 | 6 | 9 | Có phân công, nhưng thiếu tên thật, tiến độ, contributions và peer assessment |
| Dữ liệu và bài toán | 10 | 5 | 9 | Bài toán hợp lý; nguồn và quy trình thu thập đang mâu thuẫn, còn 173 dòng volume bằng 0 |
| Sử dụng R và thống kê | 20 | 15 | 18 | Có pipeline R và ADF; thiếu kiểm tra chất lượng, chẩn đoán và script chạy toàn bộ ổn định |
| Trực quan hóa | 20 | 13 | 18 | Có 7 hình, nhưng trục thời gian dày, thang giá sai và diễn giải có chỗ vượt quá bằng chứng |
| Mô hình dữ liệu | 30 | 20 | 27 | Có ARIMA, ETS, GARCH; thiếu benchmark, residual diagnostics và đánh giá GARCH ngoài mẫu |
| **Tổng** | **100** | **61** | **90** | Mục tiêu 90 chỉ đạt khi có artifact cuối và kiểm chứng chéo |

## 3. Các điều kiện chặn nộp bài (P0)

Không nộp trước khi tất cả mục sau đạt:

- [ ] `report/report.docx` mở được và có dung lượng lớn hơn 0 byte.
- [ ] Có file trình bày `.pptx` theo yêu cầu trong PDF đề bài.
- [ ] `report/report.Rmd` tạo được báo cáo từ đầu đến cuối, không còn các chunk trống.
- [ ] Báo cáo có đủ: Abstract, Introduction, Data, Visualization, Modeling, Results & Discussion, Conclusion, Appendices, Contributions, References, Peer Assessment.
- [ ] Thống nhất duy nhất một nguồn dữ liệu. Hiện README ghi `vnstock`, notebook dùng API TCBS, báo cáo ghi Yahoo Finance.
- [ ] Notebook tái tạo đúng `data/raw/FPT_stock_data.csv`: thời gian 2015-01-01 đến 2026-06-08 và tên cột `date`.
- [ ] Ghi đúng tên 3 thành viên, mã sinh viên và nhiệm vụ; bỏ `Nhóm ...`, `Người 1/2/3` trong bản nộp.
- [ ] Có một entry point như `R/run_all.R` để chạy các script theo thứ tự; đây cũng là file mã nguồn R chính để nộp kèm.
- [ ] Chạy lại toàn bộ trên một máy khác hoặc một R session sạch và lưu log kiểm thử.

## 4. Các lỗi kỹ thuật phải sửa (P1)

### Dữ liệu và khả năng tái lập

1. Chọn nguồn thật sự đã sinh ra dữ liệu hiện tại và trích dẫn URL/ngày truy cập. Không được tuyên bố `vnstock` nếu file thực tế đến từ Yahoo/TCBS.
2. Điều tra 173 dòng `volume == 0`. Báo cáo hiện nói đã loại ngày nghỉ nhưng `R/01_data_cleaning.R` không loại. Quyết định giữ hoặc loại phải có lý do và số liệu trước/sau.
3. Kiểm tra: ngày trùng, thứ tự ngày, `high >= open/close`, `low <= open/close`, giá dương, volume không âm và missing values.
4. Chỉ dùng một biến lợi suất, ưu tiên log return `return`. Hiện visualization tạo thêm simple return `returns`, gây không nhất quán với GARCH.
5. Giải thích giá đã điều chỉnh hay chưa. Không gọi là adjusted close nếu nguồn không cung cấp bằng chứng.

### Phân tích và mô hình

1. Thêm benchmark naive/random-walk. ARIMA/ETS chỉ được gọi là tốt khi thắng benchmark ngoài mẫu, không chỉ vì MAPE nhỏ.
2. Dùng rolling-origin cross-validation hoặc ít nhất nhiều cửa sổ test; một cửa sổ 30 ngày là bằng chứng yếu.
3. ARIMA/ETS: báo cáo `checkresiduals()`, Ljung-Box, ACF phần dư và kiểm tra khoảng dự báo.
4. Trước GARCH: kiểm định ARCH-LM trên return hoặc phần dư mean model; sau GARCH: Ljung-Box trên standardized residuals và residuals bình phương.
5. So sánh sGARCH-Normal với sGARCH-Student-t, eGARCH và GJR-GARCH bằng cùng dữ liệu. Không so AIC của GARCH trực tiếp với RMSE của mô hình giá.
6. Nếu làm ARIMA+XREG, không dùng `volume`/`daily_range` tương lai thật ở tập test như thể đã biết lúc dự báo. Phải dự báo xreg, dùng biến trễ, hoặc mô tả rõ đây là conditional forecast.
7. Chỉ dùng SARIMA chu kỳ 5 khi ACF/weekday analysis có bằng chứng mùa vụ. Không mặc định `frequency = 5` là đủ chứng minh.
8. Không kết luận GARCH “tối ưu” chỉ vì AIC âm. AIC chỉ có ý nghĩa tương đối giữa các model fit trên cùng response/sample.

### Biểu đồ

1. Sửa `close_price.png`: bỏ `breaks = seq(60000, 80000, ...)`, vì dữ liệu chạy từ khoảng 6,955 đến 129,856 nên nhãn trục Y hiện sai lệch.
2. Giảm nhãn trục X của biểu đồ dài hạn xuống mỗi 1-2 năm. `garch_volatility.png` hiện có nhãn chồng kín.
3. Histogram hiện vẽ empirical density nhưng ghi “so sánh phân phối chuẩn”. Thêm đường normal density thật và QQ-plot, hoặc sửa subtitle.
4. Thêm ACF/PACF return, squared return, QQ-plot và boxplot return theo weekday; mỗi hình phải có 2-4 câu diễn giải dựa trên bằng chứng.
5. Không suy diễn từ đồ thị rằng thanh khoản tăng do quỹ/tổ chức hoặc giá tăng do chip, COVID nếu không có nguồn trích dẫn.

### Báo cáo

1. Ghép các section vào `report.Rmd` bằng child documents hoặc `knitr::knit_child()`; chèn bảng CSV và hình bằng code thay vì copy thủ công.
2. Sửa mục nguồn dữ liệu, công thức return, tên file hình và số liệu cho đồng nhất với code.
3. Không dùng “chấp nhận H0”; dùng “chưa đủ bằng chứng bác bỏ H0”. P-value của `adf.test` bị chặn ở 0.01 phải trình bày là `<= 0.01`, không phải giá trị chính xác.
4. Bỏ khuyến nghị mua/bán, cắt lỗ và VaR khi dự án chưa triển khai/backtest VaR. Thay bằng kết luận học thuật và giới hạn áp dụng.
5. Thêm bảng contributions và peer assessment có nhận xét ưu điểm, hạn chế, mức hoàn thành của từng người.
6. Tạo slide 8-12 trang: bài toán, dữ liệu, pipeline, EDA, stationarity, forecast comparison, volatility, kết luận, đóng góp.

## 5. Phân công cho 3 thành viên

Ba người làm song song trên branch riêng. Mỗi pull request phải kèm danh sách output thay đổi và bằng chứng đã chạy.

Kế hoạch riêng để Người 2 và Người 3 làm trong lúc chờ dữ liệu cuối: [`docs/ke_hoach_nguoi_2_3_hom_nay.md`](ke_hoach_nguoi_2_3_hom_nay.md).

### Thành viên 1: Dữ liệu, tái lập và trực quan hóa

**File phụ trách:** notebook, `R/01_data_cleaning.R`, `R/02_visualization.R`, `data/README_data.md`, phần Data/Visualization.

Hướng dẫn cầm tay chỉ việc, code và prompt soạn sẵn: [`docs/guide_nguoi_1.md`](guide_nguoi_1.md).

- [ ] Xác minh nguồn dữ liệu thật; sửa notebook để tạo đúng schema/giai đoạn hiện tại.
- [ ] Thêm toàn bộ data-quality checks và bảng `data_quality_report.csv`.
- [ ] Quyết định cách xử lý 173 volume-zero rows, ghi rõ trong báo cáo.
- [ ] Hợp nhất về log return `return`.
- [ ] Sửa trục các hình hiện tại; thêm ACF/PACF, QQ-plot, normal overlay, squared returns và weekday plot.
- [ ] Sửa phần Data/Visualization, xóa các khẳng định không có nguồn.

**Nghiệm thu:** chạy từ raw CSV sinh đúng 2,960 dòng (hoặc ghi rõ số mới sau xử lý), không trùng ngày, không vi phạm OHLC, hình đọc được ở tỷ lệ 100% trong Word.

### Thành viên 2: Dự báo giá và kiểm định thống kê

**File phụ trách:** `R/03_stationarity_arima_ets.R`, bảng forecast, hình forecast, phần Modeling.

- [ ] Thêm naive benchmark và rolling-origin evaluation.
- [ ] Thêm MAE bên cạnh RMSE/MAPE; lưu cùng một bảng tidy.
- [ ] Thêm residual diagnostics và xuất bảng/ảnh kiểm định.
- [ ] Triển khai ETS damped; chỉ triển khai SARIMA/ARIMAX khi có lập luận hợp lệ.
- [ ] Bảo đảm mọi model dùng cùng train/test folds để so sánh công bằng.
- [ ] Viết lại nhận xét theo kết quả thật; không gắn nhãn “rất chính xác” chỉ từ một test window.

**Nghiệm thu:** bảng có model, fold, RMSE, MAE, MAPE; mô hình được chọn thắng naive ổn định qua các fold và phần dư được thảo luận.

### Thành viên 3: GARCH, tích hợp báo cáo và bài nộp

**File phụ trách:** `R/04_garch_volatility.R` đến `R/06_export_report_tables.R`, `R/run_all.R`, `report/`, slide.

- [ ] Thêm ARCH-LM, Student-t, eGARCH, GJR-GARCH và residual diagnostics.
- [ ] Tạo bảng GARCH comparison thống nhất; diễn giải significance, persistence và asymmetry đúng công thức từng model.
- [ ] Sửa model comparison để tách forecast-price và volatility thành hai bảng.
- [ ] Hoàn thiện `report.Rmd`, chèn tự động section/bảng/hình và knit Word.
- [ ] Viết Abstract, References, Contributions, Peer Assessment; điền tên nhóm.
- [ ] Tạo `.pptx`, kiểm tra link/ảnh/font và điều phối kiểm thử chéo.

**Nghiệm thu:** `Rscript R/run_all.R` và render báo cáo thành công trong session sạch; DOCX/PPTX mở được; không còn placeholder.

## 6. Thứ tự thực hiện nhanh

### Vòng 1: Cứu bài nộp

1. Thành viên 1 chốt nguồn và schema dữ liệu.
2. Thành viên 2 và 3 chỉ bắt đầu chạy model cuối sau khi nhận checksum/file sạch đã chốt.
3. Thành viên 3 dựng ngay khung báo cáo đủ 11 mục và slide, không chờ model cải tiến.
4. Cả nhóm hoàn thành P0, tạo được Word/PPTX tối thiểu nhưng đúng cấu trúc.

### Vòng 2: Nâng điểm

1. Thành viên 1 hoàn thiện quality checks và hình bổ sung.
2. Thành viên 2 hoàn thiện benchmark, cross-validation và diagnostics.
3. Thành viên 3 hoàn thiện GARCH variants và diagnostics.
4. Cập nhật toàn bộ bảng/hình tự động, không nhập số thủ công vào báo cáo.

### Vòng 3: Kiểm chứng chéo

1. Thành viên 1 kiểm tra phần ARIMA/ETS và đối chiếu mọi số với CSV.
2. Thành viên 2 kiểm tra GARCH, nguồn dữ liệu và logic diễn giải.
3. Thành viên 3 chạy repository từ đầu, knit Word, mở PPTX và kiểm tra checklist rubric.

## 7. Lệnh chạy chuẩn đề xuất

```r
# Từ thư mục gốc project
source("R/run_all.R")
rmarkdown::render("report/report.Rmd", output_format = "word_document")
```

`R/run_all.R` nên gọi lần lượt `00_config.R` đến `06_export_report_tables.R`, dừng ngay khi thiếu package/input và ghi `sessionInfo()` vào `output/session_info.txt`. Không tự động `install.packages()` bên trong pipeline; liệt kê dependency trong README hoặc `renv.lock`.

## 8. Checklist trước khi nộp

- [ ] Word và PowerPoint mở được; không có file 0 byte.
- [ ] Có một file R entry point và repository đầy đủ để kiểm chứng.
- [ ] Không còn `...`, `xxx`, “đang hoàn thiện”, tên người giả hoặc output “dự kiến” trong tài liệu chính.
- [ ] Mọi số trong README, báo cáo và slide khớp CSV mới nhất.
- [ ] Mọi hình được gọi đúng tên file và có caption/nguồn.
- [ ] Nguồn dữ liệu, khoảng thời gian, số quan sát và loại giá nhất quán ở mọi nơi.
- [ ] Mỗi kết luận về model có metric/diagnostic đi kèm.
- [ ] Contributions và peer assessment đã được cả 3 người đồng ý.
- [ ] Một người không viết module đó đã chạy thử và ký xác nhận checklist.
- [ ] Tạo bản nộp cuối từ commit/tag cố định; không chỉnh trực tiếp sau khi kiểm thử.

## 9. Những việc không nên ưu tiên

- Không thêm LSTM, Prophet, Transformer hoặc sentiment analysis trước khi P0/P1 hoàn tất.
- Không tạo thêm nhiều model chỉ để đủ số lượng; ba model được chẩn đoán đúng có giá trị hơn tám model chỉ có AIC.
- Không dành thời gian chỉnh màu/font trước khi pipeline, báo cáo và nguồn dữ liệu nhất quán.
- Không copy bảng thủ công từ Excel vào Word nếu R Markdown có thể sinh trực tiếp.
