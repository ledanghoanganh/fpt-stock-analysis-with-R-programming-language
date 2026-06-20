# Phan cong sau khi chot du lieu

## Moc ban giao bat buoc

Hai nguoi chi bat dau sau khi commit du lieu moi da duoc merge vao `main`.

```powershell
git switch main
git pull origin main
git status --short
Get-FileHash data/processed/fpt_clean.csv -Algorithm SHA256
```

`git status --short` phai rong. Ca hai gui cho nhau SHA-256 cua
`data/processed/fpt_clean.csv`; hai ma phai trung nhau. Du lieu ky vong:

- 2,787 dong, 8 cot;
- tu `2015-01-05` den `2026-06-08`;
- 2,786 log return hop le;
- khong co `volume <= 0` hoac ngay trung.

Khong su dung lai metric, model RDS, hinh hoac ket luan tao truoc data handoff.

## Nguoi 2 - Forecast va danh gia ngoai mau

### Pham vi so huu

- `R/03_stationarity_arima_ets.R`
- `report/sections/04_modeling_arima_ets.md`
- cac output co tien to `forecast_`, forecast figures va forecast model RDS

### Lenh thuc hien

```powershell
git switch -c person2-rerun-final-data
Rscript R/03_stationarity_arima_ets.R
```

Neu `Rscript` chua co trong PATH:

```powershell
& "C:\Program Files\R\R-4.6.0\bin\x64\Rscript.exe" R/03_stationarity_arima_ets.R
```

### Checklist ket qua

- Xac nhan train/test duoc tao lai tu 2,787 dong, khong hard-code index cu.
- Kiem tra ADF va ghi dung H0/H1; khong goi chuoi gia la dung neu p-value lon.
- So sanh Naive, Drift, ARIMA, SARIMA, ETS, ETS Damped va ARIMAX tren cung holdout.
- Bao cao RMSE, MAE, MAPE; khong chon model chi bang AIC/BIC.
- Kiem tra rolling-origin CV va noi ro model nao chua co CV cung coverage.
- Kiem tra Ljung-Box/ACF residual; khong goi model "tot nhat" neu diagnostics khong dat.
- Kiem tra ARIMAX khong dung bien tuong lai cua holdout, tranh leakage.
- Cap nhat `04_modeling_arima_ets.md` tu CSV moi, xoa moi con so cu.

### Dau ra toi thieu

- `output/tables/forecast_metrics.csv`
- `output/tables/forecast_cv_metrics_raw.csv`
- `output/tables/forecast_cv_metrics_summary.csv`
- `output/tables/forecast_diagnostics.csv`
- `output/tables/model_aic_bic_comparison.csv`
- forecast figures va model RDS tu lan chay moi

### Ban giao cho Nguoi 3

Gui commit hash, SHA-256 cua `fpt_clean.csv`, model dat holdout/CV, va cac canh bao
diagnostics. Khong gui ket luan bang tin nhan ma khong kem CSV tao ra ket luan do.

Commit goi y:

```powershell
git add R/03_stationarity_arima_ets.R report/sections/04_modeling_arima_ets.md
git add output/tables/forecast_*.csv output/tables/model_aic_bic_comparison.csv
git add output/figures/*forecast.png output/figures/*residual_diagnostics.png
git add output/models/arima*.rds output/models/sarima_model.rds output/models/ets*.rds
git commit -m "Rerun forecast models on final cleaned data"
git push -u origin person2-rerun-final-data
```

## Nguoi 3 - GARCH, tich hop bao cao va slide

### Pham vi so huu

- `R/04_garch_volatility.R`
- `R/05_model_comparison.R`
- `R/06_export_report_tables.R`
- `report/report.Rmd`, bao cao Word va slide
- GARCH tables, figures va model RDS

### Lenh chay GARCH song song

```powershell
git switch -c person3-rerun-final-data
Rscript R/04_garch_volatility.R
```

Hoac dung duong dan R 4.6.0 nhu phan Nguoi 2 neu PATH chua nhan `Rscript`.

### Checklist GARCH

- Xac nhan input dung 2,786 return, khong fit GARCH tren `close`.
- Bon specification dung cung sample va return scale:
  sGARCH-Normal, sGARCH-Student-t, eGARCH-Student-t, GJR-GARCH-Student-t.
- Kiem tra convergence, robust standard errors, persistence va stability.
- Kiem tra standardized residual, squared residual, ARCH-LM, sign bias va GOF.
- Khong chon model chi vi AIC nho nhat; neu diagnostics mau thuan, ghi ro candidate.
- Khong dien giai persistence eGARCH/GJR bang cong thuc `alpha + beta` cua sGARCH.
- Cap nhat bang tham so, comparison, volatility, QQ/ACF va news-impact figures.

### Tich hop sau khi PR Nguoi 2 san sang

```powershell
git fetch origin
git merge origin/person2-rerun-final-data
Rscript R/05_model_comparison.R
Rscript R/06_export_report_tables.R
Rscript -e "rmarkdown::render('report/report.Rmd', output_file='report.docx', knit_root_dir=normalizePath('.'))"
```

Sau khi render:

- doi chieu moi con so trong README, Word va slide voi CSV moi;
- xoa cac cau "provisional", "dang cho data handoff" neu khong con dung;
- neu holdout va CV khong cung winner, trinh bay ca hai thay vi ep mot winner;
- neu GARCH GOF/stability khong dat, ghi day la han che;
- khong dua ra khuyen nghi mua/ban hay tuyen bo nhan qua khong co bang chung.

Commit goi y:

```powershell
git add R/04_garch_volatility.R R/05_model_comparison.R R/06_export_report_tables.R report output README.md
git commit -m "Rerun volatility models and finalize report on final data"
git push -u origin person3-rerun-final-data
```

## Review cheo va dinh nghia hoan thanh

Nguoi 3 review Nguoi 2: cung holdout, khong leakage, benchmark day du, metric va
diagnostics khop CSV. Nguoi 2 review Nguoi 3: cung return sample, bon GARCH,
diagnostics day du, dien giai persistence/asymmetry dung.

Cong viec chi hoan thanh khi:

1. Ca hai dung cung SHA-256 cua data sach.
2. Tat ca script tren chay thanh cong trong R session moi.
3. Model RDS va output deu co thoi gian tao sau data handoff.
4. `report/report.docx` mo duoc, bang va hinh khong bi vo.
5. README, Word va slide khong con con so tu bo du lieu 2,960 dong cu.
