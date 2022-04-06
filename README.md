# rpizwsolar-server

Server to assist rpizwsolar Project!

## Overivew

* getpostweather.py does a get request to OpenWeatherMap OneCall API every hour at the minute mark, organizes the data into, "current weather" readings and "48 hour forecasted weather" readings and posts readings to a remote Postgres database on ElephantSQL.
* Both current and forecasted weather readings share the same, "read" datetime timestamp, but forecasted timestamps are at the hour mark. So for eample, an API request at 7:01AM CST would show the, "current weather collected," and "forecast collected," timestamp at 7:01 AM CST, but the forecast for the next 48 hours would be at 8:00AM CST, 9:00AM CST, etc. in precisely one hour intervals over the next 48 hours.
* The weather datapoints we are collecting are temperature, pressure, humidity, dewpoint, clouds on a scale from 0-100, windspeed, wind direction and weather type.
* The list of weather conditions can be found [here](https://openweathermap.org/weather-conditions) or [here](/WEATHERCODES.md)
## Building the Docker Image

Within the same directory as the Dockerfile:

```
docker build -t rpizwsolar_server_image:latest .
```

## Running the Docker Container, Binding Code in Dev Mode

Within the same directory as the docker-compose.yml file:

```
docker-compose up -d
```
### Exec Into Container in Dev Mode

```
docker exec -it rpizwsolar_server_container  /bin/bash
```

## Folder Structure

### /home/app

* ```/home/app``` contains everything related to the python application designed to post weather forecast information. 

### /home/bin

* ```/home/bin``` contains important, system level-stuff, an entrypoint 

## Database Breakdown

### currentweather table

* curr_iso_dt
* curr_temp_c
* curr_pressure
* curr_humidity
* curr_dew_point
* curr_clouds
* curr_wind_speed
* curr_wind_deg
* curr_weather_id
* curr_weather_description

### forecastweather table

* curr_iso_dt
* "iso_dt_list": iso_dt_string,
* "temp_list": temp_string,
* "clouds_list" : clouds_string,
* "weather_id_list": weather_id_string

### SQL Commands Used to Create Tables

* 
## Environment Variables to Be Set

* OPENWEATHERMAP_APIKEY - API from OpenWeatherMap
* DBNAME - Postgres Database Name
* DBUSER - Postgres Database Username
* DBHOST - Postgres Database Host
* DBPASSWORD - Postgres Database Passwords

## Troubleshooting

### Verifying Cron Job is Working

* getweatherpost.py is scheduled as a cron job by the Docker Image, which starts through an entrypoint script.
* cron by default does not see the normal linux $PATH environment variable, but rather a specific PATH must be set within the actual crontab file in order for cron to be aware of $PATH.
* we set the PATH=/home/app/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin so that the cron job can easily access the contents of /home/app where the getpostweather.py resides.
* there is also a cron job printing the cron-aware $PATH to /tmp/env.output every minute. So to verify that the cron job is actually working, while logged into the container shell, run:

```
cat /tmp/env.output
```
The output should include the env variables for cron, including precisely ```PATH=/home/app/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin```.
