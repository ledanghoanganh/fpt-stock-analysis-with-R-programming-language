# HƯỚNG DẪN RIÊNG CHO NGƯỜI 3

## Lê Đặng Hoàng Anh - MSSV 24162006

**Môn:** Lập trình R cho phân tích  
**Nhóm:** 06  
**Phần phụ trách:** GARCH, diagnostics, so sánh mô hình và tích hợp báo cáo

---

# 1. Đọc phần này trước: dự án đang kể câu chuyện gì?

Đừng bắt đầu bằng công thức. Hãy bắt đầu bằng câu hỏi.

Giá FPT thay đổi mỗi ngày. Nhóm muốn trả lời hai câu hỏi khác nhau:

1. **Ngày sau giá có thể ở mức nào?** Đây là bài toán forecast giá do Người 2
   phụ trách.
2. **Mức độ bất định của thay đổi giá đang cao hay thấp?** Đây là bài toán
   volatility do bạn phụ trách.

GARCH không trả lời “ngày mai FPT giá bao nhiêu”. GARCH trả lời gần với câu:

> Dựa trên thông tin đến hôm nay, mức dao động của log return ở phiên tiếp theo
> được mô hình ước lượng là cao hay thấp?

## Ví dụ trực tiếp trong dữ liệu FPT

Dữ liệu sạch có 2.787 phiên từ 05/01/2015 đến 08/06/2026 và tạo được 2.786 log
returns. Return trung bình khoảng `0,0008365`, còn độ lệch chuẩn khoảng
`0,016582`, tức khoảng `1,658%` mỗi phiên.

Return nhỏ nhất là khoảng `-7,248%`, lớn nhất khoảng `8,853%`. Những phiên cực
đoan không xuất hiện hoàn toàn đều đặn: có giai đoạn nhiều dao động lớn đứng gần
nhau, có giai đoạn tương đối yên. Hiện tượng đó gọi là **volatility clustering**.

ARCH-LM trên raw return cho p-value khoảng `1,09 × 10^-38`. Kết quả này bác bỏ
giả thuyết “không có ARCH effect”, tạo cơ sở dùng GARCH.

## Một câu phải nhớ

> Giá cho biết mức giá; return cho biết thay đổi tương đối; volatility cho biết
> độ lớn bất định của return; GARCH mô hình hóa volatility thay đổi theo thời gian.

---

# 2. Từ điển thuật ngữ bằng ví dụ của dự án

Đọc hết phần này trước khi học công thức.

## 2.1 Price, close và adjusted close

`close` là giá đóng cửa trong dữ liệu đã dùng `auto_adjust = TRUE` từ Yahoo
Finance. Nó là mức giá, có đơn vị gần với VND và có xu hướng dài hạn.

Ví dụ: `close = 100000` nghĩa là mức giá khoảng 100.000, không có nghĩa return
là 100.000.

## 2.2 Simple return và log return

Nếu giá từ 100.000 lên 102.000:

```text
simple return = 102000 / 100000 - 1 = 2%
log return    = log(102000 / 100000) ≈ 1,98%
```

Dự án chỉ dùng **log return**:

```text
r_t = log(P_t) - log(P_(t-1))
```

Không được trộn simple return với log return. Không được nhân return với 100 ở
một model nhưng giữ dạng thập phân ở model khác. Cả bốn GARCH dùng return dạng
thập phân, ví dụ `0,02` nghĩa là khoảng `2%`.

## 2.3 Mean

Mean là trung bình hoặc kỳ vọng. Mean return lịch sử FPT khoảng `0,0008365`.
Đây chỉ là thống kê của sample, không phải lợi nhuận chắc chắn ngày mai.

## 2.4 Variance và standard deviation

Variance đo mức phân tán bằng đơn vị bình phương. Standard deviation là căn bậc
hai của variance nên dễ diễn giải hơn.

Nếu conditional variance là `0,0004` thì conditional volatility là:

```text
sqrt(0,0004) = 0,02 = 2%
```

## 2.5 Volatility

Volatility là mức dao động hoặc bất định, không phải hướng tăng giảm. Return
`+5%` và `-5%` đều có độ lớn 5%, nên đều có thể làm volatility tăng.

## 2.6 Conditional

“Conditional” nghĩa là “có điều kiện trên thông tin đã biết”.

- Unconditional mean: một trung bình chung cho toàn sample.
- Conditional mean: kỳ vọng tại thời điểm `t` dựa trên thông tin đến `t-1`.
- Conditional variance: variance tại `t` dựa trên thông tin đến `t-1`.

GARCH quan tâm conditional variance, vì variance hôm nay không nhất thiết bằng
variance của nhiều năm trước.

## 2.7 Shock, innovation và residual

Trong dự án:

```text
r_t = mu_t + epsilon_t
```

`epsilon_t` là phần return ngoài conditional mean. Nó là **shock return**, không
phải chênh lệch giữa giá dự báo và giá thực tế.

Ví dụ model kỳ vọng return `0,1%`, thực tế return `-2%`:

```text
epsilon_t = -2% - 0,1% = -2,1%
```

Sau khi fit, giá trị ước lượng của shock thường được gọi là residual.

## 2.8 Standardized innovation

```text
epsilon_t = sigma_t * z_t
z_t = epsilon_t / sigma_t
```

`z_t` là shock sau khi chia cho volatility. Nếu model đúng, standardized
residual nên không còn cấu trúc rõ rệt và có variance gần 1.

## 2.9 Lag

Lag là giá trị quá khứ. `epsilon_(t-1)` là shock của phiên trước;
`sigma_(t-1)` là volatility ước lượng của phiên trước.

## 2.10 Stationarity và unit root

Chuỗi dừng có các đặc tính cơ bản tương đối ổn định theo thời gian. Unit root
làm shock tích lũy trong level, khiến chuỗi khó quay lại một mức cố định.

ADF trong dự án:

| Chuỗi | p-value | Kết luận 5% |
|---|---:|---|
| `close` | 0,6676 | Chưa bác bỏ unit root |
| `log_close` | 0,8665 | Chưa bác bỏ unit root |
| `return` | 0,01 | Bác bỏ unit root; return dừng |

Vì vậy GARCH dùng `return`, không fit trực tiếp trên `close`.

## 2.11 Heavy tails

Heavy tails nghĩa là quan sát cực đoan xuất hiện thường hơn so với Normal.
Histogram và Q-Q plot của return FPT cho thấy dấu hiệu đuôi dày. Đây là lý do
nhóm thử Student-t.

## 2.12 Symmetry và asymmetry

Model đối xứng cho shock `+x` và `-x` cùng tác động nếu có cùng độ lớn. Model
bất đối xứng cho phép shock âm và dương tác động khác nhau. eGARCH và GJR-GARCH
được thêm để kiểm tra điều này.

## 2.13 Leverage effect

Leverage effect thường mô tả việc shock âm làm volatility tăng mạnh hơn shock
dương cùng độ lớn. Không được kết luận leverage chỉ vì model có tham số bất đối
xứng; phải đọc đúng dấu, parameterization và significance.

## 2.14 Model, specification và distribution

- Model/specification: dạng phương trình, ví dụ sGARCH hay eGARCH.
- Distribution: giả định cho `z_t`, ví dụ Normal hoặc Student-t.

sGARCH-Normal và sGARCH-Student-t có cùng variance structure nhưng khác
distribution.

## 2.15 Parameter và estimate

Parameter là đại lượng chưa biết của model. Estimate là giá trị model ước lượng
từ dữ liệu. Ví dụ `beta1 = 0,96267` là estimate của eGARCH-t trong sample này.

## 2.16 Standard error, robust standard error và p-value

- Standard error đo độ bất định của estimate dưới giả định model.
- Robust standard error thận trọng hơn khi một số giả định có thể sai.
- P-value nhỏ cho bằng chứng chống H0, nhưng không đo độ lớn tác động.

Ví dụ `alpha1` của eGARCH-t có conventional p-value khoảng `0,0366`, nhưng
robust p-value khoảng `0,1699`. Vì vậy không nên diễn giải mạnh `alpha1` chỉ dựa
trên conventional inference.

## 2.17 Convergence

Optimizer tìm parameter bằng tối ưu số. `convergence = 0` trong `rugarch` nghĩa
là thuật toán báo hội tụ. Cả 4 model của dự án đều có convergence bằng 0.

Hội tụ không đồng nghĩa model đúng; nó chỉ cho biết quá trình tối ưu kết thúc
theo tiêu chí của solver.

## 2.18 Likelihood, AIC và BIC

Likelihood đo mức dữ liệu phù hợp với model. AIC/BIC kết hợp fit với penalty độ
phức tạp. Trong cùng response và sample, AIC/BIC thấp hơn tốt hơn theo nghĩa
relative fit.

AIC không phải phần trăm chính xác. AIC âm không có nghĩa model “chính xác âm”.

## 2.19 Persistence

Persistence đo mức dai dẳng của volatility shock.

Với sGARCH(1,1):

```text
persistence = alpha + beta
```

Gần 1 nghĩa shock tiêu tan chậm. Không dùng máy móc `alpha + beta` cho eGARCH;
pipeline trích persistence theo đúng specification của package.

## 2.20 Residual diagnostics

Diagnostics là các kiểm tra sau khi fit. Câu hỏi là: model đã lấy hết cấu trúc
cần thiết chưa, tham số có ổn định không, distribution có phù hợp không?

## 2.21 H0, bác bỏ và chưa bác bỏ

H0 là giả thuyết không. Quy tắc mức 5%:

- `p < 0,05`: bác bỏ H0.
- `p >= 0,05`: chưa đủ bằng chứng bác bỏ H0.

Không nói “chấp nhận H0” và không nói p-value lớn chứng minh model hoàn hảo.

---

# 3. Từ ARCH đến GARCH bằng trực giác

## 3.1 Tại sao bình phương shock xuất hiện?

Shock `+3%` và `-3%` khác dấu nhưng cùng độ lớn. Bình phương cả hai đều là
`0,0009`, nhờ đó phương trình variance tập trung vào độ lớn biến động.

## 3.2 ARCH

ARCH cho variance hôm nay phụ thuộc squared shocks quá khứ. Ý tưởng đúng nhưng
có thể cần nhiều lag.

## 3.3 GARCH(1,1)

GARCH thêm variance quá khứ, tạo trí nhớ gọn hơn:

```text
r_t = mu + epsilon_t
epsilon_t = sigma_t * z_t
sigma_t^2 = omega + alpha * epsilon_(t-1)^2
                    + beta * sigma_(t-1)^2
```

Đọc bằng lời:

> Variance hôm nay bằng mức nền, cộng phản ứng với shock mới hôm qua, cộng phần
> ghi nhớ từ variance hôm qua.

| Ký hiệu | Cách hiểu |
|---|---|
| `mu` | mean return có điều kiện |
| `epsilon_t` | shock return ngoài mean |
| `sigma_t^2` | conditional variance |
| `sigma_t` | conditional volatility |
| `z_t` | standardized innovation |
| `omega` | mức variance nền |
| `alpha` | phản ứng với shock mới |
| `beta` | trí nhớ variance quá khứ |

## 3.4 Ví dụ sGARCH-Student-t trong dự án

Estimate:

```text
alpha = 0,11875
beta  = 0,87039
alpha + beta = 0,98914
```

Persistence rất gần 1: volatility shock tiêu tan chậm. Đây không có nghĩa giá
chắc chắn giảm hay tăng; nó chỉ nói độ bất định có trí nhớ dài.

## 3.5 Unconditional variance và half-life

Với sGARCH và `alpha + beta < 1`:

```text
unconditional variance = omega / (1 - alpha - beta)
half-life = log(0,5) / log(alpha + beta)
```

Half-life là số phiên để ảnh hưởng shock giảm còn khoảng một nửa theo mô hình.
Hai công thức này không áp dụng máy móc cho eGARCH/GJR.

---

# 4. Vì sao dự án dùng bốn GARCH specification?

| Model | Lý do đưa vào |
|---|---|
| sGARCH-Normal | baseline đơn giản, đối xứng |
| sGARCH-Student-t | giữ cấu trúc sGARCH, xử lý heavy tails tốt hơn |
| eGARCH-Student-t | mô hình log variance và asymmetry |
| GJR-GARCH-Student-t | thêm indicator cho shock âm |

Trình tự quyết định:

1. Bắt đầu bằng baseline sGARCH-Normal.
2. Q-Q plot cho thấy heavy tails, nên thử Student-t.
3. Tin xấu/tốt có thể tác động khác nhau, nên thử eGARCH và GJR.
4. Giữ cùng 2.786 returns và mean equation ARMA(0,0) để so sánh công bằng.

## ARMA(0,0) là gì?

Mean equation không có AR và MA lag, chỉ có mean. Nhóm giữ nó giống nhau để tập
trung so sánh variance specification. Đây là quyết định thiết kế, không phải
tuyên bố mọi mean dynamics đều không tồn tại.

---

# 5. Các kiểm định bạn phải giải thích được

## 5.1 ARCH-LM trước fit

H0: không có ARCH effect đến lag kiểm tra. P-value `1,09 × 10^-38` rất nhỏ nên
bác bỏ H0. Kết luận: có bằng chứng conditional heteroskedasticity, hợp lý để thử
GARCH. Nó không chứng minh GARCH(1,1) là model tốt nhất.

## 5.2 Ljung-Box standardized residuals

H0: không còn autocorrelation đến các lag kiểm tra. eGARCH-t có p-value khoảng
`0,8773`, nên chưa bác bỏ H0. Mean dependence còn sót không được phát hiện.

## 5.3 Ljung-Box squared standardized residuals

H0: bình phương residual không còn autocorrelation. eGARCH-t có p-value
`0,8423`, nên chưa phát hiện variance dependence còn sót.

## 5.4 ARCH-LM sau fit

eGARCH-t có p-value `0,6458`. Chưa phát hiện ARCH effect còn sót. Đây là dấu
hiệu core variance dynamics đã được xử lý tương đối tốt.

## 5.5 Sign-bias test

H0: không còn sign bias. Joint p-value của eGARCH-t khoảng `0,1017`, nên chưa
bác bỏ H0. Không có bằng chứng mạnh về bất đối xứng còn bỏ sót theo test này.

## 5.6 Nyblom stability

Nyblom kiểm tra parameter stability theo thời gian. So joint statistic với
critical value 5%:

```text
eGARCH-t: 1,5048 < 1,68  -> đạt
GJR-t:   27,3478 > 1,68  -> không đạt
```

Đây là lý do quan trọng không chọn GJR chỉ vì AIC thấp nhất.

## 5.7 Adjusted Pearson GOF

H0: distribution giả định phù hợp với residual distribution theo cách chia
nhóm của test. P-value của cả bốn model rất nhỏ, nên cả bốn đều không đạt.

Kết luận đúng: distribution fit còn là hạn chế. Kết luận sai: “toàn bộ GARCH vô
giá trị”. Một model có thể xử lý dynamics tương đối tốt nhưng distribution fit
vẫn chưa hoàn hảo.

---

# 6. Đọc bảng kết quả cuối và chọn model

| Model | AIC | Persistence | Core diag. | Nyblom |
|---|---:|---:|---|---|
| GJR-GARCH-t | **-5,63443** | 0,98574 | Đạt | Không đạt |
| eGARCH-t | -5,63306 | 0,96267 | Đạt | **Đạt** |
| sGARCH-t | -5,63173 | 0,98914 | Đạt | Không đạt |
| sGARCH-Normal | -5,50730 | 0,96451 | Đạt | Không đạt |

## 6.1 Tại sao không chọn sGARCH-Normal?

Student-t cải thiện AIC rõ so với Normal, phù hợp với heavy tails của return.

## 6.2 Tại sao không chọn GJR dù AIC thấp nhất?

GJR chỉ hơn eGARCH khoảng `0,00137` AIC, một khoảng rất nhỏ, nhưng Nyblom joint
statistic của GJR vượt xa critical value. Parameter stability là vấn đề lớn.

## 6.3 Tại sao chọn eGARCH-Student-t?

eGARCH-t là **ứng viên cân bằng**, vì:

- AIC gần model thấp nhất;
- convergence đạt;
- Ljung-Box residual đạt;
- Ljung-Box squared residual đạt;
- ARCH-LM sau fit đạt;
- sign-bias joint chưa bị bác bỏ;
- Nyblom joint stability đạt.

Nhưng Pearson GOF không đạt, nên không gọi eGARCH-t là model hoàn hảo.

## Câu trả lời mẫu

> Nhóm không chọn model chỉ theo AIC. GJR-GARCH-t có AIC thấp nhất nhưng Nyblom
> bác bỏ tính ổn định tham số. eGARCH-t chỉ kém khoảng 0,00137 AIC, trong khi core
> residual diagnostics và Nyblom stability đều đạt. Vì vậy nhóm chọn eGARCH-t
> làm ứng viên cân bằng, đồng thời thừa nhận Pearson GOF vẫn là hạn chế.

---

# 7. Hiểu các tham số eGARCH-Student-t

Các estimate chính:

| Parameter | Estimate | Robust p-value | Cách đọc thận trọng |
|---|---:|---:|---|
| `mu` | 0,000477 | 0,0407 | conditional mean nhỏ, dương trong sample |
| `omega` | -0,303887 | rất nhỏ | intercept của log-variance equation |
| `alpha1` | -0,047986 | 0,1699 | không diễn giải mạnh theo robust inference |
| `beta1` | 0,962670 | rất nhỏ | volatility có memory dài |
| `gamma1` | 0,240236 | rất nhỏ | thành phần asymmetry có bằng chứng |
| `shape` | 3,596439 | rất nhỏ | Student-t có đuôi dày |

Không áp cách đọc `alpha + beta` của sGARCH lên eGARCH. Dấu và vai trò của
`alpha`, `gamma` phụ thuộc parameterization của `rugarch`; khi báo cáo nên bám
news-impact curve và robust inference thay vì tự suy diễn dấu.

---

# 8. Bạn đã làm gì trong code?

## 8.1 `R/04_garch_volatility.R`

File này:

1. Đọc `fpt_clean.csv` và lấy 2.786 return hợp lệ.
2. Chạy ARCH-LM trước fit.
3. Định nghĩa bốn `ugarchspec()`.
4. Fit bằng `ugarchfit()`.
5. Trích parameter, AIC/BIC, persistence và convergence.
6. Chạy residual, ARCH, sign-bias, Nyblom và Pearson diagnostics.
7. Xuất CSV, model RDS và hình GARCH.

### Cách đọc `ugarchspec()`

```r
spec <- rugarch::ugarchspec(
  variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)
```

- `model = "eGARCH"`: chọn variance specification.
- `garchOrder = c(1, 1)`: một ARCH lag và một GARCH lag.
- `armaOrder = c(0, 0)`: mean không có AR/MA lag.
- `include.mean = TRUE`: vẫn ước lượng `mu`.
- `std`: standardized Student-t.

## 8.2 `R/05_model_comparison.R`

File này không fit lại model. Nó ghép:

- fit statistics;
- diagnostics;
- stability;
- distribution GOF;

sau đó tạo rule chọn candidate. Quy tắc quan trọng là model phải đạt core
diagnostics và stability; trong nhóm đủ điều kiện mới ưu tiên AIC.

## 8.3 `R/06_export_report_tables.R`

File này gom các CSV thành `report_tables.xlsx` để kiểm tra và nộp. Nó không
thay đổi kết luận thống kê.

## 8.4 `report/report.Rmd`

Rmd đọc CSV/PNG đã tạo, chèn bảng và hình rồi render Word. Nó không fit model
trong lúc knit. Điều này giữ báo cáo nhanh và tách modeling khỏi presentation.

## 8.5 `R/run_all.R`

Entry point chạy lần lượt module 01-06, render báo cáo và khung slide, rồi ghi
`output/pipeline_log.txt`.

---

# 9. Các hình của phần Người 3 phải đọc thế nào?

## `squared_returns.png`

Các spike xuất hiện thành cụm là bằng chứng trực quan về volatility clustering.
Đây chỉ là gợi ý; ARCH-LM mới là kiểm định định lượng.

## `garch_model_comparison.png`

Bốn đường volatility broadly đồng biến, nhưng khác độ cao ở các đỉnh. Hình mô
tả conditional volatility lịch sử, không phải forecast giá và không tự cho biết
nguyên nhân sự kiện.

## `garch_acf_diagnostics.png`

ACF standardized residual kiểm tra mean dependence còn sót. ACF squared
standardized residual kiểm tra variance dependence còn sót. Cột nằm trong biên
gợi ý autocorrelation nhỏ, nhưng phải đọc cùng Ljung-Box/ARCH-LM.

## `garch_news_impact.png`

So sánh response với standardized shock âm và dương. Đường không đối xứng minh
họa asymmetry. Không tự gắn một đỉnh với sự kiện nếu chưa có nguồn bên ngoài.

---

# 10. Kịch bản trình bày phần Người 3

## Mở phần

> Phần dự báo trước tập trung vào conditional mean của giá. Phần của em giải
> quyết câu hỏi khác: độ bất định của return thay đổi như thế nào theo thời gian.

## Lý do dùng GARCH

> Log return đã dừng nhưng squared return xuất hiện theo cụm. ARCH-LM có p-value
> khoảng 1,09 nhân 10 mũ âm 38, nên nhóm bác bỏ giả thuyết không có ARCH effect
> và thử conditional variance models.

## Giải thích phương trình

> Trong sGARCH, variance hôm nay gồm mức nền, phản ứng với squared shock hôm qua
> và trí nhớ của variance hôm qua. Alpha đo phản ứng với tin mới, beta đo memory,
> còn alpha cộng beta là persistence riêng cho sGARCH.

## Lý do thử bốn model

> sGARCH-Normal là baseline. Nhóm thêm Student-t vì dữ liệu có heavy tails, rồi
> thử eGARCH và GJR để biểu diễn asymmetry. Cả bốn dùng cùng response, sample và
> mean equation nên AIC/BIC có thể so sánh tương đối.

## Quyết định model

> GJR có AIC thấp nhất nhưng không đạt Nyblom stability. eGARCH chỉ kém khoảng
> 0,00137 AIC và đạt core diagnostics cùng Nyblom, nên là ứng viên cân bằng. Tuy
> nhiên Pearson GOF vẫn bị bác bỏ, vì vậy nhóm không gọi model là hoàn hảo.

## Phần việc cá nhân

> Em phụ trách xây dựng bốn GARCH specification, trích diagnostics, xây bảng so
> sánh và tích hợp output vào báo cáo. Các kết quả được sinh từ pipeline R và có
> thể truy ngược về CSV thay vì chép thủ công.

## Kết phần

> Kết quả mô tả conditional volatility lịch sử trong sample hiện tại, không phải
> khuyến nghị đầu tư hay hệ thống quản trị rủi ro sẵn sàng triển khai.

---

# 11. Câu hỏi phản biện và đáp án ngắn

## Vì sao không fit GARCH trên close?

`close` không dừng theo ADF và chứa stochastic trend. GARCH được dùng cho shock
quanh mean equation, nên dự án dùng log return dừng.

## `epsilon_t` có phải sai số giá không?

Không. Nó là return thực tế trừ conditional mean return, tức shock return ngoài
dự kiến.

## ARCH-LM có chứng minh GARCH(1,1) tốt nhất không?

Không. Nó chỉ phát hiện ARCH effect và hỗ trợ thử conditional variance model.
Model nào phù hợp phải được so sánh và chẩn đoán tiếp.

## Persistence gần 1 nghĩa là gì?

Volatility shock tiêu tan chậm. Nó không có nghĩa giá sẽ giữ nguyên hay chắc
chắn giảm.

## Vì sao Student-t tốt hơn Normal?

Return có heavy tails và sGARCH-t cải thiện AIC rõ so với sGARCH-Normal trên
cùng sample.

## Vì sao không chọn GJR?

AIC thấp nhất nhưng Nyblom bác bỏ parameter stability; lợi thế AIC so với
eGARCH chỉ khoảng 0,00137.

## p-value lớn có chứng minh model đúng không?

Không. Nó chỉ cho biết chưa đủ bằng chứng bác bỏ H0 trong test đó.

## Pearson GOF fail có phủ nhận mọi kết quả không?

Không. Core dynamics có thể được xử lý tương đối tốt, nhưng distribution giả
định vẫn chưa mô tả hết residual distribution. Đây là hạn chế cần công bố.

## GARCH có dự báo khủng hoảng không?

Không biết trước sự kiện hoàn toàn mới. Nó cập nhật và forecast variance dựa
trên dynamics lịch sử.

## Kết quả có phải khuyến nghị mua bán không?

Không. Dự án học thuật, không định giá nội tại, không backtest chiến lược và
chưa có VaR backtest.

---

# 12. Lỗi diễn giải tuyệt đối phải tránh

| Không nói | Nên nói |
|---|---|
| “GARCH dự báo giá” | “GARCH mô hình hóa conditional variance của return” |
| “p-value bằng 0” | “p-value rất nhỏ hoặc dưới độ chính xác hiển thị” |
| “chấp nhận H0” | “chưa đủ bằng chứng bác bỏ H0” |
| “AIC thấp nhất nên tốt nhất tuyệt đối” | “AIC tốt nhất về relative in-sample fit” |
| “eGARCH là model hoàn hảo” | “eGARCH-t là ứng viên cân bằng trong bốn model” |
| “volatility cao nghĩa là giá giảm” | “volatility cao nghĩa là độ bất định lớn” |
| “alpha + beta của mọi GARCH” | “alpha + beta chỉ dùng trực tiếp cho sGARCH” |
| “đỉnh volatility do sự kiện X” | Chỉ nói vậy nếu có nguồn và kiểm chứng sự kiện |

---

# 13. Lộ trình học trong một buổi

## Vòng 1 - 30 phút

1. Đọc phần 1 và 2.
2. Tự nói lại bốn khái niệm: return, volatility, conditional variance, shock.
3. Nhìn `squared_returns.png` và giải thích volatility clustering.

## Vòng 2 - 45 phút

1. Đọc phần 3-5.
2. Viết lại sGARCH equation bằng tay.
3. Nói H0 và kết luận cho ARCH-LM, Ljung-Box, Nyblom, Pearson.

## Vòng 3 - 45 phút

1. Đọc phần 6-9.
2. Mở `volatility_model_comparison.csv`.
3. Tự trả lời vì sao chọn eGARCH thay GJR mà không nhìn đáp án.

## Vòng 4 - 30 phút

1. Đọc to kịch bản phần 10.
2. Trả lời ngẫu nhiên câu hỏi phần 11.
3. Kiểm tra không mắc lỗi diễn giải ở phần 12.

---

# 14. Checklist trước khi báo cáo

- [ ] Phân biệt được `close`, return và volatility.
- [ ] Giải thích được `epsilon_t` không phải residual giá.
- [ ] Viết và đọc được phương trình sGARCH(1,1).
- [ ] Hiểu `alpha`, `beta`, persistence.
- [ ] Nêu được lý do dùng Student-t và model bất đối xứng.
- [ ] Nêu đúng H0 của ARCH-LM và Ljung-Box.
- [ ] Giải thích được Nyblom và Pearson GOF.
- [ ] Bảo vệ được lựa chọn eGARCH-t thay vì GJR-t.
- [ ] Nêu được ít nhất ba hạn chế.
- [ ] Biết mình phụ trách file `R/04` đến `R/06` và tích hợp báo cáo.
- [ ] Không gọi kết quả là khuyến nghị đầu tư.

---

# 15. Cheat sheet một trang

```text
DATA
  2.787 clean rows; 2.786 log returns
  2015-01-05 to 2026-06-08
  Mean return = 0,0008365
  SD return   = 0,016582

ADF
  close p = 0,6676       -> chưa bác bỏ unit root
  log_close p = 0,8665   -> chưa bác bỏ unit root
  return p = 0,01        -> bác bỏ unit root

PRE-FIT
  ARCH-LM p ≈ 1,09e-38   -> có ARCH effect

MODELS
  sGARCH-Normal          -> baseline
  sGARCH-Student-t       -> heavy tails
  eGARCH-Student-t       -> log variance + asymmetry
  GJR-GARCH-Student-t    -> indicator shock âm

DECISION
  GJR AIC = -5,63443     -> thấp nhất, nhưng Nyblom fail
  eGARCH AIC = -5,63306  -> chỉ kém 0,00137
  eGARCH Nyblom 1,5048 < 1,68 -> đạt
  eGARCH core diagnostics -> đạt
  Pearson GOF -> fail cả 4
  Kết luận: eGARCH-t là ứng viên cân bằng, không hoàn hảo

FILES
  R/04_garch_volatility.R
  R/05_model_comparison.R
  R/06_export_report_tables.R
  output/tables/volatility_model_comparison.csv
  output/tables/garch_diagnostics.csv
  output/tables/garch_parameters.csv
```

Nếu bị hỏi ngoài phạm vi, trả lời trung thực:

> Trong phạm vi dự án, nhóm chưa kiểm định trực tiếp điều đó. Kết quả hiện tại
> chỉ hỗ trợ kết luận này trong sample và specification đã thử. Để trả lời đầy
> đủ cần bổ sung kiểm định hoặc thiết kế đánh giá ngoài mẫu tương ứng.
