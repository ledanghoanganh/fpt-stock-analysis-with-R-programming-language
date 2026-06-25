source("R/00_config.R")
require_packages(c("rugarch", "FinTS", "scales"))

if (!file.exists(CLEAN_DATA_PATH)) {
  stop("Không tìm thấy dữ liệu sạch: ", CLEAN_DATA_PATH)
}

df <- readr::read_csv(CLEAN_DATA_PATH, show_col_types = FALSE)
assert_columns(df, c("date", "return"), "Dữ liệu GARCH")

df$date <- as.Date(df$date)
valid_rows <- is.finite(df$return) & !is.na(df$date)
df_valid <- df[valid_rows, c("date", "return")]
returns <- as.numeric(df_valid$return)

if (length(returns) < 500) stop("Không đủ return hợp lệ để fit GARCH")
if (!isTRUE(all(diff(df_valid$date) >= 0))) stop("Dữ liệu chưa được sắp xếp theo ngày")
if (!is.finite(stats::sd(returns)) || stats::sd(returns) == 0) {
  stop("Chuỗi return không có độ biến động hợp lệ")
}

message(
  "GARCH input: ", length(returns), " returns from ",
  min(df_valid$date), " to ", max(df_valid$date)
)

model_specs <- tibble::tribble(
  ~model_name, ~variance_model, ~distribution,
  "sGARCH-Normal", "sGARCH", "norm",
  "sGARCH-Student-t", "sGARCH", "std",
  "eGARCH-Student-t", "eGARCH", "std",
  "gjrGARCH-Student-t", "gjrGARCH", "std"
)

fit_garch_model <- function(returns, variance_model, distribution) {
  specification <- rugarch::ugarchspec(
    variance.model = list(
      model = variance_model,
      garchOrder = c(1, 1)
    ),
    mean.model = list(
      armaOrder = c(0, 0),
      include.mean = TRUE
    ),
    distribution.model = distribution
  )

  rugarch::ugarchfit(
    spec = specification,
    data = returns,
    solver = "hybrid"
  )
}

safe_fit_garch <- function(returns, variance_model, distribution) {
  tryCatch(
    list(
      fit = fit_garch_model(returns, variance_model, distribution),
      error = NA_character_
    ),
    error = function(error) {
      list(fit = NULL, error = conditionMessage(error))
    }
  )
}

extract_comparison_row <- function(result, model_name, variance_model, distribution) {
  if (is.null(result$fit)) {
    return(tibble::tibble(
      model = model_name,
      variance_model = variance_model,
      distribution = distribution,
      status = "failed",
      convergence = NA_integer_,
      log_likelihood = NA_real_,
      aic = NA_real_,
      bic = NA_real_,
      persistence = NA_real_,
      error = result$error
    ))
  }

  fit <- result$fit
  criteria <- rugarch::infocriteria(fit)
  tibble::tibble(
    model = model_name,
    variance_model = variance_model,
    distribution = distribution,
    status = if (fit@fit$convergence == 0) "converged" else "not_converged",
    convergence = as.integer(fit@fit$convergence),
    log_likelihood = as.numeric(rugarch::likelihood(fit)),
    aic = as.numeric(criteria[1]),
    bic = as.numeric(criteria[2]),
    persistence = as.numeric(fit@fit$persistence),
    error = NA_character_
  )
}

extract_parameter_rows <- function(fit, model_name) {
  conventional <- fit@fit$matcoef
  robust <- fit@fit$robust.matcoef

  tibble::tibble(
    model = model_name,
    parameter = rownames(conventional),
    estimate = as.numeric(conventional[, 1]),
    std_error = as.numeric(conventional[, 2]),
    p_value = as.numeric(conventional[, 4]),
    robust_std_error = as.numeric(robust[, 2]),
    robust_p_value = as.numeric(robust[, 4])
  )
}

standardized_residuals <- function(fit) {
  residual_values <- as.numeric(fit@fit$residuals)
  sigma_values <- as.numeric(fit@fit$sigma)
  values <- residual_values / sigma_values
  values[is.finite(values)]
}

diagnostic_row <- function(
  model, category, test, lag = NA_integer_, statistic = NA_real_,
  p_value = NA_real_, critical_5pct = NA_real_, result = NA_character_
) {
  tibble::tibble(
    model = model,
    category = category,
    test = test,
    lag = as.integer(lag),
    statistic = as.numeric(statistic),
    p_value = as.numeric(p_value),
    critical_5pct = as.numeric(critical_5pct),
    result = result
  )
}

p_value_result <- function(p_value, pass_text, flag_text) {
  if (!is.finite(p_value)) {
    return("not_available")
  }
  if (p_value >= 0.05) pass_text else flag_text
}

diagnose_garch_model <- function(fit, model_name) {
  z <- standardized_residuals(fit)

  lb_return <- stats::Box.test(z, lag = 20, type = "Ljung-Box", fitdf = 0)
  lb_squared <- stats::Box.test(z^2, lag = 20, type = "Ljung-Box", fitdf = 0)
  arch_after <- FinTS::ArchTest(z, lags = 12)

  rows <- list(
    diagnostic_row(
      model_name, "serial_correlation", "Ljung-Box standardized residuals",
      lag = 20, statistic = unname(lb_return$statistic), p_value = lb_return$p.value,
      result = p_value_result(
        lb_return$p.value,
        "no_serial_correlation_detected",
        "serial_correlation_flagged"
      )
    ),
    diagnostic_row(
      model_name, "variance_dependence", "Ljung-Box squared standardized residuals",
      lag = 20, statistic = unname(lb_squared$statistic), p_value = lb_squared$p.value,
      result = p_value_result(
        lb_squared$p.value,
        "no_squared_residual_dependence_detected",
        "squared_residual_dependence_flagged"
      )
    ),
    diagnostic_row(
      model_name, "remaining_arch", "ARCH-LM standardized residuals",
      lag = 12, statistic = unname(arch_after$statistic), p_value = arch_after$p.value,
      result = p_value_result(
        arch_after$p.value,
        "no_remaining_arch_detected",
        "remaining_arch_flagged"
      )
    )
  )

  sign_bias <- tryCatch(rugarch::signbias(fit), error = function(error) NULL)
  if (!is.null(sign_bias)) {
    for (index in seq_len(nrow(sign_bias))) {
      test_name <- rownames(sign_bias)[index]
      test_p <- as.numeric(sign_bias[index, "prob"])
      rows[[length(rows) + 1]] <- diagnostic_row(
        model_name, "asymmetry", test_name,
        statistic = as.numeric(sign_bias[index, "t-value"]),
        p_value = test_p,
        result = p_value_result(
          test_p,
          "no_sign_bias_detected",
          "sign_bias_flagged"
        )
      )
    }
  }

  stability <- tryCatch(rugarch::nyblom(fit), error = function(error) NULL)
  if (!is.null(stability)) {
    joint_critical <- unname(stability$JointCritical["5%"])
    rows[[length(rows) + 1]] <- diagnostic_row(
      model_name, "parameter_stability", "Nyblom joint stability",
      statistic = stability$JointStat,
      critical_5pct = joint_critical,
      result = if (stability$JointStat <= joint_critical) {
        "parameters_stable_at_5pct"
      } else {
        "parameter_instability_flagged"
      }
    )

    individual_critical <- unname(stability$IndividualCritical["5%"])
    individual_stats <- as.numeric(stability$IndividualStat[, 1])
    names(individual_stats) <- rownames(stability$IndividualStat)
    for (parameter in names(individual_stats)) {
      rows[[length(rows) + 1]] <- diagnostic_row(
        model_name, "parameter_stability", paste("Nyblom", parameter),
        statistic = individual_stats[[parameter]],
        critical_5pct = individual_critical,
        result = if (individual_stats[[parameter]] <= individual_critical) {
          "parameter_stable_at_5pct"
        } else {
          "parameter_instability_flagged"
        }
      )
    }
  }

  goodness_of_fit <- tryCatch(
    rugarch::gof(fit, groups = c(20, 30, 40, 50)),
    error = function(error) NULL
  )
  if (!is.null(goodness_of_fit)) {
    for (index in seq_len(nrow(goodness_of_fit))) {
      group <- as.integer(goodness_of_fit[index, "group"])
      test_p <- as.numeric(goodness_of_fit[index, "p-value(g-1)"])
      rows[[length(rows) + 1]] <- diagnostic_row(
        model_name, "distribution_fit", paste("Adjusted Pearson group", group),
        statistic = as.numeric(goodness_of_fit[index, "statistic"]),
        p_value = test_p,
        result = p_value_result(
          test_p,
          "distribution_not_rejected_at_5pct",
          "distribution_fit_flagged"
        )
      )
    }
  }

  dplyr::bind_rows(rows)
}

acf_rows <- function(values, model_name, series_name, lag_max = 40) {
  acf_result <- stats::acf(values, lag.max = lag_max, plot = FALSE, na.action = na.pass)
  tibble::tibble(
    model = model_name,
    series = series_name,
    lag = as.integer(acf_result$lag),
    acf = as.numeric(acf_result$acf),
    confidence = 1.96 / sqrt(length(values))
  ) %>%
    dplyr::filter(lag > 0)
}

fit_results <- purrr::pmap(
  model_specs,
  function(model_name, variance_model, distribution) {
    message("Fitting ", model_name, "...")
    safe_fit_garch(returns, variance_model, distribution)
  }
) %>% rlang::set_names(model_specs$model_name)

comparison_rows <- purrr::pmap(
  c(model_specs, list(result = unname(fit_results))),
  function(model_name, variance_model, distribution, result) {
    extract_comparison_row(result, model_name, variance_model, distribution)
  }
)
garch_comparison <- bind_rows(comparison_rows) %>%
  dplyr::arrange(is.na(aic), aic)

successful_fits <- purrr::map(fit_results, "fit") %>% purrr::compact()

if (length(successful_fits) == 0) {
  readr::write_csv(garch_comparison, file.path(TABLE_DIR, "garch_comparison.csv"))
  stop("Không có GARCH model nào fit thành công")
}

parameter_rows <- purrr::imap(successful_fits, extract_parameter_rows)
garch_parameters <- dplyr::bind_rows(parameter_rows)

# test ARCH
pre_arch <- FinTS::ArchTest(returns, lags = 12)
pre_arch_row <- diagnostic_row(
  model = "Raw return",
  category = "pre_fit_arch",
  test = "ARCH-LM raw return",
  lag = 12,
  statistic = unname(pre_arch$statistic),
  p_value = pre_arch$p.value,
  result = if (pre_arch$p.value < 0.05) {
    "arch_effect_detected"
  } else {
    "no_arch_effect_detected"
  }
)

model_diagnostic_rows <- purrr::imap(successful_fits, diagnose_garch_model)
garch_diagnostics <- dplyr::bind_rows(
  pre_arch_row,
  dplyr::bind_rows(model_diagnostic_rows)
)

extract_test_value <- function(data, test_name, column) {
  values <- data[data$test == test_name, column, drop = TRUE]
  if (length(values) == 0) {
    return(NA_real_)
  }
  as.numeric(values[1])
}

diagnostic_summary_rows <- purrr::imap_dfr(successful_fits, function(fit, model_name) {
  model_tests <- garch_diagnostics %>% dplyr::filter(model == model_name)
  comparison <- garch_comparison %>% dplyr::filter(model == model_name)
  tibble::tibble(
    model = model_name,
    convergence = fit@fit$convergence,
    persistence = comparison$persistence[1],
    ljung_box_residual_p = extract_test_value(
      model_tests, "Ljung-Box standardized residuals", "p_value"
    ),
    ljung_box_squared_p = extract_test_value(
      model_tests, "Ljung-Box squared standardized residuals", "p_value"
    ),
    arch_lm_p = extract_test_value(
      model_tests, "ARCH-LM standardized residuals", "p_value"
    ),
    sign_bias_joint_p = extract_test_value(model_tests, "Joint Effect", "p_value"),
    nyblom_joint = extract_test_value(model_tests, "Nyblom joint stability", "statistic"),
    nyblom_5pct_critical = extract_test_value(
      model_tests, "Nyblom joint stability", "critical_5pct"
    ),
    pearson_group20_p = extract_test_value(
      model_tests, "Adjusted Pearson group 20", "p_value"
    )
  )
})

acf_data <- purrr::imap_dfr(successful_fits, function(fit, model_name) {
  z <- standardized_residuals(fit)
  dplyr::bind_rows(
    acf_rows(z, model_name, "Standardized residual"),
    acf_rows(z^2, model_name, "Squared standardized residual")
  )
})

qq_data <- purrr::imap_dfr(successful_fits, function(fit, model_name) {
  tibble::tibble(
    model = model_name,
    standardized_residual = standardized_residuals(fit)
  )
})

write_project_csv(garch_comparison, "garch_comparison.csv")
write_project_csv(garch_parameters, "garch_parameters.csv")
write_project_csv(garch_diagnostics, "garch_diagnostics.csv")
write_project_csv(diagnostic_summary_rows, "garch_diagnostic_summary.csv")
saveRDS(successful_fits, file.path(MODEL_DIR, "garch_fits.rds"))

print(garch_comparison)

base_name <- "sGARCH-Normal"
if (!base_name %in% names(successful_fits)) {
  stop("Base sGARCH-Normal failed; legacy outputs cannot be produced")
}

base_fit <- successful_fits[[base_name]]
saveRDS(base_fit, file.path(MODEL_DIR, "garch_model.rds"))

base_parameters <- garch_parameters %>%
  dplyr::filter(model == base_name) %>%
  dplyr::transmute(
    Parameter = parameter,
    Estimate = estimate,
    StdError = std_error,
    t_value = Estimate / StdError,
    Pr_z = p_value
  )

base_info <- tibble::tibble(
  Parameter = c("Log-Likelihood", "AIC", "BIC"),
  Estimate = c(
    rugarch::likelihood(base_fit),
    rugarch::infocriteria(base_fit)[1],
    rugarch::infocriteria(base_fit)[2]
  ),
  StdError = NA_real_,
  t_value = NA_real_,
  Pr_z = NA_real_
)

garch_summary <- dplyr::bind_rows(base_parameters, base_info)
write_project_csv(garch_summary, "garch_summary.csv")

base_volatility <- as.numeric(base_fit@fit$sigma)
vol_df <- tibble::tibble(
  date = df_valid$date,
  return = returns,
  volatility = base_volatility
)
write_project_csv(vol_df, "garch_volatility.csv")

theme_garch <- ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
    plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "grey35"),
    legend.position = "bottom",
    panel.grid.minor = ggplot2::element_blank()
  )

save_garch_plot <- function(filename, plot, width, height) {
  ggplot2::ggsave(file.path(FIGURE_DIR, filename), plot,
    width = width,
    height = height, dpi = 300, bg = "white"
  )
}

p_base <- ggplot2::ggplot(vol_df, ggplot2::aes(date)) +
  ggplot2::geom_line(ggplot2::aes(y = return), color = "grey70", linewidth = 0.3) +
  ggplot2::geom_line(ggplot2::aes(y = volatility), color = "#C62828", linewidth = 0.55) +
  ggplot2::geom_line(ggplot2::aes(y = -volatility), color = "#C62828", linewidth = 0.55) +
  ggplot2::scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ggplot2::scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
  ggplot2::labs(
    title = "FPT returns and sGARCH(1,1)-Normal volatility",
    subtitle = "Red lines are +/- one conditional standard deviation, not a 95% interval",
    x = NULL,
    y = "Return / conditional volatility"
  ) +
  theme_garch

save_garch_plot("garch_volatility.png", p_base, 11, 6.5)

volatility_long <- purrr::imap_dfr(successful_fits, function(fit, model_name) {
  tibble::tibble(
    date = df_valid$date,
    volatility = as.numeric(fit@fit$sigma),
    model = model_name
  )
})

p_comparison <- ggplot2::ggplot(
  volatility_long,
  ggplot2::aes(date, volatility, color = model)
) +
  ggplot2::geom_line(linewidth = 0.45, alpha = 0.85) +
  ggplot2::scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  ggplot2::scale_y_continuous(labels = scales::label_percent(accuracy = 0.5)) +
  ggplot2::labs(
    title = "Conditional volatility across GARCH specifications",
    subtitle = "All models use the same FPT return sample",
    x = NULL,
    y = "Conditional volatility",
    color = "Model"
  ) +
  theme_garch

save_garch_plot("garch_model_comparison.png", p_comparison, 11, 6.5)

p_acf <- ggplot2::ggplot(acf_data, ggplot2::aes(lag, acf)) +
  ggplot2::geom_ribbon(
    ggplot2::aes(ymin = -confidence, ymax = confidence),
    fill = "#90CAF9", alpha = 0.35
  ) +
  ggplot2::geom_hline(yintercept = 0, color = "grey40") +
  ggplot2::geom_col(fill = "#1565C0", width = 0.65) +
  ggplot2::facet_grid(series ~ model, scales = "free_y") +
  ggplot2::labs(
    title = "ACF diagnostics for standardized GARCH residuals",
    subtitle = "Blue bands are approximate 95% white-noise bounds",
    x = "Lag",
    y = "ACF"
  ) +
  theme_garch +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(size = 7),
    strip.text = ggplot2::element_text(size = 8)
  )

save_garch_plot("garch_acf_diagnostics.png", p_acf, 14, 7.5)

p_qq <- ggplot2::ggplot(
  qq_data,
  ggplot2::aes(sample = standardized_residual)
) +
  ggplot2::stat_qq(alpha = 0.35, size = 0.7, color = "#1565C0") +
  ggplot2::stat_qq_line(color = "#C62828", linewidth = 0.6) +
  ggplot2::facet_wrap(~model, scales = "free", ncol = 2) +
  ggplot2::labs(
    title = "Normal-reference Q-Q plots of standardized residuals",
    subtitle = "Descriptive tail check; Student-t models are not expected to follow a Normal line exactly",
    x = "Theoretical Normal quantile",
    y = "Sample quantile"
  ) +
  theme_garch

save_garch_plot("garch_qq_diagnostics.png", p_qq, 11, 8)

asymmetric_names <- intersect(
  c("eGARCH-Student-t", "gjrGARCH-Student-t"),
  names(successful_fits)
)
news_impact_data <- purrr::map_dfr(asymmetric_names, function(model_name) {
  impact <- tryCatch(
    rugarch::newsimpact(successful_fits[[model_name]]),
    error = function(error) NULL
  )
  if (is.null(impact)) {
    return(tibble::tibble())
  }
  tibble::tibble(
    shock = as.numeric(impact$zx),
    conditional_variance = as.numeric(impact$zy),
    model = model_name
  )
})

if (nrow(news_impact_data) > 0) {
  p_news <- ggplot2::ggplot(
    news_impact_data,
    ggplot2::aes(shock, conditional_variance, color = model)
  ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey45") +
    ggplot2::facet_wrap(~model, scales = "free_y") +
    ggplot2::labs(
      title = "News-impact curves for asymmetric GARCH models",
      subtitle = "Compare equal-sized negative and positive standardized shocks",
      x = "Standardized shock",
      y = "Conditional variance",
      color = "Model"
    ) +
    theme_garch

  save_garch_plot("garch_news_impact.png", p_news, 11, 5.5)
}

message(
  "Completed GARCH framework: ", length(successful_fits), "/",
  nrow(model_specs), " models fitted."
)
message("Pre-fit ARCH-LM p-value: ", format(pre_arch$p.value, scientific = TRUE))
print(diagnostic_summary_rows)
