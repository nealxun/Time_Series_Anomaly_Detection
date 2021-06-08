# objective: time series anomaly detection tutorial

# preparation
rm(list = ls())
# obtain the current source file work directory
wd <- getwd()


# load all the necessary packages
#devtools::install_github("business-science/anomalize")
#devtools::install_github("amrrs/coindeskr")
library(anomalize) #tidy anomaly detection
library(tidyverse) #tidyverse packages like dplyr, ggplot, tidyr
library(coindeskr) #bitcoin price extraction from coindesk
library(fpp3)

# data extraction
btc <- get_historic_price(start = "2017-01-01")
btc_ts <- btc %>% 
        rownames_to_column() %>% 
        as_tibble() %>% 
        mutate(date = as.Date(rowname)) %>% 
        filter(date < as.Date("2020-01-01")) %>% 
        select(-one_of('rowname'))
btc_tsbl <- btc_ts %>% 
        tsibble::as_tsibble(index = date)

ggplot(btc_ts) + geom_line(aes(x = date, y = Price))

# time series decomposition
btc_tsbl %>%
        model(
                STL(Price ~ trend(window = 7) +
                            season(window = "periodic"), robust = TRUE)
        ) %>%
        components() %>%
        autoplot() +
        labs(title = "Bitcoin Price")


# anomaly detection with time series decomposition
btc_ts %>% 
        time_decompose(Price, method = "stl", frequency = "auto", trend = "auto") %>%
        anomalize(remainder, method = "gesd", alpha = 0.05, max_anoms = 0.2) %>%
        plot_anomaly_decomposition()

btc_ts %>% 
        time_decompose(Price) %>%
        anomalize(remainder) %>%
        time_recompose() %>%
        plot_anomalies(time_recomposed = TRUE, ncol = 3, alpha_dots = 0.5)

# extract anomaly dates
btc_ts %>% 
        time_decompose(Price) %>%
        anomalize(remainder) %>%
        time_recompose() %>%
        filter(anomaly == 'Yes') 






