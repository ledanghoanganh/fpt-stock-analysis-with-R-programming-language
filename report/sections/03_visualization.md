# Phân tích khám phá và trực quan hóa

## Giá và khối lượng

```{r price-figure, fig.cap="Giá đóng cửa điều chỉnh của FPT"}
include_required_figure("output/figures/close_price.png")
```

Giá thay đổi rõ về level và có xu hướng dài hạn; biểu đồ gợi ý non-stationarity nhưng không thay thế ADF. Không thể suy ra nguyên nhân kinh tế hoặc xu hướng tương lai chỉ từ đường giá.

```{r volume-figure, fig.cap="Khối lượng giao dịch FPT theo thời gian"}
include_required_figure("output/figures/volume.png")
```

Volume phân tán mạnh và có các quan sát cực lớn. Hình được dùng mô tả thanh khoản, không chứng minh một sự kiện hay quan hệ nhân quả nếu chưa có nguồn độc lập.

## Log return và volatility clustering

```{r return-figure, fig.cap="Log return hằng ngày của FPT"}
include_required_figure("output/figures/returns.png")
```

Return dao động quanh 0 nhưng biên độ không ổn định: giai đoạn biến động lớn thường xuất hiện gần nhau. Đây là dấu hiệu thăm dò của volatility clustering; ARCH-LM ở phần GARCH kiểm định chính thức cấu trúc phương sai.

```{r squared-return-figure, fig.cap="Bình phương log return và các cụm biến động"}
include_required_figure("output/figures/squared_returns.png")
```

Squared return loại dấu và giữ độ lớn shock. Các spike theo cụm củng cố động cơ dùng conditional variance model thay vì một variance cố định cho toàn sample.

## Hình dạng phân phối

```{r distribution-figure, fig.cap="Phân phối thực nghiệm của log return so với Normal"}
include_required_figure("output/figures/return_distribution.png")
```

Mật độ thực nghiệm lệch khỏi Normal cùng mean/SD, đặc biệt ở phần đuôi. Vì vậy dự án so sánh Normal với standardized Student-t trong GARCH.

```{r qq-figure, fig.cap="Q-Q plot của log return so với Normal"}
include_required_figure("output/figures/qqplot_return.png")
```

Các điểm lệch đường tham chiếu ở hai đuôi gợi ý heavy tails. Q-Q plot chỉ là chẩn đoán trực quan; adjusted Pearson GOF sau GARCH mới kiểm tra distribution fit định lượng.

## Tự tương quan và yếu tố lịch

```{r acf-pacf-figures, fig.show='hold', out.width='48%', fig.cap="ACF (trái) và PACF (phải) của log return"}
include_required_figure("output/figures/acf_return.png")
include_required_figure("output/figures/pacf_return.png")
```

ACF/PACF return quan sát dependence tuyến tính theo lag, không chứng minh quan hệ nhân quả. ACF return nhỏ không loại trừ dependence trong squared return hoặc conditional variance.

```{r weekday-figure, fig.cap="Phân phối log return theo ngày trong tuần"}
include_required_figure("output/figures/return_by_weekday.png")
```

Boxplot weekday chỉ là bằng chứng thăm dò. Dự án không tuyên bố weekday effect vì chưa có kiểm định chuyên biệt và điều chỉnh multiple testing. SARIMA chu kỳ 5 được xem là một specification thử nghiệm, không phải bằng chứng mùa vụ đã được xác nhận.
