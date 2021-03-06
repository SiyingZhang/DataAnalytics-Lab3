##Test for github
library("RSQLite")
library(ggplot2)

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

## Show the linear regression result p-value = 2.2e-16 < 0.05
summary(yearCount.lm)

## Tried to use nls simple nonlinear least squares fit but failed.
#yearCount.exp <- nls(count~a*exp(b*year+c), start=list(a=1.2,b=yearCount.lm$coefficients[2],c=yearCount$coefficients[1]), data=numberYear)

## Generate data for the fit curve.
years=numberYear$year
yearCount.result<-data.frame(x=years,y=exp(yearCount.lm$coefficients[2]*years+yearCount.lm$coefficients[1])) 

########### Create a graph for this dataframe YEAR vs Number of movies.
## They seem to have a exponetial relation, number of movies increases exponetionally along with year.
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
  if(bugetTable$month[i]<4) bugetTable$season[i] <- 1
  else if(bugetTable$month[i]<7) bugetTable$season[i] <- 2
  else if(bugetTable$month[i]<10) bugetTable$season[i] <- 3
  else bugetTable$season[i] <- 4
}

for(i in 1:length(bugetTable$month)){
  if(bugetTable$worldwide[i]<1000000) bugetTable$scale[i] <- '< 1000000'
  else if(bugetTable$worldwide[i]<125000000) bugetTable$scale[i] <- '< 125000000'
  else if(bugetTable$worldwide[i]<150000000) bugetTable$scale[i] <- '< 150000000'
  else if(bugetTable$worldwide[i]<175000000) bugetTable$scale[i] <- '< 175000000'
  else if(bugetTable$worldwide[i]<1850000000) bugetTable$scale[i] <- '< 1950000000'
  else bugetTable$scale[i] <- '>= 1950000000'
}

## Generating boxpot showing the relation between worldwide gross and decade
## and pointplot in different color to indicate worldwide gross seasonally.
ggplot(data = bugetTable, aes(factor(decade), y=worldwide)) + 
  geom_jitter(aes(colour = factor(season),alpha=scale)) +
  geom_boxplot(alpha=0.01) +
  scale_y_log10()

## Average worldwide gross along with month.
queryBudget<-dbSendQuery(moviesDB,"SELECT AVG(worldwide) as avg_worldwide,month FROM budget GROUP BY month ORDER BY year ASC")
yearWorldwide<-dbFetch(queryBudget, n=-1)
ggplot(data=yearWorldwide,aes(month,avg_worldwide)) + geom_histogram(aes(fill = avg_worldwide),stat="identity")

#select rating and worldwide gross from two tables
query <- dbSendQuery(moviesDB, "SELECT r.rating,  b.worldwide FROM budget b, ratings r WHERE r.movieName=b.movieName" )
#return all rows that selected 
RatingVsWorldwide<- dbFetch(query, n = -1)

View(RatingVsWorldwide)
attach(RatingVsWorldwide)
#paint a graph that showing the relationship between ratings and worldwide gross of a movie
plot(rating, worldwide, main="RatingVsWorldwide", xlab="rating ", ylab="worldwide gross", pch=19)
#paint a graph that showing the counting of votes
ggplot(RatingVsWorldwide, aes(x=rating))+ geom_histogram(aes(fill = ..count..), binwidth=0.48)

## Select vote and ratings column from rating table.
query <- dbSendQuery(moviesDB, "SELECT AVG(rating) AS AvgRating, year FROM ratings WHERE year<2018 GROUP BY year")
RatingByYears <- dbFetch(query, n=-1)

## Create a graph for this database
attach(RatingByYears)
## Using qplot to generate a "bar" graph
qplot(year, AvgRating, data = RatingByYears, geom = "bar", color = "red", main="Ratings By Years", xlab = "Votes", ylab = "Ratings", stat = "identity")

## Select vote and ratings column from rating table.
query <- dbSendQuery(moviesDB, "SELECT votes, rating FROM ratings ORDER BY rating ASC")
RatingVsVotes <- dbFetch(query, n=-1)

## Create a graph for this database
attach(RatingVsVotes)
## generate a plot graph to see the tendency of rating over the change of votes
plot(votes, rating, main="Rating VS Votes", xlab = "Votes", ylab = "Ratings", pch = 20)

## Select budget and ratings column from two tables.
query <- dbSendQuery(moviesDB, "SELECT b.movieName, b.budget, r.rating FROM budget b, ratings r WHERE r.movieName=b.movieName" )
## return rows that selected into a class called RatingsVsBudget
RatingsVsBudget <- dbFetch(query, n=-1)
attach(RatingsVsBudget)
##Create a graph showing the relationship of rating and budget
plot(rating, budget, main="RatingsVsBudget", xlab="rating ", ylab="Budget", pch=19)

##Select year and worldwide gross column from two tables.
query <- dbSendQuery(moviesDB, "select year,worldwide from budget group by year")
YearVsWorldwide <- dbFetch(query, n=-1)
attach(YearVsWorldwide)
##Create a graph showing the relationship of year and worldwide
plot(worldwide , year , main="YearVsWorldwide" , xlab = "Worldwide" , ylab = "Year" , pch=19)

## End the query.
dbClearResult(query)
