#SHINY APP HOSTING DASHBOARD: https://www.shinyapps.io/admin/#/dashboard

#Rshiny Dashboard
shiny::runApp("/Users/brianavecchione/Desktop/MHC/mhc-diary-dashboard/app.R")

library(shiny)
library(tidyverse)
library(DT)
library(ggplot2)
library(dplyr)
library(forcats)

# Load data
diaryEntries <- read.csv("/Users/brianavecchione/Desktop/MHC/mhc-diary-dashboard/cleanedDiaryEntries.csv")

#remove unnecessary columns
diaryEntries <- diaryEntries[, !(names(diaryEntries) %in% c("timestamp", 
                                                            "usageCircumstance", 
                                                            "audioOption_1", 
                                                            "audioOption_2", 
                                                            "chatLog", 
                                                            "audioOption_3", 
                                                            "email"))]

#Figure 1: What chatbot(s) did you use?
#NOTE: roll into mixed -- too many categories
ggplot(diaryEntries, aes(x = fct_infreq(chatbotUsed))) +
  geom_bar(fill = "#4C72B0") +
  coord_flip() +
  labs(title = "Chatbot Used", x = "Chatbot", y = "Count")

#Figure 2: Free or paid version?
ggplot(diaryEntries, aes(x = userSubscription)) +
  geom_bar(fill = "#55A868") +
  labs(title = "Subscription Type", x = "Subscription", y = "Count")

#Figure 3: Mode of interaction (text/voice/mixed)
ggplot(diaryEntries, aes(x = interactionMode)) +
  geom_bar(fill = "#C44E52") +
  labs(title = "Interaction Mode", x = "Mode", y = "Count")

#Figure 4: Duration of interaction (in minutes)
#NOTE: DOESNT COMPILE
ggplot(diaryEntries, aes(x = interactionDuration)) +
  geom_histogram(binwidth = 15, fill = "#8172B2", color = "white") +
  labs(title = "Duration of Interaction", x = "Duration (minutes)", y = "Frequency")

#Figure 5: Reason(s) for chatbot use
#NEED TO TRANSFORM + SPLIT
ggplot(diaryEntries, aes(x = fct_infreq(usageReasons))) +
  geom_bar(fill = "#CCB974") +
  coord_flip() +
  labs(title = "Main Reason for Chatbot Use", x = "Reason", y = "Count")

#Figure 6: Location of interaction
ggplot(diaryEntries, aes(x = fct_infreq(locationUsed))) +
  geom_bar(fill = "#64B5CD") +
  coord_flip() +
  labs(title = "Location of Use", x = "Location", y = "Count")

#Figure 7: Device used
ggplot(diaryEntries, aes(x = deviceUsed)) +
  geom_bar(fill = "#937860") +
  labs(title = "Device Used", x = "Device", y = "Count")

#Figure 8: Social use (alone/shared/unknown)
ggplot(diaryEntries, aes(x = socialUse)) +
  geom_bar(fill = "#DA8BC3") +
  labs(title = "Social Context of Chatbot Use", x = "Social Use", y = "Count")
