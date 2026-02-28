# app.R
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(tidyverse)
library(lubridate)
library(DT)

# --- UI ---

# ui ----------------------------------------------------------------------

ui <- dashboardPage(
  dashboardHeader(title = "NOMO: Noise Monitoring System", titleWidth = 400),
  
  # dashboardSidebar(disable = TRUE),  # Sidebar removed
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Controls", tabName = "controls", icon = icon("sliders")),
      selectInput(inputId = "dep", label = "Select deployments to display", choices = "All", selectize = T, multiple = T)
    )
  ),
  
  dashboardBody(
    fluidRow(
      box(
        title = "Timeseries",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        plotOutput("plot", height = "400px")
      )
    ),
    fluidRow(
      box(
        title = "Hourly",
        status = "primary",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        plotOutput("hourly", height = "400px")
      ),
      box(
        title = "Comparison",
        status = "primary",
        solidHeader = TRUE,
        width = 6,
        collapsible = TRUE,
        plotOutput("comparison", height = "400px")
      )
    ),
    fluidRow(
      box(
        title = "Data Table",
        status = "info",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        downloadButton("downloadData", "Download")
        # p(),
        # DTOutput("table")
      )
    )
  )
)

# server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # process data ------------------------------------------------------------

  # read in data
  data = readRDS('data/processed/noise.rds')
  
  # Dynamically create deployment selectors based on CSV columns
  observe({
    dep_id_choices = c('All', unique(data$dep_id))
    
    updateSelectInput(
      session,
      inputId = "dep",
      choices = dep_id_choices,
      selected = 'All'
    )
  })
  
  d <- reactive({
    if("All" %in% input$dep){
      data
    } else {
      data %>% filter(dep_id %in% input$dep)
    }
  })
  
  # plot timeseries ---------------------------------------------------------

  # Render the plotly plot
  output$plot <- renderPlot({
    
    # convert reactive data object
    df = d()
    
    # plot
    p <- ggplot(df, aes(x = time_local, y = dB, color = dep_id, group = dep_id)) +  
      geom_path() +
      geom_point() +
      labs(x = 'Time (Eastern)', y = 'Noise level (dB)', color = 'Deployment', group = 'Deployment') +
      theme_minimal()
    p
    # ggplotly(p)
  })
  
  # plot comparison ---------------------------------------------------------

  # Render the plotly plot
  output$comparison <- renderPlot({
    
    # convert reactive data object
    df = d()
    
    # plot
    p <- ggplot(df) +  
      geom_violin(aes(x = dep_id, y = dB, fill = dep_id, group = dep_id, color = dep_id), alpha = 0.2)+
      geom_boxplot(aes(x = dep_id, y = dB, fill = dep_id, group = dep_id), outlier.fill = NULL, outlier.shape = 1, width = .25)+
      labs(x = 'Deployment', y = 'Noise level (dB)') +
      theme_minimal()+
      theme(legend.position = "none")
    # ggplotly(p)
    p
  })
  
  # plot hourly -------------------------------------------------------------

  # Render the hourly plot
  output$hourly <- renderPlot({
    
    # convert reactive data object
    df = d()
    
    # add local time of day
    df$local_hour = lubridate::hour(df$time_local)
    
    # compute summary stats
    df_sum = df %>% group_by(local_hour, dep_id) %>%
      summarize(
        mean_dB = median(dB),
        min_dB = quantile(dB, probs = 0.25),
        max_dB = quantile(dB, probs = 0.75)
      )
    
    # plot
    p <- ggplot() +  
      geom_point(data = df, aes(x = local_hour, y = dB, color = dep_id), shape = 1) +
      geom_ribbon(data = df_sum, aes(x = local_hour, ymin = min_dB, ymax = max_dB, color = NULL, fill = dep_id, group = dep_id), alpha = 0.3)+
      geom_line(data = df_sum, aes(x = local_hour, y = mean_dB, color = dep_id, group = dep_id))+
      labs(x = 'Hour of day (Eastern)', y = 'Noise level (dB)', color = 'Deployment', group = 'Deployment', fill = 'Deployment') +
      theme_minimal()
    # ggplotly(p)
    p
  })
  
  # plot table --------------------------------------------------------------

  # Render the filterable table
  # output$table <- renderDT({
  #   df <- d() %>%
  #     mutate(
  #       time_utc = format(time_utc, "%Y-%m-%d %H:%M:%S"),
  #       time_local = format(time_local, "%Y-%m-%d %H:%M:%S")
  #     ) %>%
  #     arrange(desc(time_local))
  #   datatable(df, filter = "top", options = list(pageLength = 10), rownames = F)
  # })

  # data download -----------------------------------------------------------

  output$downloadData <- downloadHandler(
    filename = function() {
      "nomo-data.csv"
    },
    content = function(file) {
      
      df <- d() %>%
        mutate(
          time_utc = format(time_utc, "%Y-%m-%d %H:%M:%S"),
          time_local = format(time_local, "%Y-%m-%d %H:%M:%S")
        ) %>%
        arrange(desc(time_local))
        
      write.csv(df, file)
    }
  )
  
}

shinyApp(ui, server)
