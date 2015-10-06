## Set directory to YOUR computer and folder
setwd("~/Desktop/Lab3")
#install.packages("RSQLite") #perhaps needed
library("RSQLite")


db = dbConnect(SQLite(), dbname="movies.db")
query <- dbSendQuery(db, "SELECT r.rating,  b.worldwide FROM budget b, ratings r WHERE r.movieName=b.movieName" )
RatingVsWorldwide<- dbFetch(query, n = -1)
View(RatingVsWorldwide)
attach(RatingVsWorldwide)
plot(rating, worldwide, main="RatingVsWorldwide", xlab="rating ", ylab="worldwide gross", pch=19)
dbClearResult(query)

### ADD MORE HERE