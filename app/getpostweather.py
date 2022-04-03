#!/usr/bin/python3
# the above is added because this could be used as a python executable
import requests
import json as js
from datetime import datetime
from dotenv import load_dotenv
import pytz
import psycopg2
import os

# load environmental variables from .env file
load_dotenv()

# get environmental variables from environment
OPENWEATHERMAP_APIKEY = os.getenv('OPENWEATHERMAP_APIKEY')
DBNAME = os.getenv('DBNAME')
DBUSER = os.getenv('DBUSER')
DBHOST = os.getenv('DBHOST')
DBPASSWORD = os.getenv('DBPASSWORD')
# put together in database auth string
databaseauthstring = "dbname="+DBNAME+" user="+DBUSER+" host="+DBHOST+" password="+DBPASSWORD

# concatenate string for URL including env
openweathermapurl = 'https://api.openweathermap.org/data/2.5/onecall?lat=44.902748&lon=-92.783539&exclude=minutely&appid='+OPENWEATHERMAP_APIKEY
# http request to openweathermap API
onecall = requests.get(openweathermapurl)

# convert json object into dictionary
onecallextractedjson = js.loads(onecall.content)

def current_weather(extractedjson):
    # start with empty current weather dictionary
    currentweatherdict={}
    # extract current time within timezone measured in postfix
    curr_dt = extractedjson['current']['dt']
    # timnezone
    tz = pytz.timezone(extractedjson['timezone'])
    # datetime in 8601 format
    currentweatherdict['curr_iso_dt'] = datetime.fromtimestamp(curr_dt,tz).isoformat()
    # temperature in celcius
    currentweatherdict['curr_temp_c'] = round((extractedjson['current']['temp']-273.15),3)
    # pressure
    currentweatherdict['curr_pressure'] = extractedjson['current']['pressure']
    # humidity
    currentweatherdict['curr_humidity'] = extractedjson['current']['humidity']
    # dewpoint
    currentweatherdict['curr_dew_point'] = round((extractedjson['current']['dew_point']-273.15),3)
    # clouds
    currentweatherdict['curr_clouds'] = extractedjson['current']['clouds']
    # windspeed
    currentweatherdict['curr_wind_speed'] = extractedjson['current']['wind_speed']
    # wind_deg
    currentweatherdict['curr_wind_deg'] = extractedjson['current']['wind_deg']
    # weather_id
    currentweatherdict['curr_weather_id'] = extractedjson['current']['weather'][0]['id']
    # weather_description
    currentweatherdict['curr_weather_description'] = extractedjson['current']['weather'][0]['description']
    # return the current weather dictionary and timezone
    return currentweatherdict,tz

# run current weather function
currentweatherdictoutput,timezone = current_weather(onecallextractedjson)
# print current weather dictionary output
print(currentweatherdictoutput)

def forecast_weather(extractedjson,tz):
    # forecasted weather dictioanry
    forecastweatherdict = {}
    # extract hourly items from the extracted json object
    forecast_weather_hourly = extractedjson['hourly']
    # get the length of the hourly data, e.g. total hourly entries
    forecast_weather_hourly_len = len(forecast_weather_hourly)
    # setup dictionary of lists containing iso time, clouds forecast, weatherid, weather description
    # This is the format we need: data = {'col_1': [3, 2, 1, 0], 'col_2': ['a', 'b', 'c', 'd']}
    iso_dt_list = []
    temp_list = []
    clouds_list = []
    weather_id_list = []
    weather_description_list = []
    # for loop throughout length of forecast_weather_hourly elements
    # create lists of all data types
    for i in range(0,forecast_weather_hourly_len):
        # datetime in 8601 format
        iso_dt = datetime.fromtimestamp(forecast_weather_hourly[i]['dt'],tz).isoformat()
        # append to iso_dt_list
        iso_dt_list.append(iso_dt)
        # append temp forecast to list
        temp_list.append(str(round(forecast_weather_hourly[i]['temp']-273.15,3)))
        # append clouds to list, convert to string so can be joined into large string for database entry
        clouds_list.append(str(forecast_weather_hourly[i]['clouds']))
        # append weather type id to list, convert to string so can be joined into large string for database entry
        weather_id_list.append(str(forecast_weather_hourly[i]['weather'][0]['id']))
        # append weather type description to list
        # weather_description_list.append(forecast_weather_hourly[i]['weather'][0]['description'])

    # turn lists into strings
    iso_dt_string = ",".join(iso_dt_list)
    temp_string = ",".join(temp_list)
    clouds_string = ",".join(clouds_list)
    weather_id_string = ",".join(weather_id_list)
    # weather_description_string = ",".join(weather_description_list)

    # enter list values into dictionary format for later extraction into pd.dataframe
    forecastweatherdict = {
    "iso_dt_list": iso_dt_string,
    "temp_list": temp_string,
    "clouds_list" : clouds_string,
    "weather_id_list": weather_id_string,
    # "weather_description": weather_description_string
    }
    # return dictionary of above data
    return(forecastweatherdict)

# create the forecast weather dictionary output
forecastweatherdictoutput = forecast_weather(onecallextractedjson,timezone)
# print forecasted output
print('forecastweatherdictoutput iso_dt:',forecastweatherdictoutput['iso_dt_list'])


# insert currentweatherdictoutput items into curretnweather
# curr_iso_dt | curr_temp_c | curr_pressure | curr_humidity | curr_dew_point | curr_clouds | curr_wind_speed | curr_wind_deg | curr_weather_id | curr_weather_description
def insert_current_weather(currentweatherdictoutput,databaseauthstring):
    
    # get the keys/columns of the dictioanry
    columns = currentweatherdictoutput.keys()
    print(columns)
    print(currentweatherdictoutput)

    # create a list to put into values later
    currentweatherlistoutput=[]
    for i in currentweatherdictoutput.values():
        currentweatherlistoutput.append(i)

    # create SQL command
    sql = """INSERT INTO currentweather VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) ;"""    

    conn = None
    try:
        # read database configuration
        # connect to the PostgreSQL database
        conn = psycopg2.connect(databaseauthstring)
        # create a new cursor
        cur = conn.cursor()
        # execute the INSERT statement
        cur.execute(sql,currentweatherlistoutput)
        # commit the changes to the database
        conn.commit()
        # close communication with the database
        cur.close()
        # print success message
        print('successfully entered into database')
    except (Exception, psycopg2.DatabaseError) as error:
        print("psycopg2.DatabaseError: ",error)
    finally:
        if conn is not None:
            conn.close()

# call insert_current_weather() to put in database
insert_current_weather(currentweatherdictoutput,databaseauthstring)


# insert forecastweather items into forecastweather
# curr_iso_dt | curr_temp_c | curr_pressure | curr_humidity | curr_dew_point | curr_clouds | curr_wind_speed | curr_wind_deg | curr_weather_id | curr_weather_description
def insert_forecast_weather(forecastweatherdictoutput,curr_iso_dt,databaseauthstring):
    
    # get the keys/columns of the dictioanry
    columns = forecastweatherdictoutput.keys()
    print(columns)
    print(forecastweatherdictoutput)

    # create a list to put into values later
    forecastweatheroutput=[curr_iso_dt]
    for i in forecastweatherdictoutput.values():
        forecastweatheroutput.append(i)

    # create SQL command
    sql = """INSERT INTO forecastweather VALUES (%s,%s,%s,%s,%s) ;"""    

    conn = None
    try:
        # read database configuration
        # connect to the PostgreSQL database
        conn = psycopg2.connect(databaseauthstring)
        # create a new cursor
        cur = conn.cursor()
        # execute the INSERT statement
        cur.execute(sql,forecastweatheroutput)
        # commit the changes to the database
        conn.commit()
        # close communication with the database
        cur.close()
        # print success message
        print('successfully entered into database')
    except (Exception, psycopg2.DatabaseError) as error:
        print("psycopg2.DatabaseError: ",error)
    finally:
        if conn is not None:
            conn.close()


# get current datetime (repeat of operation within current_weather(extractedjson): )
curr_dt = onecallextractedjson['current']['dt']
# timnezone
tz = pytz.timezone(onecallextractedjson['timezone'])
# datetime in 8601 format
curr_dt_iso_fmt = datetime.fromtimestamp(curr_dt,tz).isoformat()

# call insert_forecast_weather() to put in database
insert_forecast_weather(forecastweatherdictoutput,curr_dt_iso_fmt,databaseauthstring)
