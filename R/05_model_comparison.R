# Ghép metric và diagnostics, nhưng giữ price forecast tách khỏi volatility.
source("R/00_config.R")

# Mỗi file này là output bắt buộc của script 03 hoặc 04.
input_files <- c(
  forecast = "forecast_metrics.csv",
  cv = "forecast_cv_metrics_summary.csv",
  forecast_diag = "forecast_diagnostics.csv",
  garch = "garch_comparison.csv",
  garch_diag = "garch_diagnostic_summary.csv"
)
input_paths <- rlang::set_names(file.path(TABLE_DIR, input_files), names(input_files))
if (any(!file.exists(input_paths))) {
  stop("Thiếu output: ", paste(names(input_paths)[!file.exists(input_paths)], collapse = ", "))
}
tables <- purrr::map(input_paths, readr::read_csv, show_col_types = FALSE)

# ARIMAX có nhãn dài ở bảng metric nhưng nhãn ngắn ở diagnostics; key nối phải đồng nhất.
model_key <- function(name) if_else(str_detect(name, regex("^ARIMAX", TRUE)), "ARIMAX", name)

# ----- Price forecast: holdout + rolling CV + residual diagnostics. -----
assert_columns(tables$forecast, c("model", "split", "rmse", "mae", "mape"), "Forecast")
assert_columns(tables$cv, c("model", "mean_rmse", "mean_mae", "mean_mape", "median_mape"), "CV")
assert_columns(tables$forecast_diag, c("model", "lb_p_value"), "Forecast diagnostics")

holdout <- tables$forecast %>% mutate(key = model_key(model))
cv <- tables$cv %>%
  mutate(key = model_key(model)) %>%
  transmute(key, cv_mean_rmse = mean_rmse, cv_mean_mae = mean_mae,
            cv_mean_mape = mean_mape, cv_median_mape = median_mape)
forecast_diag <- tables$forecast_diag %>%
  mutate(key = model_key(model)) %>%
  transmute(key, residual_ljung_box_statistic = lb_statistic,
            residual_ljung_box_p = lb_p_value, residual_white_noise = white_noise)

# Naive là benchmark chung để đánh giá model phức tạp có cải thiện thật hay không.
naive_holdout <- holdout$rmse[holdout$key == "Naive"]
naive_cv <- cv$cv_mean_rmse[cv$key == "Naive"]
if (length(naive_holdout) != 1 || length(naive_cv) != 1) stop("Cần đúng một Naive benchmark.")

price_comparison <- holdout %>%
  left_join(cv, by = "key") %>%
  left_join(forecast_diag, by = "key") %>%
  mutate(
    final_rmse_rank = min_rank(rmse),
    cv_rmse_rank = min_rank(cv_mean_rmse),
    beats_naive_final = rmse < naive_holdout,
    beats_naive_cv = if_else(is.na(cv_mean_rmse), NA, cv_mean_rmse < naive_cv),
    residual_diagnostic_pass = if_else(is.na(residual_ljung_box_p), NA,
                                       residual_ljung_box_p >= 0.05),
    evidence_assessment = case_when(
      key %in% c("Naive", "Drift") ~ "Benchmark",
      is.na(cv_mean_rmse) ~ "Holdout result available; rolling CV not available",
      beats_naive_final & beats_naive_cv & residual_diagnostic_pass ~
        "Consistent improvement over Naive with acceptable residual diagnostics",
      TRUE ~ "Mixed evidence across holdout, rolling CV, or residual diagnostics"
    )
  ) %>%
  select(-key) %>%
  arrange(final_rmse_rank, model)

# ----- Volatility: fit + residual checks + stability + distribution fit. -----
assert_columns(tables$garch, c("model", "convergence", "aic", "bic", "persistence"), "GARCH")
assert_columns(
  tables$garch_diag,
  c("model", "ljung_box_residual_p", "ljung_box_squared_p", "arch_lm_p",
    "sign_bias_joint_p", "nyblom_joint", "nyblom_5pct_critical", "pearson_group20_p"),
  "GARCH diagnostics"
)

volatility_comparison <- tables$garch %>%
  left_join(select(tables$garch_diag, -any_of(c("convergence", "persistence"))), by = "model") %>%
  mutate(
    aic_rank = min_rank(aic),
    delta_aic = aic - min(aic, na.rm = TRUE),
    core_diagnostics_pass = convergence == 0 & ljung_box_residual_p >= 0.05 &
      ljung_box_squared_p >= 0.05 & arch_lm_p >= 0.05,
    sign_bias_pass = sign_bias_joint_p >= 0.05,
    parameter_stability_pass = nyblom_joint <= nyblom_5pct_critical,
    distribution_fit_pass = pearson_group20_p >= 0.05,
    persistence_warning = persistence >= 0.995
  )

# Candidate phải qua core diagnostics và stability; AIC chỉ xếp hạng trong nhóm đó.
eligible <- filter(volatility_comparison, core_diagnostics_pass, parameter_stability_pass)
candidate <- if (nrow(eligible)) eligible$model[which.min(eligible$aic)] else NA_character_
volatility_comparison <- volatility_comparison %>%
  mutate(
    provisional_candidate = !is.na(candidate) & model == candidate,
    evidence_assessment = case_when(
      convergence != 0 ~ "Model did not converge",
      !core_diagnostics_pass ~ "Residual dynamics remain after fitting",
      !parameter_stability_pass ~ "Core diagnostics pass, but parameter stability is rejected",
      !distribution_fit_pass ~ "Core diagnostics and joint stability pass; distribution GOF remains a limitation",
      TRUE ~ "Core diagnostics, stability, and distribution checks pass"
    )
  ) %>%
  arrange(aic_rank, model)

# Overview chỉ tóm tắt; tuyệt đối không xếp price model cạnh GARCH trên một thang điểm.
holdout_leader <- price_comparison$model[which.min(price_comparison$rmse)]
cv_leader <- filter(price_comparison, !is.na(cv_mean_rmse)) %>% slice_min(cv_mean_rmse) %>% pull(model)
overview <- tibble(
  analysis = c("Price forecast", "Conditional volatility"),
  provisional_conclusion = c(
    paste0("Holdout leader: ", holdout_leader,
           "; rolling-CV leader among evaluated models: ", cv_leader),
    if_else(is.na(candidate), "No eligible volatility model",
            paste0("Balanced candidate: ", candidate))
  ),
  limitation = c(
    "Holdout and rolling-CV evidence do not identify one universal winner",
    "Distribution fit remains a limitation"
  )
)

# Ba CSV này là input trực tiếp cho report.Rmd và workbook cuối.
write_project_csv(price_comparison, "price_forecast_comparison.csv")
write_project_csv(volatility_comparison, "volatility_model_comparison.csv")
write_project_csv(overview, "model_comparison.csv")
message("Đã xuất comparison riêng cho forecast và volatility.")
