function(input,output){
    # OVERVIEW
    
    # Value Box
    output$box_case <- renderValueBox(
        valueBox(covid_daily$Cumulative_Case[covid_daily$Dates==input$timeSlider], 
                 "Confirmed", 
                 icon = icon("virus"), 
                 color = "yellow")
    )
    output$box_recover <- renderValueBox(
        valueBox(covid_daily$Cumulative_Recover[covid_daily$Dates==input$timeSlider], 
                 "Recovered", 
                 icon = icon("file-medical-alt"), 
                 color = "blue")
    )
    output$box_death <- renderValueBox(
        valueBox(covid_daily$Cumulative_Death[covid_daily$Dates==input$timeSlider], 
                 "Deceased", 
                 icon = icon("skull-crossbones"), 
                 color = "red")
    )
    
    # Map
    output$covid_map <- renderLeaflet({
        covid_atDate <- covid %>% 
            filter(Dates <= input$timeSlider) %>% 
            select("Longitude", "Latitude")
        leaflet(data = covid_atDate) %>% 
            addTiles() %>%
            addCircleMarkers(col = "maroon", 
                             fillOpacity = 1, 
                             radius = 5,
                             stroke = TRUE,
                             clusterOptions = markerClusterOptions(maxClusterRadius=35,
                                                                   disableClusteringAtZoom=14))
    })
       
    #PLOTS
    
    #plot1
    output$plot1 <- renderPlotly({
        data_agg1 <- covid_daily %>% 
            select("Dates","Active_Case","Cumulative_Case","Cumulative_Death","Cumulative_Recover") %>% 
            gather(key = "variable", value = "value", -Dates)
        plot1 <- data_agg1 %>% 
            ggplot(aes(x = Dates, y=value)) + 
            geom_line(aes(color = variable, linetype = variable)) + 
            scale_color_manual(values = c("red","orange","black", "blue")) +
            theme_light()+
            ggtitle("Kurva Evolusi Kasus Covid Indonesia")
        ggplotly(plot1, tooltip = "text")
    })
    #plot2
    output$plot2 <- renderPlotly({
        covid_island <- covid %>% 
            filter(Island==input$sel_island) %>% 
            group_by(Dates) %>%
            summarise(Total_Cases = sum(New.Cases),
                      Total_Death = sum(New.Deaths),
                      Total_Recover = sum(New.Recovered)) %>% 
            mutate(Cumulative_Case = cumsum(Total_Cases),
                   Cumulative_Death = cumsum(Total_Death),
                   Cumulative_Recover = cumsum(Total_Recover),
                   Active_Case = Cumulative_Case-Cumulative_Death-Cumulative_Recover,
                   Month = month(Dates, label = TRUE, abbr = FALSE))
        data_agg2 <- covid_island %>% 
            select("Dates","Active_Case","Cumulative_Case","Cumulative_Death","Cumulative_Recover") %>% 
            gather(key = "variable", value = "value", -Dates)
        plot2 <- data_agg2 %>% 
            ggplot(aes(x = Dates, y=value)) + 
            geom_line(aes(color = variable, linetype = variable)) + 
            scale_color_manual(values = c("red","orange","black", "blue")) +
            theme_light()+
            ggtitle(paste("Kurva Evolusi Kasus Covid Pulau",input$sel_island,sep = " "))
        ggplotly(plot2, tooltip = "text")
    })
    #plot3
    output$plot3 <- renderPlotly({
        covid_island2 <- covid %>%
            filter(Monthh==input$sel_month) %>% 
            group_by(Island) %>%
            summarise(Total_Case = sum(New.Cases),
                      Total_Death = sum(New.Deaths),
                      Total_Recover = sum(New.Recovered))
        data_agg3 <- covid_island2 %>% 
            select("Island","Total_Case","Total_Death","Total_Recover") %>% 
            gather(key = "variable", value = "value", -Island)
        plot3 <- data_agg3 %>% 
            ggplot(aes(Island, value)) + 
            geom_col(aes(fill = variable), position = "dodge")+
            scale_fill_manual(values=c("#153E7E","red","#6698FF"))+
            theme_minimal()+
            ggtitle(paste("Plot Evaluasi Kasus Covid Bulan",input$sel_month,sep = " "))
        ggplotly(plot3, tooltip = "text")
    })
    
    
    # TABLE
    output$table <- DT::renderDataTable({
        DT::datatable(data = covid, options = list(scrollX = T))
    })
}
