# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  #Test generate_city_weather_bike_data() function
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}

# Create a RShiny server
shinyServer(function(input, output){
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), levels = c("small", "medium", "large"))
  city_weather_bike_df <- test_weather_data_generation()
  
  # Create another data frame 
  cities_max_bike <- city_weather_bike_df %>%
    group_by(CITY_ASCII,LAT,LNG,BIKE_PREDICTION,BIKE_PREDICTION_LEVEL,LABEL,DETAILED_LABEL,FORECASTDATETIME,TEMPERATURE ) %>%
    summarize(count = n(),max = max(BIKE_PREDICTION, na.rm = TRUE))
  
  
  # Observe 
  observeEvent(input$city_dropdown,
               if(input$city_dropdown == 'All') {
                 # circle markers and popup weather LABEL for all five cities
                 output$city_bike_map <- renderLeaflet({
                   leaflet(cities_max_bike) %>%
                     addTiles() %>%
                     addCircleMarkers(data = cities_max_bike, lng = cities_max_bike$LNG, lat = cities_max_bike$LAT, popup = cities_max_bike$LABEL )
                   })    
                   output$temp_line <- renderPlot({
                     ggplot(city_weather_bike_df, aes(FORECASTDATETIME, TEMPERATURE, label = TEMPERATURE)) + geom_line() + geom_point() + geom_text()
                   })  
                   output$bike_line <- renderPlot({
                   ggplot(city_weather_bike_df, aes(FORECASTDATETIME, BIKE_PREDICTION, label = TEMPERATURE)) + geom_line() + geom_point() + geom_text()
                   
                   }) 
                    
                 
                  #one marker on the map and popup DETAILED_LABEL 
               }     else  {
                 output$city_bike_map <- renderLeaflet({
                   leaflet(cities_max_bike) %>%
                     addTiles() %>%
                     addMarkers(lng = ~LNG, lat = ~LAT, 
                                      radius= ~ifelse(BIKE_PREDICTION_LEVEL=='small', 6, 12),color = ~color_levels(BIKE_PREDICTION_LEVEL),stroke = FALSE,
                                      fillOpacity = 0.8,label=~CITY_ASCII,popup = city_weather_bike_df$DETAILED_LABEL)
                 })
                   #add a temperature trend plot using renderPlot(...) function with following configurations:
                 output$temp_line <- renderPlot({
                   ggplot(city_weather_bike_df, aes(FORECASTDATETIME, TEMPERATURE, label = TEMPERATURE)) + geom_line() + geom_point() + geom_text()
                   
                 })
                 output$bike_line <- renderPlot({
                   ggplot(city_weather_bike_df, aes(FORECASTDATETIME, BIKE_PREDICTION, label = TEMPERATURE)) + geom_line() + geom_point() + geom_text()}) 
                 
                                                                }
              
               ) } ) 
  
    




