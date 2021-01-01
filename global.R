library(shiny)
library(shinydashboard)
library(tidyverse)
library(glue)
library(scales)
library(DT)
library(plotly)
library(lubridate)
library(dplyr)
library(anytime)
library(RColorBrewer)
library(leaflet)
library(ggplot2)


data <- read.csv("covid.csv")

covid <- data %>% 
  rename(Date = ï..Date) %>% 
  select(-c("Growth.Factor.of.New.Deaths","Growth.Factor.of.New.Cases","Total.Rural.Villages","Total.Urban.Villages",
            "Total.Cities","City.or.Regency","Total.Cases","Total.Deaths","Total.Recovered","Total.Active.Cases")) %>% 
  mutate(Date = ymd(anytime::anydate(Date)),
         Month = month(Date, label = TRUE, abbr = FALSE), 
         Day = lubridate::day(Date),
         Island = replace(Island, Island=="","Kalimantan")
  )

covid_island <- covid %>%
  group_by(Island) %>%
  summarise(Total.Cases = sum(New.Cases),
            Total.Death = sum(New.Deaths),
            Total.Recover = sum(New.Recovered))

covid_daily <- covid %>%
  group_by(Date) %>%
  summarise(Total.Cases = sum(New.Cases),
            Total.Death = sum(New.Deaths),
            Total.Recover = sum(New.Recovered)) %>% 
  mutate(Cum.Cases = cumsum(Total.Cases),
         Cum.Death = cumsum(Total.Death),
         Cum.Recover = cumsum(Total.Recover),
         active.case = Cum.Cases-Cum.Death-Cum.Recover,
         Month = month(Date, label = TRUE, abbr = FALSE))

data.agg1 <- covid_daily %>% 
  select("Date","active.case","Cum.Cases","Cum.Death","Cum.Recover") %>% 
  gather(key = "variable", value = "value", -Date)
