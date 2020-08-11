library(shinydashboard)
library(mapview)
library(plainview)
library(shiny)
library(leaflet)

ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    titlePanel("PM2.5 Spatial Variation in Delhi 2019"),
    leafletOutput("mapplot",width = "100%", height = "100%"),
    plainViewOutput("test"),
    absolutePanel(top = 10, right = 10,
                  sliderInput("slider", "Time", min = as.Date("2019-01-01"),max =as.Date("2019-12-31"),
                              value=as.Date("2019-01-01"),timeFormat="%B %Y")
    )
)
