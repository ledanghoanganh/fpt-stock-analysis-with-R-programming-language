# MODULE 05 - SO SÁNH VÀ LỰA CHỌN MÔ HÌNH
# Module chỉ ghép output từ 03/04; price forecast và volatility luôn tách riêng.
source("R/00_config.R")

# Dữ liệu đã được kiểm tra ở module tạo ra chúng; read_csv sẽ dừng nếu thiếu file.
forecast <- readr::read_csv(file.path(TABLE_DIR, "forecast_metrics.csv"),
                            show_col_types = FALSE)
cv <- readr::read_csv(file.path(TABLE_DIR, "forecast_cv_metrics_summary.csv"),
                      show_col_types = FALSE)
forecast_diag <- readr::read_csv(file.path(TABLE_DIR, "forecast_diagnostics.csv"),
                                 show_col_types = FALSE)
garch <- readr::read_csv(file.path(TABLE_DIR, "garch_comparison.csv"),
                         show_col_types = FALSE)
garch_diag <- readr::read_csv(file.path(TABLE_DIR, "garch_diagnostic_summary.csv"),
                              show_col_types = FALSE)

#' Chuẩn hóa tên ARIMAX trước khi join các bảng forecast
#'
#' @param name Character vector chứa nhãn model.
#' @return Character vector với mọi nhãn bắt đầu bằng ARIMAX đổi thành `ARIMAX`.
#' @details Chỉ key tạm được chuẩn hóa; tên hiển thị trong output vẫn được giữ.
model_key <- function(name) {
  if_else(str_detect(name, regex("^ARIMAX", ignore_case = TRUE)), "ARIMAX", name)
}

# 1. PRICE FORECAST: ghép holdout, rolling CV và Ljung-Box diagnostics.
holdout <- forecast %>% mutate(key = model_key(model))
cv <- cv %>%
  mutate(key = model_key(model)) %>%
  transmute(
    key, cv_mean_rmse = mean_rmse, cv_mean_mae = mean_mae,
    cv_mean_mape = mean_mape, cv_median_mape = median_mape
  )
forecast_diag <- forecast_diag %>%
  mutate(key = model_key(model)) %>%
  transmute(
    key, residual_ljung_box_statistic = lb_statistic,
    residual_ljung_box_p = lb_p_value, residual_white_noise = white_noise
  )

naive_holdout <- holdout$rmse[holdout$key == "Naive"]
naive_cv <- cv$cv_mean_rmse[cv$key == "Naive"]

price_comparison <- holdout %>%
  left_join(cv, by = "key") %>%
  left_join(forecast_diag, by = "key") %>%
  mutate(
    final_rmse_rank = min_rank(rmse),
    cv_rmse_rank = min_rank(cv_mean_rmse),
    beats_naive_final = rmse < naive_holdout,
    beats_naive_cv = if_else(is.na(cv_mean_rmse), NA, cv_mean_rmse < naive_cv),
    residual_diagnostic_pass = if_else(
      is.na(residual_ljung_box_p), NA, residual_ljung_box_p >= 0.05
    ),
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

# 2. VOLATILITY: fit tốt chưa đủ; candidate phải đạt core diagnostics và stability.
volatility_comparison <- garch %>%
  left_join(select(garch_diag, -convergence, -persistence), by = "model") %>%
  mutate(
    aic_rank = min_rank(aic),
    delta_aic = aic - min(aic),
    core_diagnostics_pass = convergence == 0 & ljung_box_residual_p >= 0.05 &
      ljung_box_squared_p >= 0.05 & arch_lm_p >= 0.05,
    sign_bias_pass = sign_bias_joint_p >= 0.05,
    parameter_stability_pass = nyblom_joint <= nyblom_5pct_critical,
    distribution_fit_pass = pearson_group20_p >= 0.05,
    persistence_warning = persistence >= 0.995
  )

# AIC chỉ xếp hạng trong nhóm đã đạt diagnostics và parameter stability.
candidate <- volatility_comparison %>%
  filter(core_diagnostics_pass, parameter_stability_pass) %>%
  slice_min(aic, n = 1, with_ties = FALSE) %>%
  pull(model)

volatility_comparison <- volatility_comparison %>%
  mutate(
    provisional_candidate = model == candidate,
    evidence_assessment = case_when(
      convergence != 0 ~ "Model did not converge",
      !core_diagnostics_pass ~ "Residual dynamics remain after fitting",
      !parameter_stability_pass ~
        "Core diagnostics pass, but parameter stability is rejected",
      !distribution_fit_pass ~
        "Core diagnostics and joint stability pass; distribution GOF remains a limitation",
      TRUE ~ "Core diagnostics, stability, and distribution checks pass"
    )
  ) %>%
  arrange(aic_rank, model)

# 3. OVERVIEW: tóm tắt hai bài toán, không xếp chúng trên cùng một thang điểm.
holdout_leader <- price_comparison$model[which.min(price_comparison$rmse)]
cv_leader <- price_comparison %>%
  filter(!is.na(cv_mean_rmse)) %>%
  slice_min(cv_mean_rmse, n = 1, with_ties = FALSE) %>%
  pull(model)

overview <- tibble(
  analysis = c("Price forecast", "Conditional volatility"),
  provisional_conclusion = c(
    paste0("Holdout leader: ", holdout_leader,
           "; rolling-CV leader among evaluated models: ", cv_leader),
    paste0("Balanced candidate: ", candidate)
  ),
  limitation = c(
    "Holdout and rolling-CV evidence do not identify one universal winner",
    "Distribution fit remains a limitation"
  )
)

write_project_csv(price_comparison, "price_forecast_comparison.csv")
write_project_csv(volatility_comparison, "volatility_model_comparison.csv")
write_project_csv(overview, "model_comparison.csv")
message("Đã xuất comparison riêng cho forecast và volatility.")
