library("RSQLite")
library("ggplot2")

## Set directory to YOUR computer and folder
setwd("~/Documents/Courses/workspace/DALab3/DataAnalytics-Lab3/MovieData")
system("ls *.db", show=TRUE)

## Connect database
sqlite <- dbDriver("SQLite")
moviesDB <- dbConnect(sqlite,"movies.db")

## Show tables list
dbListTables(moviesDB) 

## Select data group by year.
query <- dbSendQuery(moviesDB, "SELECT year, AVG(budget) AS avg_budget, AVG(domestic) AS avg_domestic, AVG(worldwide) AS avg_worldwide,COUNT() AS count FROM budget GROUP BY year HAVING count >5 AND year < 2016")
numberYear <- dbFetch(query, n=-1)

## Using simple linear regression to generate the exponetional fit curve.
yearCount.lm <- lm(log(count)~1 + year,data=numberYear)

## Show the linear regression result p-value =2.2e-16 < 0.05
summary(yearCount.lm)

## Tried to use nls simple nonlinear least squares fit but failed.
#yearCount.exp <- nls(count~a*exp(b*year+c), start=list(a=1.2,b=yearCount.lm$coefficients[2],c=yearCount$coefficients[1]), data=numberYear)

## Generate data for the fit curve.
yearCount.result<-data.frame(x=year,y=exp(yearCount.lm$coefficients[2]*year+yearCount.lm$coefficients[1])) 

## Create a graph for this dataframe YEAR vs Number of movies.
## They seem to have a exponetional relation, number of movies increases exponetionally along with year.
ggplot() +
  geom_point(data = numberYear, aes(year,count)) +
  geom_line(data = yearCount.result, aes(x, y)) 
#  + scale_y_log10()  ## change the curve into linear.

## Selecting data to create graph shows relations between worldwide gross and decades.
queryBudget<-dbSendQuery(moviesDB,"SELECT * FROM budget WHERE year < 2010 ORDER BY year")
bugetTable<-dbFetch(queryBudget, n=-1)
bugetTable$decade <- bugetTable$year%/%10   #Generate column decade in the dataframe.

## Generating season in the datafram as a factor to classify worldwide gross.
for(i in 1:length(bugetTable$month)){
  if((bugetTable$month[i]>=1) && (bugetTable$month[i]<4)) bugetTable$season[i] <- 1
  if((bugetTable$month[i]>=4) && (bugetTable$month[i]<7)) bugetTable$season[i] <- 2
  if((bugetTable$month[i]>=7) && (bugetTable$month[i]<10)) bugetTable$season[i] <- 3
  if((bugetTable$month[i]>=10) && (bugetTable$month[i]<12)) bugetTable$season[i] <- 4
}

## Generating boxpot showing the relation between worldwide gross and decade
## and pointplot in different color to indicate worldwide gross seasonally.
ggplot(data = bugetTable, aes(factor(decade), y=worldwide)) + 
  geom_jitter(aes(colour = factor(season)),alpha=1/2) +
  geom_boxplot() +
  scale_y_log10()

## End the query.
dbClearResult(query)

