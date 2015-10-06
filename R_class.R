library("RSQLite")

## Set directory to YOUR computer and folder
setwd("./MovieData/")
system("ls *.db", show=TRUE)
sqlite <- dbDriver("SQLite")
moviesDB <- dbConnect(sqlite,"movies.db")
## Show header budget table
dbListTables(moviesDB) 
query <- dbSendQuery(moviesDB, "SELECT r.movieName, r.rating, b.budget, b.domestic FROM ratings r, budget b WHERE r.movieName=b.movieName ORDER BY r.movieName ASC" )
budget80 <- dbFetch(query, n = -1)
dbClearResult(query)

