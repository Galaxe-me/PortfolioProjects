## installing packages
install.packages("tidyverse")
install.packages("lubridate")
install.packages("readxl")
## loading packages
library(tidyverse)
library(lubridate)
library(readxl)
## looking the directory and setting my own
getwd()
setwd("C:/Users/pedro/OneDrive/Desktop/Bike_case/Treated_data")
## loading the data
q3_2019 <- read_excel("Project_data1.xlsx")
q4_2019 <- read_excel("Project_data2.xlsx")
q1_2020 <- read_excel("Project_data3.xlsx")
q2_2020 <- read_excel("Project_data4.xlsx")
## looking at the data
str(q3_2019)
str(q4_2019)
str(q1_2020)
str(q2_2020)
## preparing the data to merge all tables
q4_2019 <- mutate(q4_2019, start_lat = as.numeric(start_lat), start_lng = as.numeric(start_lng),
                  end_lat = as.numeric(end_lat), end_lng = as.numeric(end_lng))
drop_na(q1_2020)
q1_2020 <- mutate(q1_2020, start_station_id = as.numeric(start_station_id),
                  end_station_id = as.numeric(end_station_id),
                  end_lat = as.numeric(end_lat), end_lng = as.numeric(end_lng))
drop_na(q2_2020)
q2_2020 <- mutate(q2_2020, start_station_id = as.numeric(start_station_id),
                  end_station_id = as.numeric(end_station_id),
                  end_lat = as.numeric(end_lat), end_lng = as.numeric(end_lng))
## merging the data into a single table
all_trips <- bind_rows(q3_2019, q4_2019, q1_2020, q2_2020)
## droping useless columns
all_trips <- all_trips %>%  
  select(-c(start_lat, start_lng, end_lat, end_lng, day, ...17))
colnames(all_trips)
drop_na(all_trips)
all_trips <- all_trips %>%
  select(-c(day, ...17))
## checking the data, rows, columns
nrow(all_trips)
dim(all_trips)
str(all_trips)
summary(all_trips)
## inserting new columns as month, day, year, and day of the week 
all_trips$month <- format(as.Date(all_trips$started_at), "%m")
all_trips$day <- format(as.Date(all_trips$started_at), "%d")
all_trips$year <- format(as.Date(all_trips$started_at), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$started_at), "%A")
## ride length in seconds in the trips_duration column
all_trips$trip_duration <- difftime(all_trips$ended_at,all_trips$started_at)
## checking the data type and assuring the trip_duration column is a numeric column to make calculation
str(all_trips)
is.factor(all_trips$trip_duration)
all_trips$trip_duration <- as.numeric(as.character(all_trips$trip_duration))
is.numeric(all_trips$trip_duration)
## removing bad data (trip_duration <0, and bikes removed to fix or checking)
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$trip_duration<=0),]
## checking the data and statistics
summary(all_trips)
summary(all_trips_v2)
## looking into aggregated data, accorindg to the stastistic
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual, FUN = min)
aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
## organizing the aggregated data in days of the week
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("domingo", "segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado"))
## analyze ridership data by type and weekday, creating weekday field, grouping by usertype and weekday, calculates the number of rides and average duration
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n(), average_duration = mean(trip_duration)) %>%
  arrange(member_casual, weekday)	
## visualizing the data above
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(trip_duration)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")
## visualizing by average duration
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(trip_duration)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")
## exporting the file
counts <- aggregate(all_trips_v2$trip_duration ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
write.csv(counts, file = 'C:/Users/pedro/OneDrive/Desktop/Bike_case/Treated_data/avg_ride_length.csv')
