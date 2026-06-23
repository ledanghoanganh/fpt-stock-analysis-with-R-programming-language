# MODULE 04 - MÔ HÌNH HÓA CONDITIONAL VOLATILITY
source("R/00_config.R")
require_packages(c("rugarch", "FinTS", "scales"))

# 1. DỮ LIỆU: GARCH dùng log return dạng thập phân, không dùng mức giá close.
df <- readr::read_csv(CLEAN_DATA_PATH, show_col_types = FALSE)
assert_columns(df, c("date", "return"), "Dữ liệu GARCH")

df_valid <- df %>%
  transmute(date = as.Date(date), return = as.numeric(return)) %>%
  filter(!is.na(date), is.finite(return))
returns <- df_valid$return

message(
  "GARCH input: ", length(returns), " returns from ",
  min(df_valid$date), " to ", max(df_valid$date)
)

# 2. BỐN MODEL: cùng sample và ARMA(0,0), chỉ khác variance/distribution.
model_specs <- tibble::tribble(
  ~model, ~variance_model, ~distribution,
  "sGARCH-Normal", "sGARCH", "norm",
  "sGARCH-Student-t", "sGARCH", "std",
  "eGARCH-Student-t", "eGARCH", "std",
  "gjrGARCH-Student-t", "gjrGARCH", "std"
)

#' Tạo specification và fit một GARCH(1,1)
#'
#' @param variance_model Tên variance model mà `rugarch` hỗ trợ.
#' @param distribution Tên innovation distribution (`norm` hoặc `std`).
#' @return Một object `uGARCHfit` chứa tham số, residual và volatility.
#' @details Mọi model dùng cùng vector `returns`, ARMA(0,0) và hybrid solver.
fit_one_garch <- function(variance_model, distribution) {
  spec <- rugarch::ugarchspec(
    variance.model = list(model = variance_model, garchOrder = c(1, 1)),
    mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
    distribution.model = distribution
  )
  rugarch::ugarchfit(spec, returns, solver = "hybrid")
}

fits <- purrr::pmap(
  model_specs,
  function(model, variance_model, distribution) {
    message("Fitting ", model, "...")
    fit_one_garch(variance_model, distribution)
  }
) %>% rlang::set_names(model_specs$model)

# 3. BẢNG FIT VÀ THAM SỐ.
garch_comparison <- purrr::pmap_dfr(
  c(model_specs, list(fit = unname(fits))),
  function(model, variance_model, distribution, fit) {
    criteria <- rugarch::infocriteria(fit)
    tibble(
      model, variance_model, distribution,
      status = if_else(fit@fit$convergence == 0, "converged", "not_converged"),
      convergence = as.integer(fit@fit$convergence),
      log_likelihood = as.numeric(rugarch::likelihood(fit)),
      aic = as.numeric(criteria[1]),
      bic = as.numeric(criteria[2]),
      persistence = as.numeric(fit@fit$persistence),
      error = NA_character_
    )
  }
) %>% arrange(aic)

garch_parameters <- purrr::imap_dfr(fits, function(fit, model) {
  conventional <- fit@fit$matcoef
  robust <- fit@fit$robust.matcoef
  tibble(
    model,
    parameter = rownames(conventional),
    estimate = conventional[, 1],
    std_error = conventional[, 2],
    p_value = conventional[, 4],
    robust_std_error = robust[, 2],
    robust_p_value = robust[, 4]
  )
})

#' Tính standardized residual z_t = epsilon_t / sigma_t
#'
#' @param fit Một object `uGARCHfit` đã hội tụ.
#' @return Numeric vector có cùng độ dài với chuỗi return.
standardized_residuals <- function(fit) {
  as.numeric(fit@fit$residuals) / as.numeric(fit@fit$sigma)
}

#' Tạo một hàng diagnostic theo schema chung
#'
#' @param model Tên model.
#' @param category Nhóm kiểm định, ví dụ `remaining_arch`.
#' @param test Tên kiểm định cụ thể.
#' @param lag Lag của kiểm định; `NA` nếu không áp dụng.
#' @param statistic Test statistic.
#' @param p_value P-value; `NA` với kiểm định dùng critical value.
#' @param critical_5pct Critical value tại mức 5%.
#' @param result Kết luận dạng machine-readable.
#' @return Tibble một hàng với đúng schema của `garch_diagnostics.csv`.
diagnostic_row <- function(
  model, category, test, lag = NA_integer_, statistic = NA_real_,
  p_value = NA_real_, critical_5pct = NA_real_, result = NA_character_
) {
  tibble(
    model, category, test,
    lag = as.integer(lag),
    statistic = as.numeric(statistic),
    p_value = as.numeric(p_value),
    critical_5pct = as.numeric(critical_5pct),
    result
  )
}

#' Chuyển p-value diagnostic thành nhãn đạt/cảnh báo
#'
#' @param p P-value của kiểm định có H0 là “không còn vấn đề”.
#' @param pass Nhãn khi chưa bác bỏ H0 (`p >= 0.05`).
#' @param flag Nhãn khi bác bỏ H0 (`p < 0.05`).
#' @return Một character scalar.
pass_or_flag <- function(p, pass, flag) if (p >= 0.05) pass else flag

#' Chạy toàn bộ post-fit diagnostics cho một GARCH model
#'
#' @param fit Một object `uGARCHfit` đã hội tụ.
#' @param model Tên model dùng trong output.
#' @return Tibble dạng dài gồm Ljung-Box, ARCH-LM, sign-bias, Nyblom và GOF.
#' @details Hàm giả định các diagnostic của `rugarch` chạy thành công; nếu không,
#'   pipeline dừng để lỗi không bị che giấu.
diagnose_one_garch <- function(fit, model) {
  z <- standardized_residuals(fit)
  lb <- Box.test(z, lag = 20, type = "Ljung-Box", fitdf = 0)
  lb2 <- Box.test(z^2, lag = 20, type = "Ljung-Box", fitdf = 0)
  arch <- FinTS::ArchTest(z, lags = 12)
  sign <- rugarch::signbias(fit)
  stability <- rugarch::nyblom(fit)
  pearson <- rugarch::gof(fit, groups = c(20, 30, 40, 50))

  rows <- list(
    diagnostic_row(
      model, "serial_correlation", "Ljung-Box standardized residuals", 20,
      unname(lb$statistic), lb$p.value,
      result = pass_or_flag(lb$p.value, "no_serial_correlation_detected",
                            "serial_correlation_flagged")
    ),
    diagnostic_row(
      model, "variance_dependence", "Ljung-Box squared standardized residuals", 20,
      unname(lb2$statistic), lb2$p.value,
      result = pass_or_flag(lb2$p.value, "no_squared_residual_dependence_detected",
                            "squared_residual_dependence_flagged")
    ),
    diagnostic_row(
      model, "remaining_arch", "ARCH-LM standardized residuals", 12,
      unname(arch$statistic), arch$p.value,
      result = pass_or_flag(arch$p.value, "no_remaining_arch_detected",
                            "remaining_arch_flagged")
    )
  )

  # Bốn dòng sign-bias: Sign, Negative, Positive và Joint Effect.
  rows <- c(rows, lapply(seq_len(nrow(sign)), function(i) {
    p <- as.numeric(sign[i, "prob"])
    diagnostic_row(
      model, "asymmetry", rownames(sign)[i],
      statistic = sign[i, "t-value"], p_value = p,
      result = pass_or_flag(p, "no_sign_bias_detected", "sign_bias_flagged")
    )
  }))

  # Một dòng Nyblom joint và một dòng cho từng parameter.
  joint_critical <- unname(stability$JointCritical["5%"])
  rows[[length(rows) + 1]] <- diagnostic_row(
    model, "parameter_stability", "Nyblom joint stability",
    statistic = stability$JointStat, critical_5pct = joint_critical,
    result = if_else(stability$JointStat <= joint_critical,
                     "parameters_stable_at_5pct", "parameter_instability_flagged")
  )

  individual_critical <- unname(stability$IndividualCritical["5%"])
  individual <- stability$IndividualStat[, 1]
  rows <- c(rows, lapply(seq_along(individual), function(i) {
    diagnostic_row(
      model, "parameter_stability", paste("Nyblom", rownames(stability$IndividualStat)[i]),
      statistic = individual[i], critical_5pct = individual_critical,
      result = if_else(individual[i] <= individual_critical,
                       "parameter_stable_at_5pct", "parameter_instability_flagged")
    )
  }))

  # Bốn nhóm adjusted Pearson GOF: 20, 30, 40 và 50.
  rows <- c(rows, lapply(seq_len(nrow(pearson)), function(i) {
    group <- as.integer(pearson[i, "group"])
    p <- as.numeric(pearson[i, "p-value(g-1)"])
    diagnostic_row(
      model, "distribution_fit", paste("Adjusted Pearson group", group),
      statistic = pearson[i, "statistic"], p_value = p,
      result = pass_or_flag(p, "distribution_not_rejected_at_5pct",
                            "distribution_fit_flagged")
    )
  }))

  bind_rows(rows)
}

# 4. ARCH-LM TRƯỚC FIT VÀ DIAGNOSTICS SAU FIT.
pre_arch <- FinTS::ArchTest(returns, lags = 12)
pre_arch_row <- diagnostic_row(
  "Raw return", "pre_fit_arch", "ARCH-LM raw return", 12,
  unname(pre_arch$statistic), pre_arch$p.value,
  result = if_else(pre_arch$p.value < 0.05,
                   "arch_effect_detected", "no_arch_effect_detected")
)

garch_diagnostics <- bind_rows(
  pre_arch_row,
  purrr::imap_dfr(fits, diagnose_one_garch)
)

diagnostic_summary <- purrr::imap_dfr(fits, function(fit, model_name) {
  tests <- filter(garch_diagnostics, .data$model == .env$model_name)
  # Lấy đúng một ô từ bảng diagnostics theo tên test và tên cột.
  value <- function(test, column) tests[[column]][match(test, tests$test)]
  tibble(
    model = model_name,
    convergence = fit@fit$convergence,
    persistence = garch_comparison$persistence[match(model_name, garch_comparison$model)],
    ljung_box_residual_p = value("Ljung-Box standardized residuals", "p_value"),
    ljung_box_squared_p = value("Ljung-Box squared standardized residuals", "p_value"),
    arch_lm_p = value("ARCH-LM standardized residuals", "p_value"),
    sign_bias_joint_p = value("Joint Effect", "p_value"),
    nyblom_joint = value("Nyblom joint stability", "statistic"),
    nyblom_5pct_critical = value("Nyblom joint stability", "critical_5pct"),
    pearson_group20_p = value("Adjusted Pearson group 20", "p_value")
  )
})

# 5. XUẤT CÁC BẢNG CẦN CHO BÁO CÁO.
write_project_csv(garch_comparison, "garch_comparison.csv")
write_project_csv(garch_parameters, "garch_parameters.csv")
write_project_csv(garch_diagnostics, "garch_diagnostics.csv")
write_project_csv(diagnostic_summary, "garch_diagnostic_summary.csv")
saveRDS(fits, file.path(MODEL_DIR, "garch_fits.rds"))
saveRDS(fits[["sGARCH-Normal"]], file.path(MODEL_DIR, "garch_model.rds"))
saveRDS(fits[["eGARCH-Student-t"]], file.path(MODEL_DIR, "garch_candidate_model.rds"))

# 6. DỮ LIỆU PHỤC VỤ CÁC BIỂU ĐỒ.
volatility_long <- purrr::imap_dfr(fits, function(fit, model) {
  tibble(date = df_valid$date, volatility = as.numeric(fit@fit$sigma), model)
})

#' Chuyển kết quả ACF thành tibble để vẽ facet
#'
#' @param values Numeric vector cần tính ACF.
#' @param model Tên model dùng cho facet.
#' @param series Nhãn loại residual dùng cho facet.
#' @return Tibble gồm lag 1-40, ACF và biên white-noise xấp xỉ 95%.
acf_rows <- function(values, model, series) {
  result <- acf(values, lag.max = 40, plot = FALSE)
  tibble(
    model, series,
    lag = as.integer(result$lag),
    acf = as.numeric(result$acf),
    confidence = 1.96 / sqrt(length(values))
  ) %>% filter(lag > 0)
}

acf_data <- purrr::imap_dfr(fits, function(fit, model) {
  z <- standardized_residuals(fit)
  bind_rows(
    acf_rows(z, model, "Standardized residual"),
    acf_rows(z^2, model, "Squared standardized residual")
  )
})

news_impact_data <- purrr::map_dfr(
  c("eGARCH-Student-t", "gjrGARCH-Student-t"),
  function(model) {
    impact <- rugarch::newsimpact(fits[[model]])
    tibble(
      shock = as.numeric(impact$zx),
      conditional_variance = as.numeric(impact$zy),
      model
    )
  }
)

# 7. VẼ VÀ LƯU BA HÌNH GARCH ĐƯỢC DÙNG TRONG BÁO CÁO.
theme_garch <- theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, color = "grey35"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

#' Lưu một biểu đồ GARCH theo chuẩn chung
#'
#' @param filename Tên PNG trong `output/figures`.
#' @param plot Đối tượng ggplot.
#' @param width Chiều rộng tính bằng inch.
#' @param height Chiều cao tính bằng inch.
#' @return Kết quả vô hình từ `ggsave()`.
#' @details Side effect: ghi PNG 300 DPI, nền trắng.
save_plot <- function(filename, plot, width, height) {
  ggsave(file.path(FIGURE_DIR, filename), plot,
         width = width, height = height, dpi = 300, bg = "white")
}

p_comparison <- ggplot(volatility_long, aes(date, volatility, color = model)) +
  geom_line(linewidth = 0.45, alpha = 0.85) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = scales::label_percent(accuracy = 0.5)) +
  labs(
    title = "Conditional volatility across GARCH specifications",
    subtitle = "All models use the same FPT return sample",
    x = NULL, y = "Conditional volatility", color = "Model"
  ) + theme_garch
save_plot("garch_model_comparison.png", p_comparison, 11, 6.5)

p_acf <- ggplot(acf_data, aes(lag, acf)) +
  geom_ribbon(aes(ymin = -confidence, ymax = confidence),
              fill = "#90CAF9", alpha = 0.35) +
  geom_hline(yintercept = 0, color = "grey40") +
  geom_col(fill = "#1565C0", width = 0.65) +
  facet_grid(series ~ model, scales = "free_y") +
  labs(
    title = "ACF diagnostics for standardized GARCH residuals",
    subtitle = "Blue bands are approximate 95% white-noise bounds",
    x = "Lag", y = "ACF"
  ) + theme_garch +
  theme(axis.text.x = element_text(size = 7), strip.text = element_text(size = 8))
save_plot("garch_acf_diagnostics.png", p_acf, 14, 7.5)

p_news <- ggplot(news_impact_data, aes(shock, conditional_variance, color = model)) +
  geom_line(linewidth = 0.9) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey45") +
  facet_wrap(~model, scales = "free_y") +
  labs(
    title = "News-impact curves for asymmetric GARCH models",
    subtitle = "Compare equal-sized negative and positive standardized shocks",
    x = "Standardized shock", y = "Conditional variance", color = "Model"
  ) + theme_garch
save_plot("garch_news_impact.png", p_news, 11, 5.5)

print(garch_comparison)
message("Completed GARCH framework: 4/4 models fitted.")
message("Pre-fit ARCH-LM p-value: ", format(pre_arch$p.value, scientific = TRUE))
print(diagnostic_summary)