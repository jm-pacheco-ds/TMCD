library(dplyr)
library(ggplot2)

flights <- tbl_df(read.csv("flights.csv", stringsAsFactors = FALSE))
flights$date <- as.Date(flights$date)

weather <- tbl_df(read.csv("weather.csv", stringsAsFactors = FALSE))
weather$date <- as.Date(weather$date)

planes <- tbl_df(read.csv("planes.csv", stringsAsFactors = FALSE))

airports <- tbl_df(read.csv("airports.csv", stringsAsFactors = FALSE))

flights
weather
planes
airports

##Find all flights:
# TO SFO or OAK
filter(flights, dest %in% c("SFO", "OAK"))

# In January
jan="01"
flights %>% 
  mutate(month = format(date, "%m")) %>%
  filter(month == jan )

#Delated by more than an hour
flights %>%
  filter(dep_delay > 60)

#That departed between midnight and five am
flights %>%
  filter(hour >= 0, hour <=5)

#Where the arrival delay was more than twice the departure delay
flights %>%
  filter(abs(arr_delay) > abs(2*dep_delay))

select(flights, arr_delay, dep_delay)
select(flights, arr_delay:dep_delay)
select(flights, ends_with("delay"))
select(flights, contains("delay"))

#Order the flights by departure date and time
flights %>%
  arrange(date, hour, minute)

#which flights weere most delayed?
flights %>%
  arrange(desc(dep_delay))

#Which flights caught up the most time during the flight?
flights %>%
  arrange(desc(dep_delay - arr_delay))

#Compute speed in mph from time (in minutes) and distance (in miles). Which flight flew the fastest?
flights %>%
  mutate(meanSpeed = dist/(time/60))%>%
  arrange(desc(meanSpeed))

#Add a new variable that shows how much time was made up or lost in flight.
flights %>%
  mutate(flightTime = dep_delay - arr_delay)

#How did I compute hour and minute from dep?
flights %>%
  mutate(hour_ = dep %/% 100) %>%
  mutate(minute_ = dep %% 100)
  
##Grouped Summarise
by_date <- group_by(flights, date)
by_hour <- group_by(flights, date, hour)
by_plane <- group_by(flights, plane)
by_dest <- group_by(flights, dest)

#How might you summarise dep_delay for each day? Brainstorm for 2 minutes.
by_date <- group_by(flights, date)
delays <- summarise(by_date,
  mean = mean(dep_delay, na.rm = TRUE),
  median = median(dep_delay, na.rm = TRUE),
  q75 = quantile(dep_delay, 0.75, na.rm = TRUE),
  over_15 = mean(dep_delay > 15, na.rm = TRUE),
  over_30 = mean(dep_delay > 30, na.rm = TRUE),
  over_60 = mean(dep_delay > 60, na.rm = TRUE)
)

##Pipelines
#Which destinations have the highest average delays?
flights %>%
  group_by(dest) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE),
            n = n()) %>%
  arrange(desc(arr_delay))

#Which flights (i.e. carrier + flight) happen every day? Where do they fly to?
flights %>%
  group_by(carrier, flight, dest) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE),
            n = n()) %>%
  arrange(desc(arr_delay))


#On average, how do delays (of non-cancelled flights) vary over the course of a day?

