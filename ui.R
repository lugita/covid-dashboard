header <- dashboardHeader(title = "Covid Analytics")

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(text = "Overview",
                 tabName = "over", icon = icon("globe-asia")),
        menuItem(text = "Plot",
                 tabName = "plt", icon = icon("chart-bar")),
        menuItem(text = "Table",
                 tabName = "tab", icon = icon("table"))
    ) 
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "over",
                fluidPage(valueBoxOutput("box_case"),
                          valueBoxOutput("box_recover"),
                          valueBoxOutput("box_death")),
                fluidPage(sliderInput(inputId = "timeSlider",
                                      label = "Select Date:",
                                      min = min(covid_daily$Dates), 
                                      max = max(covid_daily$Dates),
                                      value = max(covid_daily$Dates),
                                      width      = "100%",
                                      timeFormat = "%d.%m.%Y",
                                      animate = animationOptions(loop = TRUE))),
                fluidPage(h2("Case Overview", align="center"),
                          leafletOutput("covid_map"))),
        tabItem(tabName = "plt",
                fluidPage(selectInput(inputId = "sel_island",
                                      label = "Select Island:",
                                      choices = unique(covid$Island))),
                fluidPage(column(plotlyOutput(outputId = "plot1"),
                                 width = 6),
                          column(plotlyOutput(outputId = "plot2"),
                                 width = 6)),
                fluidPage(selectInput(inputId = "sel_month",
                                      label = "Select Month:",
                                      choices = unique(covid_daily$Month))),
                fluidPage(plotlyOutput(outputId = "plot3"))),
        tabItem(tabName = "tab", dataTableOutput(outputId = "table"))
    )
)

dashboardPage(
    header = header,
    body = body,
    sidebar = sidebar
)
