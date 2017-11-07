setwd("~/MAIN/MA/Analytics Dojo/") ### Set this to whatever directory you want
library(fcuk)
library(ggplot2)
library(dplyr)
library(RGoogleAnalytics)
library(ggfortify)
library(forecast)

# Step One: Authorize

### Do this at https://console.developers.google.com/apis/dashboard
### Go to Google analytics and authorize the Google Analytics API to send and receive information

# Step Two: Authenticate

token <- Auth("294470013201-qrdobt7mfpffbvpcfsfsap74grr94566.apps.googleusercontent.com", "02fVFZSrSLhZQRv4ZAgVFCvY") # first Client ID, then Client Secret

save(token,file="./token_file") # This will save the token on your computer so you do not need to authenticate everytime

ValidateToken(token) # Checks if the token is valid

GetProfiles(token) # Check to see which profiles exist on the account

### In this case, id 107460317 is the correct id that corresponds to the CareerLaunch view

# Step Three: Construct your queries

### Test out different queries with a GUI: https://ga-dev-tools.appspot.com/query-explorer/
### Names of dimensions and metrics: https://developers.google.com/analytics/devguides/reporting/core/dimsmets # Referece this when building your queries

Q.Users2017 <- Init(start.date = "2017-08-02",
                  end.date = as.Date(Sys.time()), # This returns the current date
                  dimensions = "ga:date", # This is your date column
                  metrics = "ga:users, ga:sessions, ga:avgTimeOnPage", # These are the site measurements you want to examine
                  max.results = 10000,
                  table.id = "ga:107460317") # This is the Google Analytics ID that contains the view for your website


Q.Users2016 <- Init(start.date = "2016-08-02",
                end.date = (as.Date(Sys.time())-365), # This returns the current date minus a year
                dimensions = "ga:date", # This is your date column
                metrics = "ga:users, ga:sessions, ga:avgTimeOnPage", # These are the site measurements you want to examine
                max.results = 10000,
                table.id = "ga:107460317") # This is the Google Analytics ID that contains the view for your website

# Step Four: Execute the Query (the query you just made)
## Build the query so Google Analytics can read it
ga.query <- QueryBuilder(Q.Users2017)
ga.query2 <- QueryBuilder(Q.Users2016)

## Fire the Query to the GA API, and reorder the result
ga.df <- GetReportData(ga.query, token, split_daywise = T) # Set Split_daywise = True to get unsampled, true data for each day
ga.df <- ga.df[order(as.numeric(ga.df$date)),] # Reorder by date descending

ga.df1 <- GetReportData(ga.query2, token, split_daywise = T) # Set Split_daywise = True to get unsampled, true data for each day
ga.df1 <- ga.df1[order(as.numeric(ga.df1$date)),] # Reorder by date descending

# Step Five: Create a time series object from your dataframe
StartDateNum17 <- as.numeric(format(as.Date("2017-08-01"), "%j"))
StartDateNum16 <- as.numeric(format(as.Date("2016-08-01"), "%j"))

user.ts17 <- ts(ga.df[,"users"], start = c(2017,StartDateNum17), frequency = 365)
autoplot(user.ts17, facets = T)

user.ts16 <- ts(ga.df1[,"users"], start = c(2016,StartDateNum16), frequency = 365)
autoplot(user.ts16, facets = T)

averageTime.ts17 <- ts(ga.df[,"avgTimeOnPage"], start = c(2017,StartDateNum17), frequency = 365)
autoplot(averageTime.ts17, facets = T)

averageTime.ts16 <- ts(ga.df1[,"avgTimeOnPage"], start = c(2016,StartDateNum16), frequency = 365)
autoplot(averageTime.ts16, facets = T)

