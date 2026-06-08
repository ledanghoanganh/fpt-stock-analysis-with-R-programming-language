library(readr)
library(dplyr)
library(ggplot2)

fpt <- read_csv("data/processed/fpt_clean.csv")

fpt$time <- as.Date(fpt$time)

# Descriptive statistics
summary(fpt)

# Daily return
fpt <- fpt %>%
  mutate(
    Return = (close - lag(close)) / lag(close)
  )

# Close Price
ggplot(fpt, aes(time, close)) +
  geom_line() +
  labs(
    title = "FPT Closing Price",
    x = "Date",
    y = "Close Price"
  )

# Volume
ggplot(fpt, aes(time, volume)) +
  geom_line() +
  labs(
    title = "FPT Trading Volume",
    x = "Date",
    y = "Volume"
  )

# Return
ggplot(fpt, aes(time, Return)) +
  geom_line() +
  labs(
    title = "Daily Return",
    x = "Date",
    y = "Return"
  )