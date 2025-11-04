
# app.R

library(shiny)
library(ggplot2)
library(dplyr)
library(forcats)
library(DT)

# Load your dataset
diaryEntries <- read.csv("cleanedDiaryEntries.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("Mental Health Chatbot Diary Study Dashboard"),

  sidebarLayout(
    sidebarPanel(
      helpText("Explore chatbot usage data from participant diary entries.")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Chatbot Used", plotOutput("chatbotPlot")),
        tabPanel("Subscription Type", plotOutput("subscriptionPlot")),
        tabPanel("Interaction Mode", plotOutput("modePlot")),
        tabPanel("Interaction Duration", plotOutput("durationPlot")),
        tabPanel("Reason for Use", plotOutput("reasonPlot")),
        tabPanel("Location Used", plotOutput("locationPlot")),
        tabPanel("Device Used", plotOutput("devicePlot")),
        tabPanel("Social Use", plotOutput("socialUsePlot")),
        tabPanel("User Comments", DTOutput("commentTable"))
      )
    )
  )
)

server <- function(input, output) {

  output$chatbotPlot <- renderPlot({
    ggplot(diaryEntries, aes(x = fct_infreq(chatbotUsed))) +
      geom_bar(fill = "#4C72B0") +
      coord_flip() +
      labs(title = "Chatbot Used", x = "Chatbot", y = "Count")
  })

  output$subscriptionPlot <- renderPlot({
    ggplot(diaryEntries, aes(x = userSubscription)) +
      geom_bar(fill = "#55A868") +
      labs(title = "Subscription Type", x = "Subscription", y = "Count")
  })

  output$modePlot <- renderPlot({
    ggplot(diaryEntries, aes(x = interactionMode)) +
      geom_bar(fill = "#C44E52") +
      labs(title = "Interaction Mode", x = "Mode", y = "Count")
  })

  output$durationPlot <- renderPlot({
    ggplot(diaryEntries, aes(x = interactionDuration)) +
      geom_histogram(binwidth = 15, fill = "#8172B2", color = "white") +
      labs(title = "Duration of Interaction", x = "Duration (minutes)", y = "Frequency")
  })

  output$reasonPlot <- renderPlot({
    ggplot(diaryEntries, aes(x = fct_infreq(mainUsageReason))) +
      geom_bar(fill = "#CCB974") +
      coord_flip() +
      labs(title = "Main Reason for Chatbot Use", x = "Reason", y = "Count")
  })

  output$locationPlot <- renderPlot({
    ggplot(diaryEntries, aes(x = fct_infreq(locationUsed))) +
      geom_bar(fill = "#64B5CD") +
      coord_flip() +
      labs(title = "Location of Use", x = "Location", y = "Count")
  })

  output$devicePlot <- renderPlot({
    ggplot(diaryEntries, aes(x = deviceUsed)) +
      geom_bar(fill = "#937860") +
      labs(title = "Device Used", x = "Device", y = "Count")
  })

  output$socialUsePlot <- renderPlot({
    ggplot(diaryEntries, aes(x = socialUse)) +
      geom_bar(fill = "#DA8BC3") +
      labs(title = "Social Context of Chatbot Use", x = "Social Use", y = "Count")
  })

  output$commentTable <- renderDT({
    diaryEntries %>% select(Name, miscUserComments) %>% datatable()
  })
}

shinyApp(ui = ui, server = server)
