
# 🧠 Mental Health Chatbot Diary Study Dashboard

This repository contains an interactive [R Shiny](https://shiny.posit.co/) dashboard for visualizing data from a qualitative diary study on how participants use AI chatbots for mental health support.
---

## Features

- Visual summaries of:
  - Chatbot model used
  - Subscription type (Free / Paid)
  - Mode of interaction (Text, Voice, Mixed)
  - Duration of use
  - Primary reason for usage
  - Location and device used
  - Social context (alone/private/shared)
- Optional table view of free-text participant reflections

---

## Project Structure

```
📁 mhc-chatbot-diary-dashboard/
├── app.R                               # Main R Shiny dashboard
├── .gitignore                          # Protects raw data from accidental upload
├── mental_health_chatbot_data_dictionary.md   # Full variable definitions
├── example_diary_entries.csv          # Anonymized sample dataset (for testing/demo)
└── README.md                          # You’re here
```

---

## Getting Started

### Prerequisites

- R ≥ 4.0
- R packages: `shiny`, `ggplot2`, `dplyr`, `forcats`, `DT`

Install packages if needed:
```r
install.packages(c("shiny", "ggplot2", "dplyr", "forcats", "DT"))
```

### Run the app locally

```r
shiny::runApp("app.R")
```

To run from RStudio: open `app.R` and click **Run App**.

---

## Data Handling & Privacy

 **Raw data files (e.g., `cleanedDiaryEntries.csv`) must never be committed to this repository.**  

To protect participant privacy:
	- A .gitignore file is in place to block raw CSVs and any data-raw/ directories
	- No synthetic or anonymized example dataset is currently included

---

## Dataset Variables

See [`mental_health_chatbot_data_dictionary.md`](./mental_health_chatbot_data_dictionary.md) for a full codebook with definitions and examples.

---

## Contact

Maintained by Briana Vecchione  
Data & Society Research Institute  
[brianavecchione.org](https://brianavecchione.org/)
