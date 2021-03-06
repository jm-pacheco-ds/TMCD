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
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  filter(n == 365)
  
#On average, how do delays (of non-cancelled flights) vary over the course of a day?
delays_by_hour <- flights %>%
  filter(cancelled == 0) %>%
  mutate(time = hour + minute / 60) %>%
  group_by(time) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE),
            n = n())

qplot(time, arr_delay, data = delays_by_hour)
qplot(time, arr_delay, data = delays_by_hour, size = n) + scale_size_area()
qplot(time, arr_delay, data = filter(delays_by_hour, n > 30), size = n) + scale_size_area()

ggplot(filter(delays_by_hour, n > 30), aes(time, arr_delay)) +
  geom_vline(xintercept = 5:24, colour = "white", size = 2) +
  geom_point()

#Grouped mutate/filter

planes <- flights %>%
  filter(!is.na(arr_delay)) %>%
  group_by(plane) %>%
  filter(n() > 30)

planes %>%
  mutate(z_delay =
           (arr_delay - mean(arr_delay)) / sd(arr_delay)) %>%
  filter(z_delay > 5)

planes %>% filter(min_rank(arr_delay) < 5)



flights %>% group_by(plane) %>%
  filter(row_number(desc(arr_delay)) <= 2)

flights %>% group_by(plane) %>%
  filter(min_rank(desc(arr_delay)) <= 2)

flights %>% group_by(plane) %>%
  filter(dense_rank(desc(arr_delay)) <= 2)


daily <- flights %>%
  group_by(date) %>%
  summarise(delay = mean(dep_delay, na.rm = TRUE))

daily %>% mutate(lag(delay), delay - lag(delay))

daily %>% mutate(lag(delay), delay - lag(delay), order_by = date)

##Two table verbs
location <- airports %>%
  select(dest = iata, name = airport, lat, long)

flights %>%
  group_by(dest) %>%
  filter(!is.na(arr_delay)) %>%
  summarise(
    arr_delay = mean(arr_delay),
    n = n()
  ) %>%
  arrange(desc(arr_delay)) %>%
  left_join(location)


x <- data.frame(
  name = c("John", "Paul", "George", "Ringo", "Stuart", "Pete"),
  instrument = c("guitar", "bass", "guitar", "drums", "bass",
                 "drums")
)

y <- data.frame(
  name = c("John", "Paul", "George", "Ringo", "Brian"),
  band = c("TRUE", "TRUE", "TRUE", "TRUE", "FALSE")
)

hourly_delay <- flights %>%
  group_by(date, hour) %>%
  filter(!is.na(dep_delay)) %>%
  summarise(
    delay = mean(dep_delay),
    n = n()
  ) %>%
  filter(n > 10)
delay_weather <- hourly_delay %>% left_join(weather)

#What weather conditions are associated with delays leaving houston
qplot(temp, delay, data = delay_weather)
qplot(wind_speed, delay, data = delay_weather)
qplot(gust_speed, delay, data = delay_weather)
qplot(is.na(gust_speed), delay, data = delay_weather,
      geom = "boxplot")
qplot(conditions, delay, data = delay_weather,
      geom = "boxplot")
qplot(events, delay, data = delay_weather,
      geom = "boxplot")


## DO
library(dplyr)
library(zoo)
df <- data.frame(
  houseID = rep(1:10, each = 10),
  year = 1995:2004,
  price = ifelse(runif(10 * 10) > 0.50, NA, exp(rnorm(10 * 10)))
)

df %>%
  group_by(houseID) %>%
  do(na.locf(.))

df %>%
  group_by(houseID) %>%
  do(head(., 2))

df %>%
  group_by(houseID) %>%
  do(data.frame(year = .$year[1]))

