function(input,output){
  output$box.case <- renderValueBox(
    valueBox(covid_daily$Cum.Cases[covid_daily$Date==input$timeSlider], 
             "Confirmed", 
             icon = icon("virus"), 
             color = "yellow")
  )
  output$box.recover <- renderValueBox(
    valueBox(covid_daily$Cum.Recover[covid_daily$Date==input$timeSlider], 
             "Recovered", 
             icon = icon("file-medical-alt"), 
             color = "blue")
  )
  output$box.death <- renderValueBox(
    valueBox(covid_daily$Cum.Death[covid_daily$Date==input$timeSlider], 
             "Deceased", 
             icon = icon("skull-crossbones"), 
             color = "red")
  )
  
  #covid.atDate <- reactive({covid[covid$Date <= format(input$timeSlider, '%d/%m/%Y'), ] })
  covid.atDate <- covid %>% 
    filter(Date <= max(Date)) %>% 
    select("Longitude", "Latitude")
  
  output$covid.map <- renderLeaflet(
    leaflet(data = covid.atDate) %>% 
      addTiles() %>%
      addCircleMarkers(col = "maroon", 
                       fillOpacity = 1, 
                       radius = 5,
                       stroke = TRUE,
                       clusterOptions = markerClusterOptions(
                         maxClusterRadius=35, disableClusteringAtZoom=14
                       ))
  )
  
  output$plot1 <- renderPlotly({
    data.agg1 <- covid_daily %>% 
      select("Date","active.case","Cum.Cases","Cum.Death","Cum.Recover") %>% 
      gather(key = "variable", value = "value", -Date)
    plot1 <- data.agg1 %>% 
      ggplot(aes(x = Date, y=value)) + 
      geom_line(aes(color = variable, linetype = variable)) + 
      scale_color_manual(values = c("red","orange","black", "blue")) +
      theme_light()+
      ggtitle("Kurva Evolusi Kasus Covid Indonesia")
    ggplotly(plot1, tooltip = "text")
  })
  
  output$plot2 <- renderPlotly({
    covid.island <- covid %>% 
      filter(Island==input$sel.island)
    covid_daily.island <- covid.island %>%
      group_by(Date) %>%
      summarise(Total.Cases = sum(New.Cases),
                Total.Death = sum(New.Deaths),
                Total.Recover = sum(New.Recovered)) %>% 
      mutate(Cum.Cases = cumsum(Total.Cases),
             Cum.Death = cumsum(Total.Death),
             Cum.Recover = cumsum(Total.Recover),
             active.case = Cum.Cases-Cum.Death-Cum.Recover,
             Month = month(Date, label = TRUE, abbr = FALSE))
    data.agg2 <- covid_daily.island %>% 
      select("Date","active.case","Cum.Cases","Cum.Death","Cum.Recover") %>% 
      gather(key = "variable", value = "value", -Date)
    plot2 <- data.agg2 %>% 
      ggplot(aes(x = Date, y=value)) + 
      geom_line(aes(color = variable, linetype = variable)) + 
      scale_color_manual(values = c("red","orange","black", "blue")) +
      theme_light()+
      ggtitle(paste("Kurva Evolusi Kasus Covid Pulau",input$sel.island,sep = " "))
    ggplotly(plot2, tooltip = "text")
  })
  
  output$plot3 <- renderPlotly({
    covid_island <- covid %>%
      filter(Month==input$sel.month) %>% 
      group_by(Island) %>%
      summarise(Total.Cases = sum(New.Cases),
                Total.Death = sum(New.Deaths),
                Total.Recover = sum(New.Recovered))
    
    data.agg3 <- covid_island %>% 
      select("Island","Total.Cases","Total.Death","Total.Recover") %>% 
      gather(key = "variable", value = "value", -Island)
    plot.3 <- data.agg3 %>% 
      ggplot(aes(Island, value)) + 
      geom_col(aes(fill = variable), position = "dodge")+
      scale_fill_manual(values=c("#153E7E","red","#6698FF"))+
      theme_minimal()+
      ggtitle(paste("Plot Evaluasi Kasus Covid Bulan",input$sel.month,sep = " "))
    ggplotly(plot.3)
  })
  output$data <- renderDataTable({
    datatable(covid, options = list(scrollX = T))
  })
  
}
