### This script allows you to interact with Google Analytics data and stream it into R
rm(list = ls())

setwd("~/MAIN/MA/Analytics Dojo/") ### Set this to whatever directory you want
library(fcuk)
library(ggplot2)
library(dplyr)
library(RGoogleAnalytics)
library(ggfortify)
library(forecast)
library(fpp2)

# Step One: Authorize

### Get your cliend ID and secret at https://console.developers.google.com/apis/dashboard
### Go to Google analytics and authorize the Google Analytics API to send and receive information

<<<<<<< HEAD
token <- Auth("Your ClientID Here", "Your Client Secret Here") # first Client ID, then Client Secret

save(token,file="./token_file") # This will save the token on your computer so you do not need to authenticate everytime

ValidateToken(token)

# Step Two: Authenticate

#### This is done in a setup file usually to protect your ClientID and ClientSecret
=======
# Step Two: Authenticate

## The token object should come from your setup.R file, in which you add the ClientID and ClientSecret to get your access token
>>>>>>> c50a0b2e8ae461cce75b30fab2d8c101a2d52c70

GetProfiles(token) # Check to see which profiles exist on the account

### Use GetProfiles to find which id you need to use. Each id corresponds to a website domain in Google Analytics
### In this case, id 107460317 is the correct id that corresponds to the CareerLaunch view

# Step Three: Construct your queries

### Test out different queries with a GUI: https://ga-dev-tools.appspot.com/query-explorer/
### Names of dimensions and metrics: https://developers.google.com/analytics/devguides/reporting/core/dimsmets # Referece this when building your queries

Q.Users2017 <- Init(start.date = "2017-09-02", # GA will return data for the day before this date
                  end.date = as.Date(Sys.time()), # This returns the current date
                  dimensions = "ga:date", # This is your date column
                  metrics = "ga:users, ga:sessions, ga:avgTimeOnPage, ga:avgSessionDuration", # These are the site measurements you want to examine
                  max.results = 10000,
                  table.id = "ga:107460317") # This is the Google Analytics ID that contains the view for your website


Q.Users2016 <- Init(start.date = "2016-09-02", # GA will return data for the day before this date
                end.date = (as.Date(Sys.time())-365), # This returns the current date minus a year
                dimensions = "ga:date", # This is your date column
                metrics = "ga:users, ga:sessions, ga:avgTimeOnPage, ga:avgSessionDuration", # These are the site measurements you want to examine
                max.results = 10000,
                table.id = "ga:107460317") # This is the Google Analytics ID that contains the view for your website

Q.Users16_17 <- Init(start.date = "2016-09-02", # GA will return data for the day before this date
                    end.date = "2017-04-26", # This returns the current date minus a year
                    dimensions = "ga:date", # This is your date column
                    metrics = "ga:users, ga:sessions, ga:avgTimeOnPage, ga:avgSessionDuration", # These are the site measurements you want to examine
                    max.results = 10000,
                    table.id = "ga:107460317") # This is the Google Analytics ID that contains the view for your website

# Step Four: Execute the Query (the query you just made)
## Build the query so Google Analytics can read it
ga.query <- QueryBuilder(Q.Users2017)
ga.query2 <- QueryBuilder(Q.Users2016)
ga.query3 <- QueryBuilder(Q.Users16_17)

## Fire the Query to the GA API, and reorder the result
ga.df <- GetReportData(ga.query, token, split_daywise = T) # Set Split_daywise = True to get unsampled, true data for each day
ga.df <- ga.df[order(as.numeric(ga.df$date)),] # Reorder by date descending

ga.df1 <- GetReportData(ga.query2, token, split_daywise = T) # Set Split_daywise = True to get unsampled, true data for each day
ga.df1 <- ga.df1[order(as.numeric(ga.df1$date)),] # Reorder by date descending

ga.df2 <- GetReportData(ga.query3, token, split_daywise = T) # Set Split_daywise = True to get unsampled, true data for each day
ga.df2 <- ga.df2[order(as.numeric(ga.df2$date)),] # Reorder by date descending


# Step Five: Create a time series object from your dataframe and plot

## Use these to find out what day number in a year a certain date is (i.e. "2017-09-01" is day number 244)
StartDateNum17 <- as.numeric(format(as.Date("2017-09-01"), "%j"))
StartDateNum16 <- as.numeric(format(as.Date("2016-09-01"), "%j"))
EndDateNum17 <- as.numeric(format(as.Date("2017-04-26"), "%j"))

## First, we will look at the amount of unique users in on the site, year over year
user.ts17 <- ts(ga.df[,"users"], start = c(2017,StartDateNum17), frequency = 365)
autoplot(user.ts17, facets = T)

user.ts16 <- ts(ga.df1[,"users"], start = c(2016,StartDateNum16), frequency = 365)
autoplot(user.ts16, facets = T)

## Next, we will look at the average time on page (for any page they visit in a session) on the site, year over year
averageTime.ts17 <- ts(ga.df[,"avgTimeOnPage"], start = c(2017,StartDateNum17), frequency = 365)
autoplot(averageTime.ts17, facets = T)

averageTime.ts16 <- ts(ga.df1[,"avgTimeOnPage"], start = c(2016,StartDateNum16), frequency = 365)
autoplot(averageTime.ts16, facets = T)

## Next, we will look at the average session duration on the site, year over year
averageSess.ts17 <- ts(ga.df[,"avgSessionDuration"], start = c(2017,StartDateNum17), frequency = 365)
autoplot(averageSess.ts17, facets = T)

averageSess.ts16 <- ts(ga.df1[,"avgSessionDuration"], start = c(2016,StartDateNum16), frequency = 365)
autoplot(averageSess.ts16, facets = T)

## Finally, lets look at the past business year in total, from 2016-09-01 to 2017-04-26
user.ts16_17 <- ts(ga.df2[,"users"], start = c(2016,StartDateNum16), frequency = 365)
autoplot(user.ts16_17, facets = T)

averageTime.ts16_17 <- ts(ga.df2[,"avgTimeOnPage"], start = c(2016, StartDateNum16), frequency = 365)
autoplot(averageTime.ts16_17, facets = T)

averageSess.ts16_17 <- ts(ga.df2[,"avgSessionDuration"], start = c(2016, StartDateNum16), frequency = 365)
autoplot(averageSess.ts16_17, facets = T)

## 
gglagplot(user.ts16_17)
ggAcf(user.ts16_17)
## Is there a pattern here?





