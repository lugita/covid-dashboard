# import libs
library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(scales)
library(glue)
library(lubridate)
library(DT)
library(ggpubr)
library(ggrepel)
library(anytime)
library(leaflet)

# Import Dataset 
data <- read.csv("covid.csv",fileEncoding = 'UTF-8-BOM')

# Main Data
covid <- data %>% 
  select(-c("Growth.Factor.of.New.Deaths","Growth.Factor.of.New.Cases","Total.Rural.Villages","Total.Urban.Villages",
            "Total.Cities","City.or.Regency","Total.Cases","Total.Deaths","Total.Recovered","Total.Active.Cases")) %>% 
  mutate(Dates = as.Date(Dates, format = "%m-%d-%Y"),
         Monthh = month(Dates, label = TRUE, abbr = FALSE),
         Island = replace(Island, Island=="", "Kalimantan"))

# Processed Data
covid_daily <- covid %>%
  group_by(Dates) %>%
  summarise(Total_Cases = sum(New.Cases),
            Total_Death = sum(New.Deaths),
            Total_Recover = sum(New.Recovered)) %>% 
  mutate(Cumulative_Case = cumsum(Total_Cases),
         Cumulative_Death = cumsum(Total_Death),
         Cumulative_Recover = cumsum(Total_Recover),
         Active_Case = Cumulative_Case-Cumulative_Death-Cumulative_Recover,
         Month = month(Dates, label = TRUE, abbr = FALSE))

  
