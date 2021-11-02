# Load required libraries
require(leaflet)


# Create a RShiny UI
shinyUI(
  fluidPage(padding=5,
  titlePanel("Bike-sharing demand prediction app"),
  # Create a side-bar layout
  sidebarLayout(
    # Create a main panel to show cities on a leaflet map
    mainPanel(leafletOutput("city_bike_map", width = 800, height =1000 )),
    # Create a side bar to show detailed plots for a city
    sidebarPanel(selectInput("City", inputId="city_dropdown", choices = vars)
      # select drop down list to select city
    ))
))
