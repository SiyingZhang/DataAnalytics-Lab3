## Set directory to YOUR computer and folder
setwd("~/Desktop/Lab3")
#install.packages("RSQLite") #perhaps needed
library("RSQLite")

#connect to the database
db = dbConnect(SQLite(), dbname="movies.db")
#select rating and worldwide gross from two tables
query <- dbSendQuery(db, "SELECT r.rating,  b.worldwide FROM budget b, ratings r WHERE r.movieName=b.movieName" )
#return all rows that selected 
RatingVsWorldwide<- dbFetch(query, n = -1)

View(RatingVsWorldwide)
attach(RatingVsWorldwide)
#paint a graph that showing the relationship between ratings and worldwide gross of a movie
plot(rating, worldwide, main="RatingVsWorldwide", xlab="rating ", ylab="worldwide gross", pch=19)
#paint a graph that showing the counting of votes
ggplot(RatingVsWorldwide, aes(x=rating))+ geom_histogram(aes(fill = ..count..), binwidth=0.48)

dbClearResult(query)

