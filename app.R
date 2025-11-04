library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(forcats)
library(DT)
library(plotly)
library(stringr)

# Load and clean data
diaryEntries <- read.csv("/Users/brianavecchione/Desktop/MHC/mhc-diary-dashboard/cleanedDiaryEntries.csv", stringsAsFactors = FALSE)
diaryEntries$interactionDuration <- suppressWarnings(as.numeric(diaryEntries$interactionDuration))

# Derive chatbotFamily
diaryEntries <- diaryEntries %>%
  mutate(chatbotFamily = case_when(
    str_detect(chatbotUsed, "GPT-5") ~ "GPT-5",
    str_detect(chatbotUsed, "Claude") ~ "Claude",
    str_detect(chatbotUsed, "Gemini") ~ "Gemini",
    TRUE ~ "Other"
  ))

# UI ------------------------------------------------------------------
#notes: top metrics respond dynamically to filters, figures do not
ui <- dashboardPage(
  dashboardHeader(title = "Mental Health Chatbots Diary Study"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Diary Study Explorer", tabName = "explorer", icon = icon("table")),
      menuItem("Interview Themes (Coming Soon)", tabName = "themes", icon = icon("comments"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "explorer",
        
        # Metric Value Boxes
        fluidRow(
          valueBoxOutput("totalEntries"),
          valueBoxOutput("avgDuration"),
          valueBoxOutput("pctFree"),
          valueBoxOutput("pctText")
        ),
        
        # Filter Inputs
        fluidRow(
          box(selectInput("selectedChatbot", "Chatbot", choices = c("All", unique(diaryEntries$chatbotUsed))), width = 3),
          box(selectInput("selectedSub", "Subscription Type", choices = c("All", unique(diaryEntries$userSubscription))), width = 3),
          box(selectInput("selectedMode", "Interaction Mode", choices = c("All", unique(diaryEntries$interactionMode))), width = 3),
          box(selectInput("selectedReason", "Reason for Use", choices = c("All", unique(diaryEntries$usageReasons))), width = 3)
        ),
        
        # # Reason and Duration Plots
        # fluidRow(
        #   box(plotOutput("reasonPlot"), width = 6),
        #   box(plotOutput("durationPlot"), width = 6)
        # ),
        
        
        #USER COMMENTS (TO ADD LATER)
        # # Donut Chart + User Comments
        # fluidRow(
        #   box(plotlyOutput("chatbotDonut"), width = 6),
        #   box(DTOutput("commentTable"), width = 6)
        # ),
        
        # --- Scrollable Visualization Section ---
        fluidRow(
          column(12,
                 fluidRow(
                   box(
                     #title = "Figure 1: Chatbot Family Distribution",
                     plotlyOutput("fig1", height = "350px"),
                     width = 4
                   ),
                   box(
                     #title = "Figure 2: Subscription Type",
                     plotlyOutput("fig2", height = "350px"),
                     width = 4
                   ),
                   box(
                     #title = "Figure 3: Interaction Mode",
                     plotlyOutput("fig3", height = "350px"),
                     width = 4
                   )
                 ),
                 div(class = "plot-container",
                     h2("Distribution of Interaction Duration"),
                     plotOutput("fig4", height = "400px")),
                 div(class = "plot-container",
                     h2("Main Reason for Chatbot Use"),
                     plotOutput("fig5", height = "400px")),
                 div(class = "plot-container",
                     h2("Location of Use"),
                     plotOutput("fig6", height = "400px")),
                 div(class = "plot-container",
                     h2("Device Used"),
                     plotOutput("fig7", height = "400px")),
                 div(class = "plot-container",
                     h2("Social Context of Chatbot Use"),
                     plotlyOutput("fig8", height = "400px"))
          )
        )
      )
    )
  )
)

# Server ---------------------------------------------------------------
server <- function(input, output) {
  
  # ---- Filtering ----
  filteredData <- reactive({
    df <- diaryEntries
    if (input$selectedChatbot != "All") df <- df[df$chatbotUsed == input$selectedChatbot, ]
    if (input$selectedSub != "All") df <- df[df$userSubscription == input$selectedSub, ]
    if (input$selectedMode != "All") df <- df[df$interactionMode == input$selectedMode, ]
    if (input$selectedReason != "All") df <- df[df$usageReasons == input$selectedReason, ]
    df
  })
  
  # ---- Value boxes ----
  output$totalEntries <- renderValueBox({
    valueBox(nrow(filteredData()), "Total Entries", icon = icon("clipboard"), color = "purple")
  })
  
  output$avgDuration <- renderValueBox({
    avg <- round(mean(filteredData()$interactionDuration, na.rm = TRUE), 1)
    valueBox(paste0(avg, " min"), "Avg. Conversation", icon = icon("clock"), color = "yellow")
  })
  
  output$pctFree <- renderValueBox({
    pct <- round(mean(filteredData()$userSubscription == "Free", na.rm = TRUE) * 100)
    valueBox(paste0(pct, "%"), "Free Users", icon = icon("money-bill"), color = "green")
  })
  
  output$pctText <- renderValueBox({
    pct <- round(mean(filteredData()$interactionMode == "Text", na.rm = TRUE) * 100)
    valueBox(paste0(pct, "%"), "Text Mode", icon = icon("keyboard"), color = "blue")
  })
  
  # ---- Core plots ----
  output$reasonPlot <- renderPlot({
    ggplot(filteredData(), aes(x = fct_infreq(usageReasons))) +
      geom_bar(fill = "#CCB974") +
      coord_flip() +
      labs(title = "Reason for Use", x = "Reason", y = "Count")
  })
  
  output$durationPlot <- renderPlot({
    ggplot(filteredData(), aes(x = interactionDuration)) +
      geom_histogram(binwidth = 15, fill = "#8172B2", color = "white") +
      labs(title = "Duration of Interaction", x = "Minutes", y = "Frequency")
  })
  
  # ---- Figure 1: Chatbot Family Distribution (Plotly donut) ----
  output$fig1 <- renderPlotly({
    summary <- diaryEntries %>%
      filter(!is.na(chatbotFamily) & chatbotFamily != "") %>%
      count(chatbotFamily) %>%
      mutate(
        prop = round(n / sum(n) * 100, 1),
        label = paste0(chatbotFamily, ": ", prop, "%")
      )
    
    if (nrow(summary) == 0) return(NULL)
    
    plot_ly(
      data = summary,
      labels = ~chatbotFamily,
      values = ~n,
      type = "pie",
      textinfo = "label+percent",
      insidetextorientation = "radial",
      hole = 0.5,
      marker = list(line = list(color = "#FFFFFF", width = 2))
    ) %>%
      layout(
        title = list(text = "Chatbot Family Distribution", x = 0.5),
        showlegend = FALSE,
        margin = list(t = 60, b = 40)
      )
  })
  
  # ---- Reusable donut chart function (tidy-eval safe) ----
  make_donut <- function(df, category_col, title) {
    # capture the column name properly
    category_col <- rlang::enquo(category_col)
    
    # summarize counts safely
    summary <- df %>%
      dplyr::filter(!is.na(!!category_col) & !!category_col != "") %>%
      dplyr::group_by(cat = !!category_col) %>%
      dplyr::summarise(count = dplyr::n(), .groups = "drop") %>%
      dplyr::mutate(
        prop = round(count / sum(count) * 100, 1),
        label = paste0(cat, ": ", prop, "%")
      )
    
    if (nrow(summary) == 0) return(NULL)
    
    # create pure Plotly donut
    plot_ly(
      data = summary,
      labels = ~cat,
      values = ~count,
      type = "pie",
      textinfo = "label+percent",
      insidetextorientation = "radial",
      hole = 0.5,
      marker = list(line = list(color = "#FFFFFF", width = 2))
    ) %>%
      layout(
        title = list(text = title, x = 0.5),
        showlegend = FALSE,
        margin = list(t = 60, b = 40)
      )
  }
  
  # ---- Figure 2: Subscription Type ----
  output$fig2 <- renderPlotly({
    make_donut(diaryEntries, userSubscription, "Subscription Type")
  })
  
  # ---- Figure 3: Interaction Mode ----
  output$fig3 <- renderPlotly({
    make_donut(diaryEntries, interactionMode, "Interaction Mode")
  })
  
  # ---- Figure 8: Social Context ----
  output$fig8 <- renderPlotly({
    make_donut(diaryEntries, socialUse, "Social Context of Chatbot Use")
  })
  
  
  # ---- Figure 4–7 (Bars) ----
  output$fig4 <- renderPlot({
    diaryEntries <- diaryEntries %>%
      mutate(barColor = ifelse(interactionDuration > 120, "#E26D5A", "#8172B2"))
    duration_median <- median(diaryEntries$interactionDuration, na.rm = TRUE)
    max_count <- diaryEntries %>% count(interactionDuration) %>% pull(n) %>% max()
    ggplot(diaryEntries, aes(x = interactionDuration)) +
      geom_histogram(aes(fill = barColor), binwidth = 10, color = "white", alpha = 0.8, show.legend = FALSE) +
      geom_vline(xintercept = duration_median, linetype = "dashed", color = "black", size = 1) +
      annotate("text", x = duration_median + 5, y = max_count,
               label = paste0("Median = ", duration_median, " min"), hjust = 0, size = 4) +
      annotate("text", x = max(diaryEntries$interactionDuration, na.rm = TRUE), y = 1,
               label = "Longest session: ~5 hrs", hjust = 1, size = 4, color = "#E26D5A") +
      labs(x = "Duration (minutes)", y = "Count") +
      theme_minimal()
  })
  
  output$fig5 <- renderPlot({
    ggplot(diaryEntries, aes(x = fct_infreq(usageReasons))) +
      geom_bar(fill = "#CCB974") +
      coord_flip() +
      labs(x = "Reason", y = "Count") +
      theme_minimal()
  })
  
  output$fig6 <- renderPlot({
    ggplot(diaryEntries, aes(x = fct_infreq(locationUsed))) +
      geom_bar(fill = "#64B5CD") +
      coord_flip() +
      labs(x = "Location", y = "Count") +
      theme_minimal()
  })
  
  output$fig7 <- renderPlot({
    ggplot(diaryEntries, aes(x = deviceUsed)) +
      geom_bar(fill = "#937860") +
      labs(x = "Device", y = "Count") +
      theme_minimal()
  })
  
  # ---- Comments table ----
  output$commentTable <- renderDT({
    filteredData() %>%
      select(name, miscUserComments) %>%
      datatable()
  })
}

# Launch app -----------------------------------------------------------
shinyApp(ui, server)