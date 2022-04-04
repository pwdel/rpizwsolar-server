# rpizwsolar-server

Server to assist rpizwsolar Project

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

### app

* ```app``` contains everything related to the python application designed to post weather forecast information. 

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
* "weather_id_list": weather_id_string,
## Environment Variables to Be Set

* OPENWEATHERMAP_APIKEY - API from OpenWeatherMap
* DBNAME - Postgres Database Name
* DBUSER - Postgres Database Username
* DBHOST - Postgres Database Host
* DBPASSWORD - Postgres Database Passwords