# Kết luận, hạn chế và hướng phát triển

## Kết luận

1. Raw data có `r fmt_number(raw_rows, 0)` dòng; sau khi loại `r zero_volume_removed` hàng volume bằng 0 và chuẩn hóa `r ohlc_repaired` OHLC row, dữ liệu model còn `r fmt_number(n_observations, 0)` dòng và `r fmt_number(n_returns, 0)` log returns.
2. ADF chưa bác bỏ unit root cho `close` và `log_close`, nhưng bác bỏ unit root cho `return`.
3. `r best_holdout$model` dẫn holdout theo RMSE nhưng chỉ hơn Naive `r fmt_number(holdout_gain)`; `r best_cv$model` dẫn rolling CV; mọi fitted forecast model còn residual autocorrelation.
4. Pre-fit ARCH-LM phát hiện ARCH effect. Student-t cải thiện relative fit so với Normal trong GARCH.
5. GJR có AIC thấp nhất nhưng parameter stability không đạt; eGARCH-Student-t là ứng viên cân bằng nhờ fit gần GJR, core diagnostics và Nyblom stability đạt.
6. Distribution GOF còn bị bác bỏ cho cả bốn GARCH, nên không có model hoàn hảo.

Các kết luận trên chỉ áp dụng cho sample, specification và protocol hiện tại. Dự án không chứng minh quan hệ nhân quả, không định giá FPT và không đưa ra khuyến nghị đầu tư.

## Hạn chế

- Chỉ sử dụng lịch sử một cổ phiếu từ một nhà cung cấp.
- Holdout 30 phiên ngắn; kết quả nhạy với cửa sổ đánh giá.
- SARIMA và ARIMAX chưa có rolling CV cùng coverage.
- Tất cả fitted forecast models còn residual autocorrelation.
- Ba trong bốn GARCH không đạt Nyblom joint stability.
- Pearson GOF bác bỏ distribution fit ở cả bốn GARCH.
- Chưa có out-of-sample volatility loss hoặc VaR backtest.
- Chưa kiểm tra structural breaks một cách chuyên biệt.

## Hướng phát triển

1. Chạy cùng rolling-origin folds cho toàn bộ forecast models.
2. Bổ sung MASE và prediction-interval coverage.
3. Dùng rolling/expanding evaluation cho volatility với QLIKE hoặc MSE trên variance proxy.
4. Thực hiện VaR backtest bằng Kupiec và Christoffersen.
5. Thử skewed Student-t/GED và kiểm tra distribution fit.
6. Kiểm tra structural breaks hoặc regime-switching.
7. Thêm VN-Index, biến vĩ mô hoặc thông tin doanh nghiệp với thiết kế chống leakage.

Ưu tiên của nghiên cứu tiếp theo là đánh giá công bằng và ngoài mẫu, không phải chỉ tăng số lượng model.
