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
query <- dbSendQuery(moviesDB, "SELECT votes, rating FROM ratings ORDER BY rating ASC")
RatingVsVotes <- dbFetch(query, n=-1)

## Create a graph for this database
attach(RatingVsVotes)
plot(votes, rating, main="Rating VS Votes", xlab = "Votes", ylab = "Ratings", pch = 20)

dbClearResult(query)