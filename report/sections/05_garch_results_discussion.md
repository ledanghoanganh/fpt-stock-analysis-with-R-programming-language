# Mô hình hóa conditional volatility

## Động cơ và phương trình

ARCH-LM trên raw return có p-value `r fmt_p(pre_arch$p_value)`. Với H0 “không có ARCH effect đến lag kiểm tra”, kết quả bác bỏ H0 và hỗ trợ dùng conditional variance model.

Mean và innovation equations là:

\[
r_t=\mu+\epsilon_t, \qquad \epsilon_t=\sigma_t z_t.
\]

Trong đó `epsilon_t` là shock return ngoài conditional mean, không phải residual giá. Baseline sGARCH(1,1) dùng:

\[
\sigma_t^2=\omega+\alpha_1\epsilon_{t-1}^2+\beta_1\sigma_{t-1}^2.
\]

`alpha` đo phản ứng với shock mới; `beta` đo memory của variance quá khứ; `alpha + beta` là persistence của sGARCH. Không áp dụng máy móc công thức này cho eGARCH hoặc GJR-GARCH.

## Specification được so sánh

| Model | Distribution | Vai trò |
|---|---|---|
| sGARCH(1,1) | Normal | Baseline đối xứng |
| sGARCH(1,1) | Student-t | Kiểm tra heavy tails |
| eGARCH(1,1) | Student-t | Log variance và asymmetry |
| GJR-GARCH(1,1) | Student-t | Indicator cho shock âm |

Cả bốn model dùng cùng `r fmt_number(n_returns, 0)` returns và mean equation ARMA(0,0), nên AIC/BIC có thể so sánh tương đối trên cùng response/sample. Cả bốn optimizer báo convergence bằng 0.

## So sánh fit và diagnostics

```{r volatility-comparison-table}
volatility_report <- volatility_comparison %>%
  select(model, aic, bic, delta_aic, persistence,
         core_diagnostics_pass, sign_bias_pass,
         parameter_stability_pass, distribution_fit_pass,
         provisional_candidate, evidence_assessment)
kable(volatility_report,
      caption = "So sánh GARCH bằng fit, residual checks, stability và GOF",
      digits = 5)
```

Student-t cải thiện AIC rõ so với sGARCH-Normal, phù hợp với heavy tails quan sát trong EDA. GJR-GARCH-Student-t có AIC thấp nhất, nhưng Nyblom bác bỏ parameter stability. eGARCH-Student-t chỉ kém GJR `r fmt_number(volatility_candidate$delta_aic, 5)` AIC, đồng thời core residual diagnostics và joint stability đạt; vì vậy đây là ứng viên cân bằng theo quy tắc định trước, không phải model “hoàn hảo”.

```{r garch-diagnostic-table}
garch_diag_report <- volatility_comparison %>%
  select(model, ljung_box_residual_p, ljung_box_squared_p, arch_lm_p,
         sign_bias_joint_p, nyblom_joint, nyblom_5pct_critical,
         pearson_group20_p)
kable(garch_diag_report, caption = "P-value và statistics chẩn đoán GARCH", digits = 5)
```

Ljung-Box standardized residual, Ljung-Box squared residual và ARCH-LM sau fit đều chưa bác bỏ H0 ở mức 5% cho cả bốn model. Sign-bias joint test cũng chưa bác bỏ H0. Tuy nhiên, Nyblom chỉ chấp nhận joint stability cho eGARCH; adjusted Pearson GOF bác bỏ distribution fit ở cả bốn specification.

## Tham số candidate

```{r candidate-parameter-table}
candidate_parameters <- garch_parameters %>%
  filter(model == volatility_candidate$model) %>%
  select(parameter, estimate, std_error, p_value,
         robust_std_error, robust_p_value)
kable(candidate_parameters,
      caption = "Tham số eGARCH-Student-t: conventional và robust inference",
      digits = 6)
```

Robust inference quan trọng vì distribution GOF chưa đạt. Ví dụ, một tham số có conventional p-value nhỏ nhưng robust p-value lớn không nên được diễn giải mạnh. `beta1` của eGARCH gần 1 cho thấy volatility có memory dài theo parameterization của model; không cộng `alpha1 + beta1` như sGARCH.

## Volatility và asymmetry theo thời gian

```{r garch-comparison-figure, fig.cap="Conditional volatility của bốn GARCH specification"}
include_required_figure("output/figures/garch_model_comparison.png")
```

Bốn đường broadly đồng biến và đều cho thấy volatility clustering. Các đỉnh chỉ mô tả giai đoạn model ước lượng conditional volatility cao; báo cáo không tự gán nguyên nhân sự kiện nếu chưa có nguồn bên ngoài.

```{r garch-acf-figure, fig.cap="ACF standardized residual và squared standardized residual"}
include_required_figure("output/figures/garch_acf_diagnostics.png")
```

```{r news-impact-figure, fig.cap="News-impact curves của eGARCH và GJR-GARCH"}
include_required_figure("output/figures/garch_news_impact.png")
```

News-impact curves mô tả phản ứng khác nhau với standardized shock âm và dương. Đây là minh họa cấu trúc bất đối xứng; diễn giải leverage phải dựa trên đúng dấu, parameterization và robust significance của package.

## Kết luận phần volatility

eGARCH-Student-t là ứng viên cân bằng nhất trong bốn specification đã thử vì fit gần GJR, core diagnostics đạt và Nyblom stability đạt. Pearson GOF vẫn bị bác bỏ và dự án chưa đánh giá volatility forecast ngoài mẫu bằng QLIKE/MSE hoặc VaR backtest. Do đó kết quả chỉ mô tả conditional volatility lịch sử, không phải hệ thống quản trị rủi ro sẵn sàng triển khai.
