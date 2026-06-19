# ==============================================================================
# PROJECT: Stock Market Analysis (FPT)
# SCRIPT: 04_garch_volatility.R
# PURPOSE: Fit and compare symmetric/asymmetric GARCH(1,1) specifications
# ==============================================================================

source("R/00_config.R")

required_packages <- c("rugarch", "dplyr", "tidyr", "purrr", "readr", "ggplot2", "scales")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop("Thiếu package: ", paste(missing_packages, collapse = ", "))
}

# 1. READ AND VALIDATE DATA -----------------------------------------------------
if (!file.exists(CLEAN_DATA_PATH)) {
  stop("Không tìm thấy dữ liệu sạch: ", CLEAN_DATA_PATH)
}

df <- readr::read_csv(CLEAN_DATA_PATH, show_col_types = FALSE)
required_columns <- c("date", "return")
missing_columns <- setdiff(required_columns, names(df))
if (length(missing_columns) > 0) {
  stop("Dữ liệu thiếu cột: ", paste(missing_columns, collapse = ", "))
}

df$date <- as.Date(df$date)
valid_rows <- is.finite(df$return) & !is.na(df$date)
df_valid <- df[valid_rows, c("date", "return")]
returns <- as.numeric(df_valid$return)

if (length(returns) < 500) stop("Không đủ return hợp lệ để fit GARCH")
if (!isTRUE(all(diff(df_valid$date) >= 0))) stop("Dữ liệu chưa được sắp xếp theo ngày")
if (!is.finite(stats::sd(returns)) || stats::sd(returns) == 0) {
  stop("Chuỗi return không có độ biến động hợp lệ")
}

message("GARCH input: ", length(returns), " returns from ",
        min(df_valid$date), " to ", max(df_valid$date))

# 2. MODEL SPECIFICATIONS ------------------------------------------------------
model_specs <- tibble::tribble(
  ~model_name,           ~variance_model, ~distribution,
  "sGARCH-Normal",      "sGARCH",        "norm",
  "sGARCH-Student-t",   "sGARCH",        "std",
  "eGARCH-Student-t",   "eGARCH",        "std",
  "gjrGARCH-Student-t", "gjrGARCH",      "std"
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

# 3. FIT ALL MODELS ON THE SAME RETURN VECTOR ---------------------------------
fit_results <- vector("list", nrow(model_specs))
names(fit_results) <- model_specs$model_name

for (index in seq_len(nrow(model_specs))) {
  specification <- model_specs[index, ]
  message("Fitting ", specification$model_name, "...")
  fit_results[[specification$model_name]] <- safe_fit_garch(
    returns = returns,
    variance_model = specification$variance_model,
    distribution = specification$distribution
  )
}

comparison_rows <- vector("list", nrow(model_specs))
for (index in seq_len(nrow(model_specs))) {
  specification <- model_specs[index, ]
  comparison_rows[[index]] <- extract_comparison_row(
    result = fit_results[[specification$model_name]],
    model_name = specification$model_name,
    variance_model = specification$variance_model,
    distribution = specification$distribution
  )
}

garch_comparison <- dplyr::bind_rows(comparison_rows) %>%
  dplyr::arrange(is.na(aic), aic)

successful_fits <- purrr::keep(
  purrr::map(fit_results, "fit"),
  ~ !is.null(.x)
)

if (length(successful_fits) == 0) {
  readr::write_csv(garch_comparison, file.path(TABLE_DIR, "garch_comparison.csv"))
  stop("Không có GARCH model nào fit thành công")
}

parameter_rows <- purrr::imap(successful_fits, extract_parameter_rows)
garch_parameters <- dplyr::bind_rows(parameter_rows)

readr::write_csv(garch_comparison, file.path(TABLE_DIR, "garch_comparison.csv"))
readr::write_csv(garch_parameters, file.path(TABLE_DIR, "garch_parameters.csv"))
saveRDS(successful_fits, file.path(MODEL_DIR, "garch_fits.rds"))

print(garch_comparison)

# 4. LEGACY BASE-MODEL OUTPUTS -------------------------------------------------
# Keep these files until report/model-comparison modules are migrated.
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
readr::write_csv(garch_summary, file.path(TABLE_DIR, "garch_summary.csv"))

base_volatility <- as.numeric(base_fit@fit$sigma)
vol_df <- tibble::tibble(
  date = df_valid$date,
  return = returns,
  volatility = base_volatility
)
readr::write_csv(vol_df, file.path(TABLE_DIR, "garch_volatility.csv"))

# 5. VISUALIZATIONS ------------------------------------------------------------
theme_garch <- ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
    plot.subtitle = ggplot2::element_text(hjust = 0.5, color = "grey35"),
    legend.position = "bottom",
    panel.grid.minor = ggplot2::element_blank()
  )

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

ggplot2::ggsave(
  file.path(FIGURE_DIR, "garch_volatility.png"),
  p_base, width = 11, height = 6.5, dpi = 300, bg = "white"
)

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

ggplot2::ggsave(
  file.path(FIGURE_DIR, "garch_model_comparison.png"),
  p_comparison, width = 11, height = 6.5, dpi = 300, bg = "white"
)

message("Completed GARCH framework: ", length(successful_fits), "/",
        nrow(model_specs), " models fitted.")

