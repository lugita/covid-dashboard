header <- dashboardHeader(title = "Covid Analysis")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(text = " Overview",
             tabName = "over", icon = icon("globe-asia")),
    menuItem(text = " Plot",
             tabName = "plot", icon = icon("chart-bar")),
    menuItem(text = "Table",
             tabName = "tab", icon = icon("table"))
    # menuItem(text = "About",
    #          tabName = "about", icon = icon("question-circle"))
  )
)
body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "over",
      fluidRow(
        valueBoxOutput("box.case"),
        valueBoxOutput("box.recover"),
        valueBoxOutput("box.death")
      ),
      fluidRow(
        column(
          sliderInput(
            "timeSlider","Select Date:",
            min = min(covid_daily$Date), 
            max = max(covid_daily$Date),
            value = max(covid_daily$Date),
            width      = "100%",
            timeFormat = "%d.%m.%Y",
            animate = animationOptions(loop = TRUE)
          ),
          width = 12
        )
      ),
      fluidRow(
        h2("Case Overview", align="center"),
        column(
          leafletOutput("covid.map"),
          width = 12
        )
      )
    ),
    tabItem(
      tabName = "plot",
      fluidRow(
        column(
          selectInput(
            inputId = "sel.island",
            label = "Select Island",
            choices = unique(covid$Island)
          ),
          width = 6
        )
      ),
      fluidRow(
        column(
          plotlyOutput(outputId = "plot1"),
          width = 6
        ),
        column(
          plotlyOutput(outputId = "plot2"),
          width = 6
        )
      ),
      fluidRow(
        column(
          selectInput(
            inputId = "sel.month",
            label = "Select Month",
            choices = unique(covid$Month)
          ),
          width = 2
        )
      ),
      fluidRow(
        column(
          plotlyOutput(outputId = "plot3"),
          width = 12
        )
      )
    ),
    tabItem(
      tabName = "tab",
      dataTableOutput("data")
    )
  )
)

dashboardPage(
  header = header,
  body = body,
  sidebar = sidebar
)
