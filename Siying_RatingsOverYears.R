library("RSQLite")

## Set directory to YOUR computer and folder
setwd("/Users/siying/Documents/edu/PITT/2015\ Fall/Data\ Analytics/Lab/DataAnalytics-Lab3/MovieData")
#system("ls *.db", show=TRUE)

## Connect database
sqlite <- dbDriver("SQLite")
moviesDB <- dbConnect(sqlite,"movies.db")

## Show tables list
dbListTables(moviesDB) 

## Select vote and ratings column from rating table.
query <- dbSendQuery(moviesDB, "SELECT AVG(rating) AS AvgRating, year FROM ratings WHERE year<2018 GROUP BY year")
RatingByYears <- dbFetch(query, n=-1)

library(ggplot2)
## Create a graph for this database
attach(RatingByYears)
## Using qplot to generate a "bar" graph
qplot(year, AvgRating, data = RatingsByYears, geom = "bar", color = "red", main="Ratings By Years", xlab = "Votes", ylab = "Ratings", stat = "identity")

dbClearResult(query)