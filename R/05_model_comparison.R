# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 05_model_comparison.R
# PURPOSE: Compare price-forecast and volatility models in separate tables
# ==============================================================================

source("R/00_config.R")

required_packages <- c("dplyr", "readr", "stringr", "tibble")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop("Thiếu package: ", paste(missing_packages, collapse = ", "))
}

required_files <- c(
  forecast_metrics = file.path(TABLE_DIR, "forecast_metrics.csv"),
  forecast_cv = file.path(TABLE_DIR, "forecast_cv_metrics_summary.csv"),
  forecast_diagnostics = file.path(TABLE_DIR, "forecast_diagnostics.csv"),
  garch_comparison = file.path(TABLE_DIR, "garch_comparison.csv"),
  garch_diagnostics = file.path(TABLE_DIR, "garch_diagnostic_summary.csv")
)

missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop(
    "Thiếu output đầu vào: ",
    paste(names(missing_files), missing_files, sep = "=", collapse = ", "),
    ". Hãy chạy R/03_stationarity_arima_ets.R và R/04_garch_volatility.R trước."
  )
}

normalize_forecast_model <- function(model) {
  dplyr::case_when(
    stringr::str_detect(model, stringr::regex("^ARIMAX", ignore_case = TRUE)) ~ "ARIMAX",
    TRUE ~ model
  )
}

assert_columns <- function(data, required, data_name) {
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop(data_name, " thiếu cột: ", paste(missing, collapse = ", "))
  }
}

# 1. PRICE-FORECAST COMPARISON -------------------------------------------------
forecast_metrics <- readr::read_csv(required_files[["forecast_metrics"]], show_col_types = FALSE)
forecast_cv <- readr::read_csv(required_files[["forecast_cv"]], show_col_types = FALSE)
forecast_diagnostics <- readr::read_csv(
  required_files[["forecast_diagnostics"]], show_col_types = FALSE
)

assert_columns(
  forecast_metrics,
  c("model", "split", "rmse", "mae", "mape"),
  "forecast_metrics.csv"
)
assert_columns(
  forecast_cv,
  c("model", "mean_rmse", "mean_mae", "mean_mape", "median_mape"),
  "forecast_cv_metrics_summary.csv"
)
assert_columns(
  forecast_diagnostics,
  c("model", "lb_statistic", "lb_p_value", "white_noise"),
  "forecast_diagnostics.csv"
)

forecast_metrics <- forecast_metrics %>%
  dplyr::mutate(model_key = normalize_forecast_model(model))

forecast_cv <- forecast_cv %>%
  dplyr::mutate(model_key = normalize_forecast_model(model)) %>%
  dplyr::select(
    model_key,
    cv_mean_rmse = mean_rmse,
    cv_mean_mae = mean_mae,
    cv_mean_mape = mean_mape,
    cv_median_mape = median_mape
  )

forecast_diagnostics <- forecast_diagnostics %>%
  dplyr::mutate(model_key = normalize_forecast_model(model)) %>%
  dplyr::select(
    model_key,
    residual_ljung_box_statistic = lb_statistic,
    residual_ljung_box_p = lb_p_value,
    residual_white_noise = white_noise
  )

naive_final_rmse <- forecast_metrics %>%
  dplyr::filter(model_key == "Naive") %>%
  dplyr::pull(rmse)
naive_cv_rmse <- forecast_cv %>%
  dplyr::filter(model_key == "Naive") %>%
  dplyr::pull(cv_mean_rmse)

if (length(naive_final_rmse) != 1 || length(naive_cv_rmse) != 1) {
  stop("Cần đúng một Naive benchmark trong holdout và CV summary")
}

price_forecast_comparison <- forecast_metrics %>%
  dplyr::left_join(forecast_cv, by = "model_key") %>%
  dplyr::left_join(forecast_diagnostics, by = "model_key") %>%
  dplyr::mutate(
    final_rmse_rank = dplyr::min_rank(rmse),
    cv_rmse_rank = dplyr::min_rank(cv_mean_rmse),
    beats_naive_final = rmse < naive_final_rmse,
    beats_naive_cv = dplyr::if_else(
      is.na(cv_mean_rmse),
      NA,
      cv_mean_rmse < naive_cv_rmse
    ),
    residual_diagnostic_pass = dplyr::if_else(
      is.na(residual_ljung_box_p),
      NA,
      residual_ljung_box_p >= 0.05
    ),
    evidence_assessment = dplyr::case_when(
      model_key %in% c("Naive", "Drift") ~ "Benchmark",
      is.na(cv_mean_rmse) ~ "Holdout result available; rolling CV not available",
      beats_naive_final & beats_naive_cv & residual_diagnostic_pass ~
        "Consistent improvement over Naive with acceptable residual diagnostics",
      TRUE ~ "Mixed evidence across holdout, rolling CV, or residual diagnostics"
    )
  ) %>%
  dplyr::select(
    model,
    split,
    rmse,
    mae,
    mape,
    final_rmse_rank,
    beats_naive_final,
    cv_mean_rmse,
    cv_mean_mae,
    cv_mean_mape,
    cv_median_mape,
    cv_rmse_rank,
    beats_naive_cv,
    residual_ljung_box_p,
    residual_diagnostic_pass,
    evidence_assessment
  ) %>%
  dplyr::arrange(final_rmse_rank, model)

# 2. VOLATILITY-MODEL COMPARISON ----------------------------------------------
garch_comparison <- readr::read_csv(
  required_files[["garch_comparison"]], show_col_types = FALSE
)
garch_diagnostics <- readr::read_csv(
  required_files[["garch_diagnostics"]], show_col_types = FALSE
)

assert_columns(
  garch_comparison,
  c(
    "model", "variance_model", "distribution", "status", "convergence",
    "log_likelihood", "aic", "bic", "persistence"
  ),
  "garch_comparison.csv"
)
assert_columns(
  garch_diagnostics,
  c(
    "model", "ljung_box_residual_p", "ljung_box_squared_p", "arch_lm_p",
    "sign_bias_joint_p", "nyblom_joint", "nyblom_5pct_critical",
    "pearson_group20_p"
  ),
  "garch_diagnostic_summary.csv"
)

volatility_model_comparison <- garch_comparison %>%
  dplyr::left_join(
    garch_diagnostics %>%
      dplyr::select(-dplyr::any_of(c("convergence", "persistence"))),
    by = "model"
  ) %>%
  dplyr::mutate(
    aic_rank = dplyr::min_rank(aic),
    delta_aic = aic - min(aic, na.rm = TRUE),
    core_diagnostics_pass =
      convergence == 0 &
      ljung_box_residual_p >= 0.05 &
      ljung_box_squared_p >= 0.05 &
      arch_lm_p >= 0.05,
    sign_bias_pass = sign_bias_joint_p >= 0.05,
    parameter_stability_pass = nyblom_joint <= nyblom_5pct_critical,
    distribution_fit_pass = pearson_group20_p >= 0.05,
    persistence_warning = persistence >= 0.995
  )

eligible_models <- volatility_model_comparison %>%
  dplyr::filter(core_diagnostics_pass, parameter_stability_pass)

provisional_model <- if (nrow(eligible_models) > 0) {
  eligible_models %>%
    dplyr::slice_min(aic, n = 1, with_ties = FALSE) %>%
    dplyr::pull(model)
} else {
  NA_character_
}

volatility_model_comparison <- volatility_model_comparison %>%
  dplyr::mutate(
    provisional_candidate = !is.na(provisional_model) & model == provisional_model,
    evidence_assessment = dplyr::case_when(
      convergence != 0 ~ "Model did not converge",
      !core_diagnostics_pass ~ "Residual dynamics remain after fitting",
      !parameter_stability_pass ~ "Core diagnostics pass, but parameter stability is rejected",
      !distribution_fit_pass ~
        "Core diagnostics and joint stability pass; distribution GOF remains a limitation",
      TRUE ~ "Core diagnostics, stability, and distribution checks pass"
    )
  ) %>%
  dplyr::select(
    model,
    variance_model,
    distribution,
    status,
    convergence,
    log_likelihood,
    aic,
    bic,
    aic_rank,
    delta_aic,
    persistence,
    persistence_warning,
    ljung_box_residual_p,
    ljung_box_squared_p,
    arch_lm_p,
    core_diagnostics_pass,
    sign_bias_joint_p,
    sign_bias_pass,
    nyblom_joint,
    nyblom_5pct_critical,
    parameter_stability_pass,
    pearson_group20_p,
    distribution_fit_pass,
    provisional_candidate,
    evidence_assessment
  ) %>%
  dplyr::arrange(aic_rank, model)

# 3. COMPATIBILITY OVERVIEW ----------------------------------------------------
# This overview does not rank price and volatility models against each other.
best_final_model <- price_forecast_comparison %>%
  dplyr::slice_min(rmse, n = 1, with_ties = FALSE) %>%
  dplyr::pull(model)
best_cv_model <- price_forecast_comparison %>%
  dplyr::filter(!is.na(cv_mean_rmse)) %>%
  dplyr::slice_min(cv_mean_rmse, n = 1, with_ties = FALSE) %>%
  dplyr::pull(model)

model_comparison_overview <- tibble::tibble(
  analysis = c("Price forecast", "Conditional volatility"),
  provisional_conclusion = c(
    paste0(
      "Holdout leader: ", best_final_model,
      "; rolling-CV leader among evaluated models: ", best_cv_model
    ),
    if (is.na(provisional_model)) {
      "No volatility model passes the current eligibility rules"
    } else {
      paste0("Provisional candidate: ", provisional_model)
    }
  ),
  limitation = c(
    "Holdout and rolling-CV evidence do not identify one universal winner",
    "Results are provisional until final clean-data rerun and distribution limitations remain"
  )
)

# 4. EXPORT --------------------------------------------------------------------
readr::write_csv(
  price_forecast_comparison,
  file.path(TABLE_DIR, "price_forecast_comparison.csv")
)
readr::write_csv(
  volatility_model_comparison,
  file.path(TABLE_DIR, "volatility_model_comparison.csv")
)
readr::write_csv(
  model_comparison_overview,
  file.path(TABLE_DIR, "model_comparison.csv")
)

message("Exported separate price and volatility comparison tables.")
print(model_comparison_overview)

