# MASTER DOCUMENTATION

## Phân tích và dự báo cổ phiếu FPT bằng R

**Môn học:** Lập trình R cho phân tích  
**Nhóm:** 06
**Giảng viên:** TS. Phan Thị Thể

| Thành viên | MSSV | Tỷ lệ | Vai trò chính |
|---|---:|---:|---|
| Trần Thiên Lực | 24133037 | 30% | Dữ liệu, làm sạch, kiểm tra chất lượng và trực quan hóa |
| Nguyễn Đức Học | 24162039 | 35% | Kiểm định tính dừng, dự báo giá và đánh giá ngoài mẫu |
| Lê Đặng Hoàng Anh | 24162006 | 35% | GARCH, diagnostics, so sánh mô hình và tích hợp báo cáo |

---

## Mục lục

1. [Cách sử dụng tài liệu](#1-cách-sử-dụng-tài-liệu)
2. [Dự án giải quyết bài toán gì](#2-dự-án-giải-quyết-bài-toán-gì)
3. [Bức tranh tổng thể trong 10 phút](#3-bức-tranh-tổng-thể-trong-10-phút)
4. [Kiến thức R tối thiểu](#4-kiến-thức-r-tối-thiểu)
5. [Kiến thức tài chính và dữ liệu OHLCV](#5-kiến-thức-tài-chính-và-dữ-liệu-ohlcv)
6. [Chuỗi thời gian từ số 0](#6-chuỗi-thời-gian-từ-số-0)
7. [Nguồn dữ liệu và khả năng tái lập](#7-nguồn-dữ-liệu-và-khả-năng-tái-lập)
8. [Làm sạch và kiểm tra chất lượng](#8-làm-sạch-và-kiểm-tra-chất-lượng)
9. [Phân tích khám phá và trực quan hóa](#9-phân-tích-khám-phá-và-trực-quan-hóa)
10. [Tính dừng, unit root và ADF](#10-tính-dừng-unit-root-và-adf)
11. [Forecast và cách đánh giá đúng](#11-forecast-và-cách-đánh-giá-đúng)
12. [Các mô hình dự báo giá](#12-các-mô-hình-dự-báo-giá)
13. [Residual diagnostics cho forecast](#13-residual-diagnostics-cho-forecast)
14. [Volatility, ARCH và GARCH](#14-volatility-arch-và-garch)
15. [Bốn specification GARCH của dự án](#15-bốn-specification-garch-của-dự-án)
16. [Diagnostics và lựa chọn GARCH](#16-diagnostics-và-lựa-chọn-garch)
17. [Đọc code theo từng file](#17-đọc-code-theo-từng-file)
18. [Đọc toàn bộ output](#18-đọc-toàn-bộ-output)
19. [Cách chạy dự án từ đầu](#19-cách-chạy-dự-án-từ-đầu)
20. [Kiến thức riêng cho Người 1](#20-kiến-thức-riêng-cho-người-1)
21. [Kiến thức riêng cho Người 2](#21-kiến-thức-riêng-cho-người-2)
22. [Kiến thức riêng cho Người 3](#22-kiến-thức-riêng-cho-người-3)
23. [Kịch bản báo cáo chung](#23-kịch-bản-báo-cáo-chung)
24. [Ngân hàng câu hỏi phản biện](#24-ngân-hàng-câu-hỏi-phản-biện)
25. [Lỗi thường gặp và xử lý](#25-lỗi-thường-gặp-và-xử-lý)
26. [Giới hạn và cách phát triển dự án](#26-giới-hạn-và-cách-phát-triển-dự-án)
27. [Checklist trước khi nộp](#27-checklist-trước-khi-nộp)
28. [Bảng thuật ngữ](#28-bảng-thuật-ngữ)

---

# 1. Cách sử dụng tài liệu

Tài liệu này được viết với giả định người đọc chưa biết R, chưa biết chuỗi thời
gian và chưa biết GARCH. Không cần đọc mọi công thức ngay từ lần đầu.

## 1.1 Nếu chỉ còn 30 phút

Đọc theo thứ tự:

1. Phần 2: dự án giải quyết bài toán gì.
2. Phần 3: toàn bộ pipeline và kết quả chính.
3. Phần riêng của mình: phần 20, 21 hoặc 22.
4. Phần 23 và 24: kịch bản báo cáo và câu hỏi phản biện.

## 1.2 Nếu có nửa ngày

Đọc phần 2 đến phần 18, sau đó tự mở các CSV được nhắc tới. Mỗi khi gặp một
con số, hãy tìm nó trong `output/tables` thay vì học thuộc không có ngữ cảnh.

## 1.3 Nếu muốn chạy lại dự án

Đọc phần 19. Lệnh chính là:

```r
source("R/run_all.R")
```

hoặc trong PowerShell:

```powershell
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" -e "source('R/run_all.R')"
```

## 1.4 Nguyên tắc học

- Hiểu câu hỏi trước, công thức sau.
- Luôn phân biệt **giá** với **lợi suất**.
- Luôn phân biệt **mean forecast** với **volatility model**.
- Không kết luận chỉ từ một p-value hoặc một metric.
- Không đọc một con số tách khỏi sample, đơn vị và phương pháp tạo ra nó.

## 1.5 Trạng thái chính thức của bản tài liệu này

Tài liệu đã được đối chiếu với pipeline và output ngày **21/06/2026**. Lần chạy
nghiệm thu cuối đã hoàn thành toàn bộ sáu module, fit 7 phương pháp dự báo giá,
chạy 27 rolling-origin folds, fit 4 GARCH specification và render thành công hai
tài liệu Word. File xác nhận là `output/pipeline_log.txt`.

Không hiểu “hoàn thành” là mọi mô hình đều tốt. Hoàn thành nghĩa là code chạy
đầu-cuối, kết quả được đánh giá đúng và các hạn chế được báo cáo trung thực.

## 1.6 Bản đồ đọc nhanh theo nhu cầu

| Khi cần làm việc này | Đọc phần | Mở file thực tế |
|---|---:|---|
| Hiểu dự án trong 10 phút | 2-3 | `README.md` |
| Giải thích dữ liệu và biểu đồ | 5, 7-9, 20 | `R/01_data_cleaning.R`, `R/02_visualization.R` |
| Giải thích ADF và forecast | 10-13, 21 | `R/03_stationarity_arima_ets.R` |
| Giải thích GARCH và lựa chọn model | 14-16, 22 | `R/04_garch_volatility.R`, `R/05_model_comparison.R` |
| Học riêng toàn bộ phần Người 3 | Tài liệu riêng | `docs/GUIDE_NGUOI_3.md` |
| Chạy lại toàn bộ dự án | 19 | `R/run_all.R` |
| Chuẩn bị thuyết trình | 23-24 | `presentation/khung_noi_dung_slide.docx` |
| Kiểm tra con số cuối | 18, Phụ lục A | `output/tables/` |

## 1.7 Từ câu hỏi đến bằng chứng

| Câu hỏi | Bằng chứng chính |
|---|---|
| Dữ liệu có sạch không? | `data_quality_report.csv`, `missing_values.csv` |
| Chuỗi nào dừng? | `stationarity_tests.csv` |
| Model giá nào dẫn holdout/CV? | `price_forecast_comparison.csv` |
| Residual forecast còn tự tương quan không? | `forecast_diagnostics.csv` |
| Return có ARCH effect không? | `garch_diagnostics.csv` |
| Vì sao chọn eGARCH-t? | `volatility_model_comparison.csv` |
| Tham số eGARCH-t bằng bao nhiêu? | `garch_parameters.csv` |
| Pipeline cuối có chạy xong không? | `pipeline_log.txt` |

---

# 2. Dự án giải quyết bài toán gì

## 2.1 Đối tượng phân tích

Dự án phân tích cổ phiếu FPT trên Yahoo Finance với ticker `FPT.VN`. Dữ liệu
gồm giá mở cửa, cao nhất, thấp nhất, đóng cửa và khối lượng theo ngày.

## 2.2 Hai bài toán hoàn toàn khác nhau

### Bài toán A: dự báo mức giá

Câu hỏi: “Trong 30 phiên cuối, mô hình dự báo giá đóng cửa gần giá thực tế đến
mức nào?”

Response là `close`, đơn vị gần với VND. Nhóm so sánh:

- Naive;
- Drift;
- ARIMA;
- SARIMA;
- ETS;
- ETS Damped;
- ARIMAX với biến trễ.

Metric chính là RMSE, MAE và MAPE.

### Bài toán B: mô hình hóa volatility

Câu hỏi: “Mức độ bất định của return thay đổi theo thời gian như thế nào?”

Response là `return`, không phải `close`. Nhóm so sánh:

- sGARCH-Normal;
- sGARCH-Student-t;
- eGARCH-Student-t;
- GJR-GARCH-Student-t.

Tiêu chí gồm AIC/BIC, convergence, residual diagnostics, sign bias, stability
và goodness-of-fit.

## 2.3 Vì sao không gộp hai bài toán thành một bảng xếp hạng

RMSE giá và AIC GARCH đo hai thứ khác nhau. Không thể nói “ARIMAX tốt hơn
eGARCH” vì:

- ARIMAX dự báo mức giá;
- eGARCH mô hình hóa phương sai có điều kiện của return;
- response, đơn vị và mục tiêu không giống nhau.

`R/05_model_comparison.R` vì vậy tạo hai bảng riêng:

- `price_forecast_comparison.csv`;
- `volatility_model_comparison.csv`.

## 2.4 Giá trị học thuật của dự án

Dự án minh họa một quy trình đầy đủ:

1. Xác định nguồn dữ liệu.
2. Kiểm tra và làm sạch.
3. Trực quan hóa.
4. Kiểm định giả thuyết.
5. Huấn luyện nhiều mô hình.
6. Đánh giá ngoài mẫu.
7. Chẩn đoán phần dư.
8. Nêu hạn chế thay vì phóng đại kết quả.

Dự án không đưa ra khuyến nghị mua hoặc bán FPT.

---

# 3. Bức tranh tổng thể trong 10 phút

## 3.1 Pipeline

```text
Yahoo Finance (FPT.VN)
        |
        v
notebooks/01_scrape_fpt_colab.ipynb
        |
        v
data/raw/FPT_stock_data.csv              2.960 dòng
        |
        v
R/01_data_cleaning.R
        |
        +--> output/tables/data_quality_report.csv
        v
data/processed/fpt_clean.csv              2.787 dòng
        |
        +--> R/02_visualization.R          9 biểu đồ EDA
        |
        +--> R/03_stationarity_arima_ets.R forecast + CV
        |
        +--> R/04_garch_volatility.R       4 GARCH
        |
        v
R/05_model_comparison.R
        |
        v
R/06_export_report_tables.R + report/report.Rmd
        |
        v
report/report.docx
```

## 3.2 Những con số cần nhớ và hiểu

| Nội dung | Kết quả |
|---|---:|
| Dòng dữ liệu thô | 2.960 |
| Dòng `volume = 0` bị loại | 173 |
| Dòng dữ liệu sạch | 2.787 |
| Log return hợp lệ | 2.786 |
| Giai đoạn sạch | 2015-01-05 đến 2026-06-08 |
| Mean return mỗi phiên | 0,0008365, xấp xỉ 0,0837% |
| SD return mỗi phiên | 0,016582, xấp xỉ 1,658% |
| Return nhỏ nhất | -7,248% |
| Return lớn nhất | 8,853% |
| Holdout | 30 phiên cuối |
| Holdout leader | ETS Damped |
| ETS Damped holdout RMSE | 1.939,13 |
| ETS Damped holdout MAPE | 2,10% |
| Rolling-CV leader trong nhóm có CV | Naive |
| Naive CV mean RMSE | 5.353,94 |
| GARCH candidate cân bằng | eGARCH-Student-t |

## 3.3 Kết luận chính

1. `close` và `log_close` không dừng theo ADF.
2. `return` dừng và có ARCH effect mạnh.
3. ETS Damped đứng đầu holdout nhưng chỉ hơn Naive khoảng 0,72 RMSE.
4. Naive đứng đầu rolling CV; mọi fitted model đều còn residual autocorrelation.
5. Chưa có bằng chứng model phức tạp cải thiện Naive một cách ổn định.
6. GJR-GARCH có AIC thấp nhất nhưng parameter stability không đạt.
7. eGARCH-Student-t có AIC gần GJR và đạt core diagnostics cùng Nyblom
   stability, nên là lựa chọn cân bằng.
8. Pearson GOF bác bỏ distribution fit cho cả bốn GARCH, nên không model nào
   được gọi là hoàn hảo.

---

# 4. Kiến thức R tối thiểu

## 4.1 R là gì

R là ngôn ngữ và môi trường tính toán thống kê. Trong dự án này R đảm nhiệm:

- đọc và ghi CSV;
- xử lý bảng;
- tính return;
- vẽ biểu đồ;
- kiểm định thống kê;
- fit ARIMA, ETS và GARCH;
- render báo cáo Word.

## 4.2 Object và phép gán

```r
x <- 10
ticker <- "FPT.VN"
```

`<-` nghĩa là gán giá trị bên phải cho tên bên trái.

Trong dự án:

```r
ohlc_tolerance <- 1e-8
```

nghĩa là đặt ngưỡng sai số OHLC bằng `0,00000001`.

## 4.3 Vector

Vector là dãy giá trị cùng kiểu:

```r
required_columns <- c("date", "open", "high", "low", "close", "volume")
```

Đoạn này tạo danh sách sáu tên cột bắt buộc.

## 4.4 Data frame và tibble

Data frame giống một bảng Excel. Mỗi hàng là một quan sát, mỗi cột là một biến.
Tibble là phiên bản hiện đại của data frame trong tidyverse.

```r
df <- readr::read_csv("data/processed/fpt_clean.csv")
```

`df$close` chọn cột `close`. `nrow(df)` trả số dòng.

## 4.5 Pipe `%>%`

Pipe chuyển kết quả bước trước vào bước sau:

```r
df_clean <- df_raw %>%
  filter(volume > 0) %>%
  arrange(date)
```

Đọc như câu: “Lấy `df_raw`, giữ volume dương, rồi sắp xếp theo ngày.”

## 4.6 Các động từ dplyr quan trọng

| Hàm | Ý nghĩa | Ví dụ dự án |
|---|---|---|
| `select()` | chọn cột | chọn biến xreg |
| `filter()` | chọn hàng | bỏ return NA |
| `mutate()` | tạo/sửa cột | tạo `log_close`, `return` |
| `arrange()` | sắp xếp hàng | sắp theo `date` |
| `summarise()` | tổng hợp | mean RMSE theo CV |
| `group_by()` | chia nhóm | tổng hợp theo model |
| `left_join()` | ghép bảng | ghép metric và diagnostics |

## 4.7 NA và `na.rm = TRUE`

`NA` là giá trị thiếu. Return đầu tiên bắt buộc là NA vì không có phiên trước.

```r
mean(df$return, na.rm = TRUE)
```

`na.rm = TRUE` yêu cầu bỏ NA trước khi tính trung bình.

Không nên tùy tiện xóa mọi NA. Phải hiểu vì sao nó xuất hiện.

## 4.8 Hàm

```r
calculate_forecast_metrics <- function(actual, predicted) {
  rmse <- sqrt(mean((actual - predicted)^2))
  return(rmse)
}
```

Hàm nhận input, thực hiện logic và trả output. Dự án dùng hàm để tránh viết lại
cùng phép tính cho nhiều model.

## 4.9 Điều kiện và dừng pipeline

```r
if (!file.exists(RAW_DATA_PATH)) {
  stop("Không tìm thấy dữ liệu thô")
}
```

Đây là fail-fast: nếu input sai thì dừng sớm, không tạo ra kết quả giả.

## 4.10 Package và namespace

```r
library(forecast)
forecast::Acf(x)
```

`library()` attach package. Cú pháp `forecast::Acf` gọi rõ hàm `Acf` từ package
`forecast`, giúp tránh nhầm hàm trùng tên.

## 4.11 R Markdown

`report/report.Rmd` trộn Markdown, văn bản và R chunk. Khi render, code đọc CSV,
chèn bảng/hình và tạo `report.docx`. Nhờ đó số trong báo cáo không phải gõ tay.

---

# 5. Kiến thức tài chính và dữ liệu OHLCV

## 5.1 Một hàng dữ liệu là gì

Mỗi hàng mô tả một ngày trong dữ liệu Yahoo Finance:

- `date`: ngày;
- `open`: giá mở cửa;
- `high`: giá cao nhất;
- `low`: giá thấp nhất;
- `close`: giá đóng cửa;
- `volume`: khối lượng.

## 5.2 Quan hệ logic OHLC

Thông thường:

```text
high >= max(open, close)
low  <= min(open, close)
```

Nếu close lớn hơn high, dữ liệu mâu thuẫn. Dự án phát hiện một dòng thực sự bất
thường sau khi loại sai số floating-point.

## 5.3 `auto_adjust = TRUE`

Notebook dùng Yahoo Finance với `auto_adjust = TRUE`. Các cột giá được điều
chỉnh để phản ánh corporate actions như chia tách hoặc cổ tức theo cách nhà
cung cấp áp dụng. Vì vậy báo cáo gọi `close` là giá đóng cửa điều chỉnh.

Không nên trộn giá raw chưa điều chỉnh với chuỗi đã điều chỉnh.

## 5.4 Giá và return

Giá trả lời “một cổ phiếu có mức giá bao nhiêu”. Return trả lời “giá thay đổi
tương đối bao nhiêu giữa hai phiên”.

Log return:

```text
r_t = log(P_t) - log(P_(t-1))
    = log(P_t / P_(t-1))
```

Ví dụ nếu giá từ 100.000 lên 102.000:

```text
simple return = 102.000 / 100.000 - 1 = 0,02 = 2%
log return    = log(102.000 / 100.000) ≈ 0,01980 = 1,98%
```

Khi biến động nhỏ, simple return và log return gần nhau nhưng không giống nhau.

## 5.5 Vì sao dùng log return

- Có tính cộng theo thời gian.
- Thường ổn định hơn mức giá.
- Phù hợp với mô hình volatility.
- Không phụ thuộc trực tiếp vào mức giá tuyệt đối.

Trong dữ liệu dự án:

```text
mean(return) = 0,0008365 ≈ 0,0837% mỗi phiên
sd(return)   = 0,016582  ≈ 1,658% mỗi phiên
```

Đây là thống kê mô tả lịch sử, không phải lợi nhuận đảm bảo trong tương lai.

## 5.6 Volume bằng 0

Dữ liệu thô có 173 dòng `volume = 0`. Dự án loại chúng vì chúng không đại diện
cho phiên có giao dịch hữu ích trong chuỗi mô hình. Sau lọc:

```text
2.960 - 173 = 2.787 dòng sạch
```

## 5.7 Volatility là gì

Volatility là mức độ dao động, không phải hướng tăng hay giảm. Return `+5%` và
`-5%` đều là biến động lớn. Vì vậy squared return có thể đại diện thô cho độ
lớn của biến động.

---

# 6. Chuỗi thời gian từ số 0

## 6.1 Chuỗi thời gian khác dữ liệu thông thường

Trong dữ liệu độc lập, có thể shuffle hàng. Trong chuỗi thời gian, thứ tự là
thông tin. Không được dùng dữ liệu tương lai để dự báo quá khứ.

## 6.2 Các thành phần thường gặp

- Level: mức nền của chuỗi.
- Trend: xu hướng dài hạn.
- Seasonality: mẫu lặp có chu kỳ.
- Noise: biến động không giải thích được.
- Conditional variance: độ lớn noise thay đổi theo thời gian.

Giá FPT có trend mạnh. Return quanh gần 0 nhưng độ lớn biến động thay đổi.

## 6.3 Lag

`lag(x, 1)` là giá trị của phiên trước.

```r
lag_return = dplyr::lag(return, 1)
```

Tại ngày t, `lag_return` chỉ dùng thông tin đến t-1, nên hợp lý hơn việc dùng
return của chính ngày t làm biến giải thích.

## 6.4 Leakage

Leakage xảy ra khi mô hình nhìn thấy thông tin không có sẵn tại thời điểm dự
báo. Ví dụ sai:

- dùng volume thật của ngày test để dự báo close của chính ngày đó;
- chuẩn hóa bằng mean tính từ cả train và test;
- shuffle chuỗi trước khi chia train/test.

Dự án dùng các biến trễ `lag_volume`, `lag_daily_range`, `lag_return` cho
ARIMAX để giảm nguy cơ leakage. Tuy nhiên khả năng có đầy đủ xreg trong triển
khai thực tế vẫn phải được thảo luận.

## 6.5 Train, test và holdout

Train dùng để fit model. Test/holdout giả lập tương lai chưa biết để đánh giá.
Dự án giữ 30 phiên cuối làm holdout và không shuffle.

## 6.6 In-sample và out-of-sample

- In-sample: dữ liệu model đã thấy.
- Out-of-sample: dữ liệu model chưa thấy khi fit.

AIC/BIC chủ yếu đánh giá fit in-sample có penalty. RMSE/MAE/MAPE trên holdout
đánh giá forecast out-of-sample. Hai nhóm không thay thế nhau.

---

# 7. Nguồn dữ liệu và khả năng tái lập

## 7.1 Nguồn duy nhất

Nguồn hiện tại là Yahoo Finance, ticker `FPT.VN`. Notebook:

`notebooks/01_scrape_fpt_colab.ipynb`

Tệp đầu ra phải tên:

`FPT_stock_data.csv`

và được đặt tại:

`data/raw/FPT_stock_data.csv`

## 7.2 Khoảng thời gian

Notebook yêu cầu từ `2015-01-01` đến `2026-06-09`. Tham số `end` của API là
mốc loại trừ, nên quan sát cuối là `2026-06-08`.

## 7.3 Raw và processed

- Raw: giữ dữ liệu nhận từ nguồn, phục vụ audit.
- Processed: dữ liệu đã áp dụng quy tắc làm sạch, dùng cho model.

Không nên chỉnh raw bằng Excel rồi quên ghi lại thao tác. Mọi chuyển đổi phải
nằm trong script.

## 7.4 Reproducibility

Một phân tích tái lập khi người khác có thể:

1. Có cùng input.
2. Cài dependency.
3. Chạy cùng code.
4. Nhận bảng và hình tương đương.

Dự án cung cấp `R/run_all.R` và `output/pipeline_log.txt` để hỗ trợ mục tiêu này.

---

# 8. Làm sạch và kiểm tra chất lượng

## 8.1 Schema bắt buộc

`R/01_data_cleaning.R` yêu cầu sáu cột raw:

```r
required_columns <- c("date", "open", "high", "low", "close", "volume")
```

Nếu thiếu cột, script dừng.

## 8.2 Chuẩn hóa kiểu

```r
date = as.Date(date)
open = as.numeric(open)
```

Ngày phải là Date; giá và volume phải là numeric. Nếu để character, phép tính
có thể sai hoặc không chạy.

## 8.3 Các fatal checks

Pipeline dừng nếu có:

- ngày không hợp lệ;
- ngày trùng;
- thiếu OHLCV;
- giá không dương;
- volume âm.

Kết quả hiện tại cho tất cả các check này là 0.

## 8.4 Floating-point tolerance

Máy tính biểu diễn số thực hữu hạn nên hai giá trị về lý thuyết bằng nhau có
thể lệch khoảng `10^-12`. So sánh exact sẽ gọi sai số máy là lỗi dữ liệu.

Dự án dùng:

```r
ohlc_tolerance <- 1e-8
high + ohlc_tolerance < max(open, close)
```

Nhờ đó chỉ còn một lỗi high thực sự thay vì 18 dòng sai lệch cực nhỏ.

## 8.5 Sửa OHLC

Chỉ khi sai vượt tolerance:

```r
high = pmax(open, high, close)
low  = pmin(open, low, close)
```

Dự án chuẩn hóa một dòng sau lọc volume. Việc sửa được ghi trong quality report,
không diễn ra âm thầm.

## 8.6 Tạo biến

```r
log_close = log(close)
return = log_close - lag(log_close)
```

Với 2.787 dòng sạch, chỉ có 2.786 return hợp lệ vì dòng đầu không có lag.

## 8.7 Assertions cuối

Script kiểm tra:

- ít nhất 500 quan sát;
- đúng một NA trong return;
- không ngày trùng;
- không còn lỗi high/low vượt tolerance.

Assertions biến giả định thành điều kiện kiểm chứng được.

## 8.8 Đọc quality report

| Check | Count | Cách hiểu |
|---|---:|---|
| `raw_rows` | 2.960 | số dòng raw |
| `invalid_date` | 0 | không có ngày lỗi |
| `duplicate_date` | 0 | không ngày trùng |
| `missing_ohlcv` | 0 | không thiếu OHLCV |
| `non_positive_price` | 0 | không có giá <= 0 |
| `negative_volume` | 0 | không volume âm |
| `zero_volume` | 173 | số dòng bị loại |
| `ohlc_rows_repaired_after_volume_filter` | 1 | một dòng được chuẩn hóa |

---

# 9. Phân tích khám phá và trực quan hóa

## 9.1 Mục đích EDA

EDA không chỉ để làm đẹp báo cáo. Nó giúp:

- thấy trend;
- phát hiện outlier;
- quan sát distribution;
- tìm volatility clustering;
- gợi ý mô hình và kiểm định tiếp theo.

## 9.2 `close_price.png`

Biểu đồ giá điều chỉnh theo thời gian. Điều cần nói:

- mức giá có xu hướng dài hạn;
- mean và variance của chuỗi mức giá khó ổn định;
- hình chỉ gợi ý non-stationarity, ADF mới là kiểm định định lượng.

Không được nói: “đồ thị chứng minh chắc chắn giá sẽ tiếp tục tăng”.

## 9.3 `volume.png`

Volume biến động mạnh và có cực trị 415.709.889. Mean khoảng 4,19 triệu nhưng
median khoảng 2,91 triệu, cho thấy phân phối lệch và mean bị kéo lên bởi giá trị
lớn.

## 9.4 `returns.png`

Return dao động quanh 0. Có giai đoạn biên độ lớn nối tiếp giai đoạn biên độ
lớn, và giai đoạn yên tĩnh nối tiếp yên tĩnh. Đây là volatility clustering.

## 9.5 `return_distribution.png`

Histogram và density thực nghiệm được so với Normal cùng mean và SD. Nếu đuôi
thực nghiệm dày hơn Normal, Normal có thể đánh giá thấp xác suất biến động cực
đoan. Đây là động cơ thử Student-t trong GARCH.

## 9.6 `qqplot_return.png`

Nếu điểm bám đường thẳng, distribution gần Normal. Lệch ở hai đuôi cho thấy
heavy tails. QQ plot không tự chọn chính xác distribution tốt nhất.

## 9.7 `squared_returns.png`

Squared return loại dấu và giữ độ lớn. Các spike theo cụm là dấu hiệu trực quan
của variance thay đổi theo thời gian.

## 9.8 ACF và PACF

ACF đo tương quan giữa chuỗi và chính nó ở các lag. PACF đo tương quan riêng
phần sau khi kiểm soát các lag ngắn hơn.

- ACF return nhỏ không có nghĩa return độc lập hoàn toàn.
- ACF squared return có thể lớn, cho thấy dependence nằm trong variance.
- AR order và MA order có thể được ACF/PACF gợi ý nhưng dự án dùng
  `auto.arima()` để tìm kiếm có hệ thống.

---

# 10. Tính dừng, unit root và ADF

## 10.1 Stationarity là gì

Theo nghĩa yếu, chuỗi dừng có:

- mean không đổi theo thời gian;
- variance hữu hạn, không đổi;
- covariance phụ thuộc lag, không phụ thuộc thời điểm tuyệt đối.

## 10.2 Unit root là gì

Xét AR(1):

```text
y_t = phi * y_(t-1) + epsilon_t
```

Nếu `phi = 1`:

```text
y_t = y_(t-1) + epsilon_t
```

Đây là random walk có unit root. Shock không tắt dần mà tích lũy vào level.

## 10.3 ADF kiểm định gì

- H0: chuỗi có unit root, không dừng.
- H1: chuỗi không có unit root, dừng theo specification kiểm định.

Quy tắc mức 5%:

- p-value < 0,05: bác bỏ H0;
- p-value >= 0,05: chưa đủ bằng chứng bác bỏ H0.

Nói “fail to reject H0”, không nói “accept H0”.

## 10.4 Kết quả dự án

| Chuỗi | ADF statistic | p-value | Kết luận |
|---|---:|---:|---|
| `close` | -1,7892 | 0,6676 | chưa bác bỏ unit root |
| `log_close` | -1,3194 | 0,8665 | chưa bác bỏ unit root |
| `return` | -13,7914 | 0,01 | bác bỏ unit root |

`adf.test()` báo 0,01 là cận dưới hiển thị, nên nên nói `p <= 0,01`, không nói
p chính xác bằng 0,01 nếu package cảnh báo p-value nhỏ hơn printed value.

## 10.5 Vì sao log không tự làm chuỗi dừng

Log làm giảm scale và biến tăng theo tỷ lệ thành gần tuyến tính hơn, nhưng không
tự loại trend hoặc unit root. Kết quả `log_close` p = 0,8665 minh họa điều này.

## 10.6 Vì sao return phù hợp cho GARCH

Return là sai phân log-price. Sai phân thường loại stochastic trend khỏi level.
GARCH giả định mô hình hóa dynamics của variance quanh một mean equation, nên
return dừng phù hợp hơn price level không dừng.

---

# 11. Forecast và cách đánh giá đúng

## 11.1 Forecast không phải fit đẹp trên train

Mục tiêu là dự báo dữ liệu chưa thấy. Model phức tạp có thể fit train tốt nhưng
forecast kém vì overfitting.

## 11.2 Holdout 30 phiên

Dự án dùng 30 phiên cuối làm test. Tất cả model holdout dùng cùng train/test để
so sánh công bằng.

## 11.3 RMSE

```text
RMSE = sqrt(mean((actual - predicted)^2))
```

RMSE phạt lỗi lớn mạnh vì bình phương. ETS Damped có RMSE `1.939,13`, nghĩa là
độ lớn lỗi theo thước đo bình phương căn khoảng 1.939 đơn vị giá. Không được
diễn giải RMSE là “mỗi dự báo sai đúng 1.939”.

## 11.4 MAE

```text
MAE = mean(abs(actual - predicted))
```

MAE dễ hiểu hơn: độ lệch tuyệt đối trung bình. ETS Damped MAE là `1.524,15`.

## 11.5 MAPE

```text
MAPE = mean(abs((actual - predicted) / actual)) * 100
```

ETS Damped MAPE `2,10%` trên holdout. MAPE có vấn đề khi actual gần 0; giá FPT dương
nên dự án kiểm tra `actual > 0` trước khi tính.

## 11.6 Vì sao cần benchmark

Nếu model phức tạp không thắng dự báo “giá ngày mai bằng giá hôm nay”, độ phức
tạp chưa mang lại bằng chứng cải thiện. Naive là baseline bắt buộc.

## 11.7 Rolling-origin cross-validation

Một holdout có thể may mắn hoặc bất thường. Rolling-origin tạo nhiều lần đánh
giá theo thời gian:

```text
Fold 1: train [1 ... i],       test [i+1 ... i+20]
Fold 2: train [1 ... i+20],    test [i+21 ... i+40]
...
```

Dự án dùng:

- initial = 80% dữ liệu model;
- horizon = 20;
- step = 20;
- 27 folds;
- 5 model mỗi fold;
- tổng 135 dòng metric raw.

ARIMAX và SARIMA chưa nằm trong cùng rolling CV, vì vậy không được tuyên bố
ARIMAX là winner tuyệt đối.

## 11.8 Kết quả holdout

| Model | RMSE | MAE | MAPE |
|---|---:|---:|---:|
| ETS Damped | 1.939,13 | 1.524,15 | 2,10% |
| Naive | 1.939,85 | 1.525,33 | 2,11% |
| SARIMA | 1.983,50 | 1.581,50 | 2,19% |
| ETS | 1.986,72 | 1.519,23 | 2,08% |
| Drift | 2.020,67 | 1.609,29 | 2,23% |
| ARIMAX Lagged | 2.025,86 | 1.614,20 | 2,24% |
| ARIMA | 2.119,63 | 1.711,40 | 2,38% |

## 11.9 Kết quả rolling CV

| Model | Mean RMSE | Mean MAPE |
|---|---:|---:|
| Naive | 5.353,94 | 4,70% |
| Drift | 5.397,32 | 4,76% |
| ETS Damped | 5.404,76 | 4,74% |
| ETS | 5.476,87 | 4,81% |
| ARIMA | 6.501,43 | 5,57% |

Naive tốt nhất theo mean RMSE CV. ETS Damped chỉ hơn Naive khoảng 0,72 RMSE
trên holdout nhưng kém Naive trong CV. Đây là mixed evidence.

---

# 12. Các mô hình dự báo giá

## 12.1 Naive

```text
forecast(P_(t+h)) = P_t
```

Giả định tốt nhất cho tương lai là quan sát cuối. Với giá tài chính khó dự báo,
Naive thường là benchmark mạnh.

## 12.2 Drift

Random walk with drift kéo dài tốc độ thay đổi trung bình từ đầu đến cuối train.
Drift holdout RMSE `1.892,29`, đứng thứ hai.

Rủi ro: trend lịch sử có thể không tiếp tục.

## 12.3 ARIMA

ARIMA(p,d,q):

- AR(p): dùng lag của chuỗi;
- I(d): sai phân d lần;
- MA(q): dùng lag của shock/phần dư.

`auto.arima()` chọn cấu hình theo information criterion và kiểm tra nhiều order.
Trong final split dự án tắt stepwise/approximation để tìm kỹ hơn.

## 12.4 SARIMA

SARIMA thêm thành phần mùa vụ. Dự án thử frequency = 5 để biểu diễn chu kỳ tuần
giao dịch. Kết quả SARIMA giống ARIMA trên holdout, cho thấy specification được
chọn không tạo cải thiện trong lần chạy này.

Không được nói “cổ phiếu chắc chắn có mùa vụ 5 ngày” chỉ vì đã fit SARIMA.

## 12.5 ETS

ETS là Error-Trend-Seasonality state-space model. Nó cập nhật level/trend bằng
exponential smoothing, đặt trọng số lớn hơn cho quan sát gần.

## 12.6 ETS Damped

Damped trend làm trend tắt dần thay vì kéo dài vô hạn. Điều này hợp lý khi
không tin tốc độ tăng dài hạn tiếp tục mãi.

Trong dự án ETS Damped đứng đầu holdout rất sát Naive nhưng residual diagnostics chưa đạt.

## 12.7 ARIMAX Lagged

ARIMAX = ARIMA + biến giải thích ngoài:

```text
y_t = ARIMA dynamics + beta' x_t + error_t
```

Dự án tạo:

- `lag_volume`;
- `lag_daily_range`;
- `lag_return`.

Các biến đều trễ một phiên. ARIMAX thắng holdout nhưng chưa có rolling CV.

## 12.8 AIC và BIC cho forecast model

```text
AIC = -2 log(L) + 2k
BIC = -2 log(L) + k log(n)
```

Nhỏ hơn tốt hơn trong các model có cùng response/sample và likelihood có thể so
sánh. Không dùng AIC của ARIMA để so trực tiếp với RMSE hoặc AIC GARCH.

---

# 13. Residual diagnostics cho forecast

## 13.1 Residual là gì

```text
e_t = actual_t - fitted_t
```

Residual tốt không còn cấu trúc dự báo được rõ ràng. Nếu residual có tự tương
quan, model bỏ sót dynamics.

## 13.2 Ljung-Box

- H0: không có autocorrelation đến lag được kiểm tra.
- H1: có ít nhất một autocorrelation khác 0.

Kết quả:

| Model | p-value | Diễn giải mức 5% |
|---|---:|---|
| ARIMA | 0,00026 | bác bỏ H0 |
| SARIMA | 0,00151 | bác bỏ H0 |
| ETS | 0,00292 | bác bỏ H0 |
| ETS Damped | 0,00149 | bác bỏ H0 |
| ARIMAX | 0,00026 | bác bỏ H0 |

## 13.3 P-value nhỏ cho biết điều gì

Các p-value đều nhỏ hơn 0,05, cho thấy residual còn autocorrelation. Model chưa
khai thác hết mean dynamics dù có thể có holdout metric cạnh tranh.

## 13.4 Kết luận forecast trung thực

Không có winner tuyệt đối vì:

- ETS Damped chỉ hơn Naive rất nhỏ trên holdout;
- Naive thắng rolling CV;
- mọi fitted model còn residual autocorrelation;
- hiệu năng thay đổi theo cửa sổ đánh giá.

---

# 14. Volatility, ARCH và GARCH

## 14.1 Ba phương trình cốt lõi

```text
Mean equation:     r_t = mu_t + epsilon_t
Innovation:        epsilon_t = sigma_t * z_t
Variance equation: sigma_t^2 phụ thuộc thông tin đến t-1
```

Trong đó:

- `r_t`: log return quan sát được;
- `mu_t`: mean có điều kiện;
- `epsilon_t`: phần return ngoài dự kiến của mean equation;
- `sigma_t`: conditional volatility;
- `z_t`: standardized innovation, thường Normal hoặc standardized Student-t.

## 14.2 Epsilon không phải residual của giá

Dự án fit GARCH trên return. Vì vậy:

```text
epsilon_t = return thực tế - conditional mean của return
```

Nó không phải `giá thực tế - giá dự báo` của ARIMA.

Ví dụ nếu return hôm nay 2% và mean equation dự kiến 0,1%:

```text
epsilon_t = 0,020 - 0,001 = 0,019
```

## 14.3 Conditional volatility

`sigma_t` là độ lệch chuẩn dự kiến tại t dựa trên thông tin trước t. Nó thay đổi
theo thời gian, khác với một SD duy nhất cho toàn sample.

## 14.4 Standardized innovation

```text
z_t = epsilon_t / sigma_t
```

Nếu variance model đúng, z gần như không còn volatility clustering. Diagnostics
được chạy trên z và z² để kiểm tra điều này.

## 14.5 ARCH effect

ARCH nghĩa là variance hiện tại phụ thuộc squared shock quá khứ.

ARCH-LM:

- H0: không có ARCH effect đến lag kiểm tra;
- H1: có ARCH effect.

Pre-fit p-value của dự án khoảng `1,09e-38`, cực nhỏ. Ta bác bỏ H0 và có động
cơ mạnh để fit conditional variance model.

ARCH-LM significant không chứng minh GARCH(1,1) là model tốt nhất; nó chỉ cho
biết constant variance model bỏ sót cấu trúc.

## 14.6 sGARCH(1,1)

```text
sigma_t^2 = omega
            + alpha * epsilon_(t-1)^2
            + beta  * sigma_(t-1)^2
```

- `omega`: variance nền;
- `alpha`: phản ứng với shock mới;
- `beta`: ký ức của variance quá khứ;
- `alpha + beta`: persistence trong sGARCH.

Với sGARCH-Normal cuối:

```text
alpha = 0,07837
beta  = 0,88614
alpha + beta = 0,96451
```

Shock tiêu biến chậm nhưng tổng vẫn dưới 1.

## 14.7 Half-life

Với sGARCH, half-life gần đúng:

```text
half_life = log(0,5) / log(alpha + beta)
```

Persistence càng gần 1, thời gian để ảnh hưởng shock giảm một nửa càng dài.

## 14.8 Unconditional variance

Với sGARCH và `alpha + beta < 1`:

```text
Var(epsilon) = omega / (1 - alpha - beta)
```

Nếu tổng >= 1, unconditional variance không hữu hạn theo công thức chuẩn.

## 14.9 Normal và Student-t

Normal có đuôi mỏng hơn. Student-t có tham số `shape` và đuôi dày hơn, phù hợp
hơn khi return có nhiều quan sát cực đoan.

Shape eGARCH khoảng `3,596`, cho thấy đuôi khá dày so với Normal.

---

# 15. Bốn specification GARCH của dự án

## 15.1 sGARCH-Normal

Baseline đối xứng, Normal innovations.

Kết quả:

- AIC: -5,5073;
- persistence: 0,9645;
- core residual diagnostics đạt;
- Nyblom không đạt;
- Pearson GOF không đạt.

## 15.2 sGARCH-Student-t

Cùng variance equation nhưng Student-t innovations.

- AIC: -5,6317, cải thiện rõ so với Normal;
- persistence: 0,9891;
- shape: 3,6499;
- stability không đạt.

Điều này cho thấy distribution choice có ảnh hưởng lớn đến fit.

## 15.3 eGARCH-Student-t

eGARCH mô hình hóa log variance. Dạng khái niệm:

```text
log(sigma_t^2) = omega
                 + beta log(sigma_(t-1)^2)
                 + terms from standardized shock
```

Ưu điểm:

- variance luôn dương vì dùng log variance;
- cho phép phản ứng bất đối xứng;
- không cần ràng buộc alpha/beta giống sGARCH.

Kết quả:

- AIC: -5,6331;
- beta/persistence báo cáo: 0,96267;
- gamma1: 0,24024, robust p-value gần 0;
- Nyblom: 1,5048 < critical 1,68;
- core diagnostics đạt;
- Pearson GOF không đạt.

Không diễn giải `alpha + beta` của eGARCH như sGARCH.

## 15.4 GJR-GARCH-Student-t

GJR thêm indicator cho shock âm:

```text
sigma_t^2 = omega
            + alpha epsilon_(t-1)^2
            + gamma I(epsilon_(t-1) < 0) epsilon_(t-1)^2
            + beta sigma_(t-1)^2
```

- shock dương tác động khoảng `alpha`;
- shock âm tác động khoảng `alpha + gamma`.

Kết quả:

- alpha1: 0,08451;
- gamma1: 0,08363, robust p-value 0,0050;
- beta1: 0,85942;
- AIC thấp nhất: -5,6344;
- Nyblom 27,3478 > 1,68, stability thất bại rất mạnh.

## 15.5 Vì sao không chọn model chỉ bằng AIC

GJR thắng AIC nhưng tham số không ổn định theo Nyblom. eGARCH chỉ kém AIC:

```text
delta AIC = 0,00137
```

chênh lệch cực nhỏ, trong khi eGARCH đạt stability. Vì vậy eGARCH là lựa chọn
cân bằng hơn theo rule của dự án.

---

# 16. Diagnostics và lựa chọn GARCH

## 16.1 Convergence

`convergence = 0` nghĩa optimizer báo hội tụ. Cả 4/4 model hội tụ. Hội tụ là
điều kiện cần, không phải đủ để model đúng.

## 16.2 Ljung-Box trên standardized residual

Kiểm tra mean dynamics còn sót. Cả bốn p-value từ 0,817 đến 0,877, nên chưa bác
bỏ H0 không autocorrelation.

## 16.3 Ljung-Box trên squared standardized residual

Kiểm tra dependence trong variance còn sót. P-value từ 0,632 đến 0,881, đều
trên 0,05.

## 16.4 ARCH-LM sau fit

P-value từ 0,366 đến 0,810. So với pre-fit `1,09e-38`, GARCH đã hấp thụ phần lớn
ARCH structure theo kiểm định này.

## 16.5 Sign-bias test

H0: không còn phản ứng sai lệch theo dấu shock. Joint p-value:

- sGARCH-Normal: 0,1029;
- sGARCH-Student-t: 0,0601;
- eGARCH-Student-t: 0,1017;
- GJR-GARCH-Student-t: 0,0864.

Tất cả trên 0,05 nhưng Student-t sGARCH và GJR khá gần biên. Không nói “chắc
chắn không có asymmetry”; chỉ nói chưa bác bỏ H0 ở mức 5%.

## 16.6 Nyblom stability

So sánh joint statistic với critical value 5%:

| Model | Statistic | Critical | Đạt? |
|---|---:|---:|---|
| sGARCH-Normal | 12,8991 | 1,24 | Không |
| sGARCH-Student-t | 11,8898 | 1,47 | Không |
| eGARCH-Student-t | 1,5048 | 1,68 | Có |
| GJR-GARCH-Student-t | 27,3478 | 1,68 | Không |

Stability thất bại gợi ý tham số thay đổi trong sample dài, có thể do structural
break hoặc regime khác nhau.

## 16.7 Adjusted Pearson GOF

H0 liên quan distribution fit theo các nhóm phân vị. Tất cả p-value cực nhỏ,
nên distribution giả định vẫn chưa mô tả hoàn hảo standardized innovations.

Đây là hạn chế quan trọng nhất còn lại của candidate eGARCH.

## 16.8 Rule chọn candidate trong code

Model đủ điều kiện nếu:

```text
convergence == 0
Ljung-Box residual p >= 0,05
Ljung-Box squared p >= 0,05
ARCH-LM p >= 0,05
Nyblom joint <= critical 5%
```

Trong các model đủ điều kiện, chọn AIC nhỏ nhất. Chỉ eGARCH qua core diagnostics
và stability, nên được gắn `provisional_candidate = TRUE`. Tên cột là di sản
code; báo cáo gọi nó là “ứng viên cân bằng”.

---

# 17. Đọc code theo từng file

## 17.1 `R/00_config.R`

### Mục đích

Định nghĩa đường dẫn dùng chung và tạo thư mục output:

```r
RAW_DATA_PATH <- "data/raw/FPT_stock_data.csv"
CLEAN_DATA_PATH <- "data/processed/fpt_clean.csv"
FIGURE_DIR <- "output/figures"
TABLE_DIR <- "output/tables"
```

### Vì sao cần config

Nếu mỗi script tự ghi đường dẫn, đổi cấu trúc thư mục sẽ phải sửa nhiều nơi.
Config tạo một nguồn sự thật cho đường dẫn.

### Điều cần nhớ khi bảo vệ

`source("R/00_config.R")` không chạy model; nó chuẩn bị dependency nội bộ và
đường dẫn.

## 17.2 `R/01_data_cleaning.R`

### Input

`data/raw/FPT_stock_data.csv`.

### Các bước

1. Kiểm tra file tồn tại.
2. Chuẩn hóa tên cột thành chữ thường.
3. Kiểm tra schema.
4. Chuyển kiểu Date/numeric.
5. Tạo quality report.
6. Dừng nếu có lỗi nghiêm trọng.
7. Loại volume bằng 0.
8. Sửa OHLC vượt tolerance.
9. Tạo `log_close` và `return`.
10. Chạy assertions cuối.
11. Ghi processed CSV.

### Output

- `data/processed/fpt_clean.csv`;
- `output/tables/data_quality_report.csv`.

### Câu hỏi có thể bị hỏi

**Tại sao loại volume 0 thay vì thay bằng NA?**  
Vì các hàng này không đại diện phiên giao dịch hữu ích cho chuỗi return. Nhóm
chọn loại cả quan sát để tránh tạo khoảng thời gian giả có giá nhưng không có
giao dịch. Quy tắc được ghi rõ và áp dụng tái lập.

**Tại sao sửa high mà không xóa dòng?**  
Chỉ một quan hệ OHLC sai thực sự được chuẩn hóa bằng envelope của open/high/
close. Đây là lựa chọn bảo toàn quan sát; quality report ghi lại. Một phương án
khác hợp lệ là loại dòng và làm sensitivity analysis.

## 17.3 `R/02_visualization.R`

### Input

`fpt_clean.csv`.

### Xử lý

- tạo weekday;
- tạo missing report;
- tạo descriptive summary;
- thiết lập theme chung;
- xuất 9 biểu đồ 300 DPI hoặc PNG độ phân giải cao.

### Output bảng

- `missing_values.csv`;
- `data_summary.csv`.

### Output hình

1. `close_price.png`;
2. `volume.png`;
3. `returns.png`;
4. `return_distribution.png`;
5. `qqplot_return.png`;
6. `squared_returns.png`;
7. `acf_return.png`;
8. `pacf_return.png`.

### Cách đọc code ggplot

```r
ggplot(df, aes(date, close)) +
  geom_line() +
  labs(x = "Năm", y = "Giá")
```

- `ggplot`: khai báo data và mapping;
- `aes`: ánh xạ cột vào trục;
- `geom_line`: hình học đường;
- `labs`: nhãn.

## 17.4 `R/03_stationarity_arima_ets.R`

### Input

`fpt_clean.csv`.

### Nhóm hàm

- `forecast_metrics()`: RMSE/MAE/MAPE;
- `adf_row()`: biến một ADF test thành hàng tidy;
- `fit_final_models()`: fit bảy model trên final split;
- `score_forecasts()`: chấm một named list forecast;
- `save_forecast_plot()`: hình forecast vs actual;
- `diagnose_model()`: Ljung-Box và residual figure;
- `score_cv_fold()` và `run_rolling_cv()`: rolling CV cho năm model.

### Feature engineering ARIMAX

```r
daily_range = high - low
lag_volume = lag(volume, 1)
lag_daily_range = lag(daily_range, 1)
lag_return = lag(return, 1)
```

Sau khi tạo lag, các hàng đầu có NA bị loại khỏi `model_data`.

### Final split

```r
HOLDOUT_SIZE <- 30
train_end <- nrow(model_data) - HOLDOUT_SIZE
```

Đây là chronological split, không shuffle.

### Rolling CV

```r
initial <- floor(0.80 * nrow(model_data))
CV_HORIZON <- 20
CV_STEP <- 20
```

CV dùng `stepwise = TRUE, approximation = TRUE` cho ARIMA để giảm thời gian qua
nhiều fold; final model dùng tìm kiếm kỹ hơn. Đây là trade-off tính toán.

### Output chính

- `forecast_metrics.csv`;
- `forecast_cv_metrics_raw.csv`;
- `forecast_cv_metrics_summary.csv`;
- `forecast_diagnostics.csv`;
- `ets_damped_forecast.png`;
- `ets_damped_residual_diagnostics.png`.

### Vì sao không lưu toàn bộ forecast figure nhưng vẫn lưu RDS

Dự án đã được tinh giản để chỉ giữ artifact phục vụ báo cáo. Các forecast khác
vẫn được fit và chấm điểm trong CSV, nhưng không xuất hình riêng vì báo cáo chỉ
trình bày ETS Damped như ví dụ minh họa. Tuy vậy, model RDS vẫn được lưu trong
`output/models/` để người khác có thể load thử fitted model mà không cần chạy lại
toàn bộ pipeline. Mọi kết luận chính vẫn phải dựa trên CSV/PNG tái lập từ code.

## 17.5 `R/04_garch_volatility.R`

### Input

2.786 giá trị `return` không NA.

### Trình tự logic

1. Validate sample và return scale.
2. Chạy pre-fit ARCH-LM.
3. Khai báo bốn specification.
4. Fit từng model bằng `rugarch`.
5. Bắt convergence/error.
6. Trích log likelihood, AIC, BIC và persistence.
7. Trích standard và robust standard errors.
8. Chạy residual diagnostics.
9. Chạy sign-bias, Nyblom và Pearson GOF.
10. Xuất bảng, fitted object và hình.

### Tại sao robust standard error

Standard error thông thường phụ thuộc mạnh vào distribution specification.
Robust SE giảm độ nhạy khi likelihood không mô tả hoàn hảo dữ liệu. Ví dụ
`alpha1` của eGARCH có standard p-value 0,0366 nhưng robust p-value 0,1699;
điều này nhắc ta không nên diễn giải alpha quá mạnh.

### Output chính

- `garch_comparison.csv`;
- `garch_parameters.csv`;
- `garch_diagnostics.csv`;
- `garch_diagnostic_summary.csv`;
- `garch_fits.rds`;
- `garch_model.rds`;
- `garch_candidate_model.rds`;
- 3 hình GARCH dùng trong báo cáo: `garch_model_comparison.png`,
  `garch_acf_diagnostics.png`, `garch_news_impact.png`.

## 17.6 `R/05_model_comparison.R`

### Mục tiêu

Ghép metric và diagnostics thành bằng chứng tổng hợp, nhưng vẫn tách price và
volatility.

### Forecast rule

So với Naive trên holdout và CV, cộng residual diagnostic. Kết quả được gắn:

- benchmark;
- holdout only;
- consistent improvement;
- mixed evidence.

### GARCH rule

Tạo các cột boolean:

- `core_diagnostics_pass`;
- `sign_bias_pass`;
- `parameter_stability_pass`;
- `distribution_fit_pass`;
- `persistence_warning`.

### Điều quan trọng

Code không xếp price model và volatility model trong cùng thang điểm.

## 17.7 `R/06_export_report_tables.R`

Đọc các CSV đã có, tạo workbook nhiều sheet với `openxlsx`, định dạng header và
ghi `output/tables/report_tables.xlsx`.

Workbook là artifact tiện xem; nguồn sự thật vẫn là CSV và code tạo CSV.

## 17.8 `R/run_all.R`

Entry point:

1. Kiểm tra đang ở project root.
2. Kiểm tra package.
3. Mở pipeline log.
4. Chạy script 01 đến 06 theo thứ tự.
5. Tìm Pandoc.
6. Render `report/report.docx` và `presentation/khung_noi_dung_slide.docx`.

Nếu một script lỗi, pipeline dừng. Không nên tiếp tục dùng output cũ như thể lần
chạy mới thành công.

## 17.9 `report/report.Rmd`

Rmd đọc output thay vì tính lại model. Cách này tách:

- computation layer: các script đánh số từ 01 đến 06 trong thư mục `R/`;
- presentation layer: `report.Rmd`.

Các hàm `read_required_csv()` và `include_required_figure()` dừng render nếu
thiếu artifact bắt buộc.

---

# 18. Đọc toàn bộ output

## 18.1 `output/tables`

| File | Nội dung | Người dùng chính |
|---|---|---|
| `data_quality_report.csv` | kiểm tra dữ liệu raw/clean | Người 1 |
| `missing_values.csv` | NA theo biến | Người 1 |
| `data_summary.csv` | thống kê close, volume, return | Cả nhóm |
| `stationarity_tests.csv` | ADF | Người 2 |
| `forecast_metrics.csv` | final holdout metrics | Người 2 |
| `forecast_cv_metrics_raw.csv` | metric từng fold | Người 2 |
| `forecast_cv_metrics_summary.csv` | mean/median CV | Người 2 |
| `forecast_diagnostics.csv` | Ljung-Box forecast residual | Người 2 |
| `garch_comparison.csv` | fit và persistence | Người 3 |
| `garch_parameters.csv` | coefficient và robust SE | Người 3 |
| `garch_diagnostic_summary.csv` | diagnostics tóm tắt | Người 3 |
| `volatility_model_comparison.csv` | rule chọn GARCH | Người 3 |
| `price_forecast_comparison.csv` | bằng chứng forecast tổng hợp | Cả nhóm |
| `model_comparison.csv` | overview hai bài toán | Báo cáo |
| `report_tables.xlsx` | workbook tiện đọc | Cả nhóm |

## 18.2 `output/figures`

EDA figures giải thích dữ liệu; forecast chỉ giữ hình ETS Damped được đưa vào
báo cáo; GARCH chỉ giữ ba hình phục vụ phần volatility và asymmetry.

Không dùng hình mà không biết file nguồn và thông điệp của nó.

## 18.3 `output/models`

Thư mục này lưu fitted R objects để kiểm thử nhanh:

- `arima_model.rds`;
- `sarima_model.rds`;
- `ets_model.rds`;
- `ets_damped_model.rds`;
- `arima_xreg_model.rds`;
- `garch_fits.rds`;
- `garch_model.rds`;
- `garch_candidate_model.rds`.

Ví dụ:

```r
model <- readRDS("output/models/ets_damped_model.rds")
forecast::forecast(model, h = 10)
```

RDS giúp demo nhanh, nhưng không thay thế pipeline tái lập. Khi dữ liệu hoặc code
đổi, nên chạy lại `R/run_all.R` để sinh lại model.

## 18.4 `output/pipeline_log.txt`

Log cho biết script nào đã chạy và thời gian bắt đầu/kết thúc. Log trống thường
có nghĩa entry point chưa được chạy hoặc output bị redirect sai. Log hiện tại
đã ghi đầy đủ lần chạy thành công.

---

# 19. Cách chạy dự án từ đầu

## 19.1 Yêu cầu

- Windows 11 hoặc hệ điều hành tương đương;
- R 4.6.0 trong môi trường nhóm;
- RStudio có Pandoc;
- các package trong `R/run_all.R`.

## 19.2 Mở đúng project

Mở `FPT_Stock_TimeSeries.Rproj` hoặc đặt working directory tại project root.

Kiểm tra:

```r
getwd()
file.exists("FPT_Stock_TimeSeries.Rproj")
```

Kết quả thứ hai phải là `TRUE`.

## 19.3 Cài package một lần

```r
install.packages(c(
  "tidyverse", "lubridate", "forecast", "tseries", "FinTS",
  "rugarch", "scales", "openxlsx", "knitr", "rmarkdown"
))
```

Không đặt `install.packages()` trong logic phân tích thường xuyên vì nó cần
network và làm lần chạy khó kiểm soát.

## 19.4 Chạy toàn bộ

Trong RStudio:

```r
source("R/run_all.R")
```

Trong PowerShell:

```powershell
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" -e "source('R/run_all.R')"
```

## 19.5 Chạy từng phần

```r
source("R/01_data_cleaning.R")
source("R/02_visualization.R")
source("R/03_stationarity_arima_ets.R")
source("R/04_garch_volatility.R")
source("R/05_model_comparison.R")
source("R/06_export_report_tables.R")
```

Phải giữ đúng thứ tự vì script sau dùng output script trước.

## 19.6 Render báo cáo

```r
rmarkdown::render(
  "report/report.Rmd",
  output_file = "report.docx",
  knit_root_dir = normalizePath(".")
)
```

## 19.7 Kiểm tra sau chạy

```r
d <- readr::read_csv("data/processed/fpt_clean.csv", show_col_types = FALSE)
stopifnot(
  nrow(d) == 2787,
  sum(!is.na(d$return)) == 2786,
  anyDuplicated(d$date) == 0,
  all(d$volume > 0)
)
```

Sau đó mở:

- `output/pipeline_log.txt`;
- `report/report.docx`;
- các bảng comparison;
- hình chính.

---

# 20. Kiến thức riêng cho Người 1

**Thành viên:** Trần Thiên Lực - 24133037 - 30%.

## 20.1 Phạm vi phải nắm

- nguồn Yahoo Finance và ticker `FPT.VN`;
- ý nghĩa OHLCV;
- `auto_adjust = TRUE`;
- raw vs processed;
- schema và kiểu dữ liệu;
- zero volume;
- OHLC tolerance;
- log return;
- missing values và descriptive statistics;
- cách đọc 9 biểu đồ EDA.

## 20.2 Bài nói mẫu 90 giây

“Dữ liệu được lấy từ Yahoo Finance với ticker FPT.VN bằng notebook tái lập và
tùy chọn auto-adjust. Tệp thô có 2.960 quan sát OHLCV. Tôi kiểm tra schema,
ngày lỗi, ngày trùng, missing, giá không dương, volume âm và quan hệ OHLC. Có
173 hàng volume bằng 0 nên nhóm loại khỏi chuỗi phân tích. Kiểm tra OHLC dùng
tolerance 1e-8 để không nhầm sai số floating-point với lỗi thật; sau đó chỉ có
một hàng cần chuẩn hóa. Tệp sạch còn 2.787 dòng và tạo 2.786 log returns. EDA
cho thấy giá có trend, return có heavy tails và volatility clustering, tạo động
cơ cho kiểm định ADF, ARCH và các mô hình ở phần sau.”

## 20.3 Phải giải thích được từng biểu đồ

### Giá

Nói trend và non-stationarity là giả thuyết cần kiểm định. Không dự báo tương lai
chỉ bằng mắt.

### Volume

Nói mean lớn hơn median do distribution lệch/outlier. Không tự gán nguyên nhân
kinh tế nếu chưa có nguồn sự kiện.

### Return distribution và QQ

Nói empirical tails lệch Normal, là động cơ thử Student-t.

### Squared return

Nói spike theo cụm gợi ý conditional heteroskedasticity.

### ACF/PACF

Nói chúng đo dependence theo lag, không phải quan hệ nhân quả.

## 20.4 Câu hỏi riêng và trả lời

**Vì sao dòng return đầu là NA?**  
Vì return cần giá phiên trước, nhưng quan sát đầu sample không có lag.

**Tại sao không điền return đầu bằng 0?**  
0 là một quan sát kinh tế có nghĩa “không đổi”, trong khi ở đây giá trị không
xác định. Điền 0 sẽ bịa dữ liệu.

**Tại sao dùng tolerance?**  
Để phân biệt sai số biểu diễn số thực rất nhỏ với vi phạm OHLC có ý nghĩa.

**Có thể nói volume 0 chắc chắn là ngày nghỉ không?**  
Không nếu chưa đối chiếu lịch giao dịch. Nhóm chỉ nói chúng không đại diện phiên
có volume dương và áp dụng quy tắc loại nhất quán.

**Mean return 0,0837% có nghĩa ngày mai tăng 0,0837%?**  
Không. Đó là trung bình lịch sử của sample, không phải forecast chắc chắn.

## 20.5 Thực hành trước bảo vệ

1. Mở raw và clean, đọc 10 dòng đầu.
2. Tự tính `2960 - 173`.
3. Tự tính return cho hai close liên tiếp bằng máy tính.
4. Mở 9 hình và nói mỗi hình trong 20 giây.
5. Mở quality report và giải thích từng check.

---

# 21. Kiến thức riêng cho Người 2

**Thành viên:** Nguyễn Đức Học - 24162039 - 35%.

## 21.1 Phạm vi phải nắm

- stationarity, unit root, ADF;
- lag, differencing, AR, MA;
- Naive và Drift;
- ARIMA/SARIMA;
- ETS/ETS Damped;
- ARIMAX và leakage;
- chronological split;
- RMSE, MAE, MAPE;
- rolling-origin CV;
- residual và Ljung-Box;
- vì sao không có winner tuyệt đối.

## 21.2 Bài nói mẫu 2 phút

“ADF có H0 là chuỗi có unit root. Với close và log-close, p-value lần lượt là
0,6676 và 0,8665 nên nhóm chưa bác bỏ H0; return có p-value không quá 0,01 nên
bác bỏ H0. Bài toán forecast dùng 30 phiên cuối làm holdout và không shuffle.
Nhóm so sánh Naive, Drift, ARIMA, SARIMA, ETS, ETS Damped và ARIMAX Lagged bằng
RMSE, MAE và MAPE. ETS Damped đứng đầu holdout với RMSE 1.939,13 nhưng chỉ hơn
Naive khoảng 0,72. Trong năm model có rolling CV, Naive có mean RMSE thấp nhất
5.353,94. Ljung-Box cũng bác bỏ white-noise residual ở mọi fitted model. Vì vậy
nhóm chưa có bằng chứng model phức tạp cải thiện Naive một cách ổn định.”

## 21.3 Phân biệt các model trong một câu

- Naive: giữ nguyên giá cuối.
- Drift: kéo dài độ trôi trung bình.
- ARIMA: lag, sai phân và lag shock.
- SARIMA: thêm cấu trúc chu kỳ.
- ETS: cập nhật state bằng exponential smoothing.
- ETS Damped: trend tắt dần.
- ARIMAX: ARIMA cộng biến giải thích có sẵn.

## 21.4 Câu hỏi riêng và trả lời

**ADF p-value lớn có nghĩa chuỗi chắc chắn không dừng?**  
Không. Chỉ là chưa đủ bằng chứng bác bỏ unit root với test/specification này.

**Tại sao log-close vẫn không dừng?**  
Log đổi scale nhưng không nhất thiết loại stochastic trend.

**Tại sao không shuffle?**  
Shuffle cho model học tương lai để dự báo quá khứ và phá cấu trúc thời gian.

**Vì sao chưa chọn chắc chắn ETS Damped dù RMSE thấp nhất?**  
Nó chỉ hơn Naive khoảng 0,72 RMSE trên một holdout, thua Naive trong rolling CV
và residual còn autocorrelation.

**Tại sao AIC và RMSE có thể cho thứ hạng khác nhau?**  
AIC đánh giá likelihood in-sample có penalty; RMSE đo forecast holdout. Mục tiêu
khác nhau nên thứ hạng có thể khác.

**Naive thắng CV có nghĩa các model khác vô dụng?**  
Không, nhưng hiện chưa có bằng chứng chúng cải thiện benchmark ổn định; cần cải
thiện specification và đánh giá lại trên cùng folds.

**ARIMAX có leakage không?**  
Code dùng lagged features nên tránh dùng contemporaneous values. Tuy nhiên phải
đảm bảo các xreg test thực sự có sẵn khi dự báo triển khai.

## 21.5 Bài tập tự kiểm tra

1. Tính RMSE cho actual `(100, 102)` và forecast `(99, 104)`.
2. Giải thích một rolling fold bằng cách vẽ timeline.
3. Đọc `forecast_metrics.csv` không nhìn README.
4. Đọc `forecast_diagnostics.csv` và phân loại pass/fail mức 5%.
5. Nói kết luận forecast trong 30 giây mà không dùng từ “chính xác tuyệt đối”.

---

# 22. Kiến thức riêng cho Người 3

**Thành viên:** Lê Đặng Hoàng Anh - 24162006 - 35%.

## 22.1 Phạm vi phải nắm

- return, innovation và conditional volatility;
- volatility clustering;
- ARCH-LM;
- sGARCH equation;
- alpha, beta, persistence, half-life;
- Normal vs Student-t;
- eGARCH và GJR asymmetry;
- standardized residual;
- convergence;
- Ljung-Box, ARCH-LM sau fit;
- sign bias;
- Nyblom;
- Pearson GOF;
- AIC/BIC và model selection rule;
- giới hạn của candidate eGARCH.

## 22.2 Bài nói mẫu 2 phút

“GARCH được fit trên 2.786 log returns, không fit trên close. ARCH-LM trước fit
có p-value khoảng 1,09 nhân 10 mũ -38, bác bỏ H0 không có ARCH effect. Nhóm fit
bốn specification trên cùng sample và mean equation ARMA(0,0); cả bốn hội tụ.
Student-t cải thiện AIC rõ so với sGARCH-Normal, phù hợp với heavy tails trong
EDA. GJR có AIC thấp nhất -5,6344 nhưng Nyblom joint 27,35 vượt critical 1,68,
cho thấy parameter instability. eGARCH có AIC -5,6331, chỉ kém 0,00137, đồng
thời core residual diagnostics và Nyblom stability đều đạt. Vì vậy nhóm chọn
eGARCH-Student-t là ứng viên cân bằng. Tuy nhiên Pearson GOF vẫn bị bác bỏ, nên
đây không phải model hoàn hảo và dự án chưa có volatility backtest ngoài mẫu.”

## 22.3 Phân biệt epsilon, sigma và z

- epsilon: shock return ngoài mean dự kiến;
- sigma: độ lệch chuẩn có điều kiện của shock;
- z: epsilon đã chuẩn hóa bằng sigma.

Không gọi epsilon là residual giá ARIMA.

## 22.4 Câu hỏi riêng và trả lời

**ARCH-LM significant có chứng minh GARCH tốt nhất?**  
Không. Nó cho thấy variance dynamics tồn tại, chỉ hỗ trợ thử họ ARCH/GARCH.

**Alpha và beta là gì?**  
Trong sGARCH, alpha là phản ứng với squared shock mới, beta là memory của
conditional variance quá khứ.

**Persistence 0,989 nghĩa gì?**  
Shock volatility tiêu biến rất chậm. Không có nghĩa giá tăng 98,9%.

**Tại sao Student-t tốt hơn Normal?**  
Return có heavy tails; Student-t gán xác suất cao hơn cho extreme standardized
innovations. AIC cải thiện rõ, nhưng GOF vẫn chưa đạt hoàn toàn.

**Tại sao không chọn GJR?**  
AIC tốt nhất nhưng parameter stability thất bại rất mạnh; eGARCH có fit gần như
ngang và diagnostics/stability cân bằng hơn.

**Gamma dương trong GJR nghĩa gì?**  
Shock âm có thêm tác động lên variance so với shock dương cùng độ lớn, theo
parameterization của model.

**Có được dùng alpha + beta cho eGARCH?**  
Không. eGARCH mô hình hóa log variance và có parameterization khác.

**GOF fail có làm mọi kết quả vô dụng?**  
Không, nhưng cho thấy distribution specification chưa hoàn hảo; phải nêu hạn
chế và tránh tuyên bố model mô tả đầy đủ tail risk.

## 22.5 Thực hành trước bảo vệ

1. Viết sGARCH equation không nhìn tài liệu.
2. Tính alpha + beta của sGARCH-Normal.
3. So sánh AIC GJR/eGARCH và tính delta.
4. Đọc từng p-value trong diagnostic summary.
5. Giải thích lý do chọn eGARCH trong 45 giây.

---

# 23. Kịch bản báo cáo chung

## 23.1 Phân bổ thời gian 10-12 phút

| Thời gian | Nội dung | Người nói |
|---:|---|---|
| 0:00-0:30 | giới thiệu nhóm và bài toán | Người 3 |
| 0:30-2:30 | nguồn, cleaning, quality, EDA | Người 1 |
| 2:30-5:30 | ADF, forecast design và kết quả | Người 2 |
| 5:30-8:30 | ARCH/GARCH, diagnostics, lựa chọn | Người 3 |
| 8:30-10:00 | kết luận và hạn chế | Người 3, cả nhóm |
| 10:00-12:00 | buffer hoặc minh họa thêm | tùy tình huống |

## 23.2 Câu chuyển Người 1 sang Người 2

“EDA cho thấy mức giá có trend và return có đặc điểm khác mức giá. Vì vậy phần
tiếp theo kiểm định tính dừng trước khi chọn chuỗi và mô hình phù hợp.”

## 23.3 Câu chuyển Người 2 sang Người 3

“Forecast model tập trung vào conditional mean của giá. Tuy nhiên squared
returns cho thấy độ bất định cũng thay đổi theo thời gian, nên nhóm tách riêng
bài toán conditional variance bằng GARCH.”

## 23.4 Câu kết luận an toàn

“Kết quả cho thấy không có forecast model thắng nhất quán trên mọi phương pháp
đánh giá. Với volatility, eGARCH-Student-t cân bằng tốt nhất giữa fit, residual
diagnostics và stability, nhưng distribution GOF vẫn là hạn chế. Các kết quả
phục vụ học thuật và không phải khuyến nghị đầu tư.”

## 23.5 Từ nên tránh

- “chứng minh tuyệt đối”;
- “dự báo chắc chắn”;
- “model hoàn hảo”;
- “p-value bằng 0” khi chỉ là underflow/printed 0;
- “GARCH dự báo giá”;
- “AIC âm sâu nghĩa là chính xác”.

---

# 24. Ngân hàng câu hỏi phản biện

## 24.1 Câu hỏi chung

### Tại sao chọn FPT?

FPT có lịch sử dữ liệu dài, thanh khoản và biến động đủ để minh họa cả forecast
mean lẫn conditional volatility. Đây là lý do thực hành, không hàm ý FPT tốt
hơn cổ phiếu khác.

### Vì sao chọn giai đoạn 2015-2026?

Khoảng dài tạo sample đủ lớn và chứa nhiều chế độ thị trường. Đổi lại, structural
instability trở thành rủi ro, thể hiện trong Nyblom của nhiều model.

### Dữ liệu sau ngày hiện tại có vấn đề không?

Thời điểm dự án và nguồn dữ liệu được chốt đến 2026-06-08. Khi tái lập ở thời
điểm khác cần giữ fixed end date để so sánh đúng cùng sample.

### Vì sao không thêm tin tức hoặc VN-Index?

Phạm vi môn tập trung R và univariate time series. Biến ngoài là hướng mở rộng,
nhưng cần nguồn tái lập và kiểm soát leakage.

## 24.2 Câu hỏi về thống kê

### Mức ý nghĩa 5% là gì?

Đó là ngưỡng quy ước cho xác suất Type I error trong điều kiện H0 và giả định
kiểm định. Nó không phải xác suất H0 đúng.

### Multiple testing có phải vấn đề không?

Có thể có khi chạy nhiều kiểm định. Dự án dùng diagnostics như một bộ bằng
chứng, không coi một p-value là chân lý. Nghiên cứu sâu hơn có thể điều chỉnh
multiple comparisons hoặc dùng validation độc lập.

### Correlation có phải causation không?

Không. ACF, lag relation hoặc weekday plot không chứng minh nhân quả.

## 24.3 Câu hỏi về forecast

### Vì sao test chỉ 30 phiên?

Nó mô phỏng horizon ngắn và giữ train lớn, nhưng là hạn chế. Rolling CV được
thêm để giảm phụ thuộc vào một cửa sổ.

### Vì sao CV RMSE lớn hơn holdout RMSE?

Các fold đi qua nhiều giai đoạn có mức giá và volatility khác nhau. Holdout cuối
có thể dễ hơn; RMSE đơn vị giá cũng tăng khi level giá cao.

### Có nên forecast return thay vì price?

Có thể, nhưng là bài toán khác. Dự án forecast price theo yêu cầu và dùng return
cho volatility. Forecast return thường khó và cần thiết kế đánh giá riêng.

## 24.4 Câu hỏi về GARCH

### Vì sao mean equation ARMA(0,0)?

Return ACF nhỏ và mục tiêu tập trung variance. Giữ cùng mean equation giúp so
sánh variance specifications công bằng. Có thể thử ARMA khác trong sensitivity
analysis.

### Tại sao persistence eGARCH trong bảng bằng beta?

Với implementation này, measure persistence được trích theo specification;
không dùng alpha + beta của sGARCH cho eGARCH.

### Volatility cao có nghĩa return âm không?

Không. Volatility đo độ lớn bất định; cả return dương và âm lớn đều có thể làm
volatility tăng.

### GARCH có dự báo được khủng hoảng không?

GARCH phản ứng và forecast variance dựa trên dynamics lịch sử; nó không biết
trước sự kiện hoàn toàn mới. Không nên gọi nó là công cụ dự đoán khủng hoảng.

## 24.5 Câu hỏi về code và tái lập

### Nếu xóa output rồi chạy lại có tạo được không?

Có, nếu raw data, package và Pandoc sẵn sàng. `R/run_all.R` chạy module 01-06 và
render Word.

### Tại sao dùng CSV thay vì Excel làm nguồn model?

CSV đơn giản, diff được, ít phụ thuộc formatting. Excel là output tiện đọc.

### Làm sao biết model không dùng data cũ?

Chạy entry point sau data handoff, kiểm tra log/timestamp, row count và cùng hash
data. Output được tái sinh trong một pipeline.

---

# 25. Lỗi thường gặp và xử lý

## 25.1 `Rscript is not recognized`

Nguyên nhân: R không nằm trong PATH.

Giải pháp PowerShell:

```powershell
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" -e "source('R/run_all.R')"
```

## 25.2 Không tìm thấy file raw

Kiểm tra:

```r
getwd()
file.exists("data/raw/FPT_stock_data.csv")
```

Phải chạy từ project root và đúng tên chữ hoa/thường theo repo.

## 25.3 Thiếu package

Đọc danh sách trong error, cài package một lần rồi restart R session.

## 25.4 Không tìm thấy Pandoc

Mở dự án bằng RStudio hoặc đặt:

```r
Sys.setenv(
  RSTUDIO_PANDOC =
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
)
```

## 25.5 Pipeline log trống

`R/run_all.R` lưu các mốc bắt đầu, sáu script, hai lần render và thời điểm hoàn
thành bằng `writeLines()`. Nếu log trống, có thể đang chạy từng module riêng thay
vì entry point, pipeline dừng trước bước ghi cuối, hoặc đang xem nhầm project.
Chạy lại `source("R/run_all.R")` rồi kiểm tra dòng `Pipeline completed`.

## 25.6 GARCH không hội tụ

Không ép kết quả. Cần:

- kiểm tra return có NA/Inf;
- kiểm tra scale nhất quán;
- thử solver hợp lệ;
- xem parameter bounds;
- báo model failed trong comparison.

## 25.7 Trộn return scale

Nếu một model dùng return dạng `0,01` và model khác dùng `1`, scale khác 100 lần.
AIC/parameter không còn so sánh công bằng. Dự án giữ return decimal cho cả bốn.

## 25.8 Fit GARCH trên close

Sai vì close non-stationary và GARCH variance equation được thiết kế cho shock
quanh mean equation. Dự án dùng return.

## 25.9 Dùng simple return lẫn log return

Phải đặt tên rõ và dùng một định nghĩa. Dự án dùng:

```text
log(close_t) - log(close_(t-1))
```

## 25.10 AIC nhỏ nhất bị gọi là tốt nhất tuyệt đối

AIC không kiểm tra residual, stability, GOF hoặc out-of-sample performance.
Phải đọc toàn bộ comparison.

## 25.11 p-value lớn bị gọi là chấp nhận H0

Nói “chưa đủ bằng chứng bác bỏ H0”. P-value lớn không chứng minh H0 đúng.

## 25.12 Word có số cũ

Không sửa số trực tiếp. Chạy pipeline, render lại Rmd và đối chiếu CSV.

## 25.13 Git có nhiều output thay đổi

Đây là bình thường sau rerun. Trước commit:

```powershell
git status --short
git diff --check
```

Chỉ commit artifact đúng phạm vi và không xóa thay đổi người khác.

---

# 26. Giới hạn và cách phát triển dự án

## 26.1 Giới hạn dữ liệu

- phụ thuộc Yahoo Finance;
- một ticker, không có market benchmark;
- fixed historical interval;
- corporate-action adjustment phụ thuộc provider;
- sample dài có thể chứa structural breaks.

## 26.2 Giới hạn forecast

- holdout chỉ 30 phiên;
- ARIMAX và SARIMA chưa có rolling CV cùng coverage;
- xreg availability khi triển khai chưa được mô phỏng đầy đủ;
- metric đơn vị giá bị ảnh hưởng bởi price level;
- chưa có prediction-interval coverage comparison.

## 26.3 Giới hạn GARCH

- mean equation cố định ARMA(0,0);
- three models fail Nyblom stability;
- tất cả fail Pearson GOF;
- chưa có out-of-sample volatility loss;
- chưa có VaR backtest;
- chưa thử skewed-t/GED/regime-switching.

## 26.4 Hướng phát triển ưu tiên

1. Chạy cùng rolling CV cho mọi forecast model.
2. Dùng scale-free metrics bổ sung như MASE.
3. Đánh giá prediction interval coverage.
4. Chia train/test volatility và dùng QLIKE/MSE trên proxy variance.
5. VaR backtest bằng Kupiec/Christoffersen.
6. Thử skewed Student-t hoặc GED.
7. Kiểm tra structural break và rolling parameter estimation.
8. Thêm VN-Index hoặc biến vĩ mô với thiết kế chống leakage.

## 26.5 Điều không nên làm chỉ để “tăng số model”

Không thêm model nếu không có:

- câu hỏi rõ;
- cùng protocol đánh giá;
- diagnostics;
- thời gian giải thích lý thuyết.

Rubric đánh giá sử dụng hợp lý, không chỉ số lượng tên model.

---

# 27. Checklist trước khi nộp

## 27.1 Code và dữ liệu

- [ ] `git status` được xem và hiểu mọi thay đổi.
- [ ] Raw/processed đúng schema.
- [ ] `R/run_all.R` chạy thành công trong session mới.
- [ ] `output/pipeline_log.txt` có start/completed.
- [ ] Không có error/convergence failure bị bỏ qua.

## 27.2 Báo cáo

- [ ] Tên ba thành viên và MSSV đúng.
- [ ] Môn “Lập trình R cho phân tích”, Nhóm 06.
- [ ] Giảng viên TS. Phan Thị Thể.
- [ ] Tỷ lệ 30%/35%/35% tổng bằng 100%.
- [ ] Word mở được, mục lục/bảng/hình không vỡ.
- [ ] Mọi số khớp CSV.
- [ ] Không còn câu chờ data handoff.
- [ ] Không có khuyến nghị đầu tư.

## 27.3 Slide

- [ ] Dùng `presentation/khung_noi_dung_slide.docx` làm khung.
- [ ] Mỗi slide chỉ giữ một đoạn đọc trực tiếp ngắn, khoảng 2-4 câu, không biến
      toàn bộ slide thành một trang báo cáo.
- [ ] Font tối thiểu 24 pt.
- [ ] Hình có nhãn và nguồn.
- [ ] Tổng thời lượng 10-12 phút.
- [ ] Mỗi người nói đúng module mình hiểu.

## 27.4 Bảo vệ

- [ ] Người 1 giải thích được return, OHLC và 9 hình.
- [ ] Người 2 giải thích được ADF, split, metric, CV và Ljung-Box.
- [ ] Người 3 viết được GARCH equation và bảo vệ lựa chọn eGARCH.
- [ ] Cả nhóm phân biệt forecast mean với volatility.
- [ ] Cả nhóm nêu được ít nhất ba hạn chế.
- [ ] Có thể nhìn và đọc các câu kết luận đã soạn, nhưng phải hiểu thuật ngữ để
      giải thích lại khi giảng viên hỏi.

## 27.5 Git

- [ ] Commit cuối chứa code, output cần nộp và tài liệu.
- [ ] Commit message rõ.
- [ ] Push đúng branch/repository.
- [ ] Tag hoặc ghi commit hash bản nộp.
- [ ] Không sửa trực tiếp sau khi nhóm đã ký xác nhận mà không rerun/review.

---

# 28. Bảng thuật ngữ

| Thuật ngữ | Giải thích ngắn |
|---|---|
| Actual | giá trị thực tế |
| ACF | autocorrelation theo lag |
| ADF | kiểm định unit root mở rộng Dickey-Fuller |
| AIC | tiêu chí fit có penalty số tham số |
| ARCH | variance phụ thuộc squared shock quá khứ |
| ARIMA | autoregressive integrated moving average |
| ARIMAX | ARIMA có biến giải thích ngoài |
| Asymmetry | shock khác dấu có tác động variance khác nhau |
| Backtest | đánh giá quy tắc/model trên dữ liệu ngoài mẫu lịch sử |
| Benchmark | baseline để model phức tạp phải vượt qua |
| BIC | information criterion penalty mạnh hơn theo sample size |
| Conditional mean | kỳ vọng dựa trên thông tin hiện có |
| Conditional variance | phương sai dựa trên thông tin hiện có |
| Convergence | optimizer tìm được nghiệm theo tiêu chí dừng |
| Cross-validation | đánh giá lặp trên nhiều train/test split |
| Data leakage | dùng thông tin tương lai/không sẵn có |
| Drift | độ trôi trung bình của random walk |
| eGARCH | GARCH trên log variance, hỗ trợ asymmetry |
| EDA | exploratory data analysis |
| ETS | error-trend-seasonality state-space |
| GARCH | generalized ARCH |
| GJR-GARCH | GARCH có indicator shock âm |
| GOF | goodness-of-fit |
| Heavy tails | xác suất cực trị lớn hơn Normal |
| Holdout | tập dữ liệu giữ lại để đánh giá |
| Innovation | shock ngoài conditional mean |
| Lag | giá trị quá khứ |
| Ljung-Box | kiểm định nhóm autocorrelation |
| Log return | log tỷ số hai giá liên tiếp |
| MAE | mean absolute error |
| MAPE | mean absolute percentage error |
| Mean equation | phương trình mô tả conditional mean |
| Naive | dự báo tương lai bằng quan sát cuối |
| Nyblom | kiểm định ổn định tham số |
| OHLCV | open, high, low, close, volume |
| Out-of-sample | dữ liệu model chưa dùng khi fit |
| PACF | partial autocorrelation |
| Persistence | mức độ dai dẳng của volatility shock |
| Residual | phần quan sát model không giải thích |
| RMSE | root mean squared error |
| Rolling origin | train mở rộng theo thời gian qua nhiều fold |
| SARIMA | ARIMA có thành phần mùa vụ |
| sGARCH | standard symmetric GARCH |
| Sign bias | phần bất đối xứng theo dấu shock còn sót |
| Stationarity | đặc tính phân phối bậc thấp ổn định theo thời gian |
| Student-t | distribution đuôi dày có shape parameter |
| Unit root | nghiệm đơn vị làm shock tích lũy trong level |
| Volatility | mức độ dao động/bất định, không phải hướng |
| Volatility clustering | biến động lớn/nhỏ xuất hiện theo cụm |
| White noise | chuỗi không còn autocorrelation có hệ thống |

---

# Phụ lục A - Cheat sheet số liệu cuối

```text
RAW
  Rows: 2960
  Zero volume: 173
  Fatal data checks: 0
  True OHLC repair: 1

CLEAN
  Rows: 2787
  Returns: 2786
  Period: 2015-01-05 to 2026-06-08
  Mean return: 0.0008365
  SD return: 0.0165820

ADF
  close: p = 0.6676
  log_close: p = 0.8665
  return: p <= 0.01

FORECAST
  Holdout: 30 sessions
  ETS Damped RMSE: 1939.13
  ETS Damped MAE: 1524.15
  ETS Damped MAPE: 2.10%
  CV leader among covered models: Naive
  Naive CV mean RMSE: 5353.94

GARCH
  Returns: 2786
  Models converged: 4/4
  Pre-fit ARCH-LM p: 1.09e-38
  Lowest AIC: GJR, -5.6344, but unstable
  Balanced candidate: eGARCH Student-t
  eGARCH AIC: -5.6331
  eGARCH Nyblom: 1.5048 < 1.68
  Pearson GOF: fail for all four
```

# Phụ lục B - Công thức cần nhớ

```text
Log return:
r_t = log(P_t / P_(t-1))

RMSE:
sqrt(mean((actual - predicted)^2))

MAE:
mean(abs(actual - predicted))

MAPE:
mean(abs((actual - predicted) / actual)) * 100

Mean equation:
r_t = mu_t + epsilon_t

Innovation:
epsilon_t = sigma_t * z_t

sGARCH(1,1):
sigma_t^2 = omega + alpha epsilon_(t-1)^2 + beta sigma_(t-1)^2

sGARCH persistence:
alpha + beta

Half-life:
log(0.5) / log(persistence)

sGARCH unconditional variance:
omega / (1 - alpha - beta), nếu alpha + beta < 1
```

# Phụ lục C - Một câu trả lời cuối cùng khi không chắc

Nếu bị hỏi sâu hơn phạm vi đã làm, không đoán. Có thể trả lời:

“Trong phạm vi dự án, nhóm chưa kiểm định trực tiếp giả thuyết đó. Kết quả hiện
tại chỉ hỗ trợ kết luận ... Dữ liệu hoặc kiểm định cần bổ sung là ... Đây là một
hướng mở rộng hợp lý.”

Câu trả lời thừa nhận giới hạn nhưng vẫn cho thấy hiểu phương pháp tốt hơn việc
khẳng định một điều không có bằng chứng.
