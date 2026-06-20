# README du lieu FPT

## Nguon va kha nang tai lap

Du lieu OHLCV duoc tai tu Yahoo Finance voi ma `FPT.VN` bang notebook
`notebooks/01_scrape_fpt_colab.ipynb`. Notebook dung `auto_adjust = TRUE`, do do
cac cot gia la gia da dieu chinh. Khoang tai du lieu la tu `2015-01-01` den
`2026-06-09`; tham so `end` cua Yahoo Finance la moc loai tru, nen quan sat cuoi
cung la `2026-06-08`.

Notebook xuat file `FPT_stock_data.csv`. Sau khi tai ve, dat file tai:

`data/raw/FPT_stock_data.csv`

Sau do chay tu thu muc goc cua du an:

```r
source("R/01_data_cleaning.R")
source("R/02_visualization.R")
```

## Du lieu tho

`data/raw/FPT_stock_data.csv` co 2,960 dong va 6 cot: `date`, `open`, `high`,
`low`, `close`, `volume`.

## Du lieu sach

`data/processed/fpt_clean.csv` co 2,787 dong, tu `2015-01-05` den
`2026-06-08`, va 8 cot:

- `date`: ngay giao dich
- `open`, `high`, `low`, `close`: gia OHLC da dieu chinh
- `volume`: khoi luong giao dich
- `log_close`: log tu nhien cua `close`
- `return`: `log(close_t) - log(close_{t-1})`

`return` cua dong dau tien la `NA` theo dinh nghia sai phan. Khi mo hinh hoa,
can loai dong nay bang `filter(!is.na(return))`.

## Kiem tra chat luong

Quy trinh tai `R/01_data_cleaning.R`:

- kiem tra schema, ngay trung, gia tri thieu, gia khong duong va volume am;
- loai 173 dong co `volume = 0`;
- kiem tra quan he OHLC voi tolerance `1e-8` de bo qua sai so dau phay dong;
- chuan hoa mot dong bat thuong OHLC thuc su (`2021-11-02`);
- tao `log_close` va log return.

Ket qua kiem tra duoc ghi tai `output/tables/data_quality_report.csv`. Du lieu
phu thuoc Yahoo Finance va co the thay doi neu nha cung cap hieu chinh lich su.
Du lieu va bao cao khong phai khuyen nghi dau tu.
