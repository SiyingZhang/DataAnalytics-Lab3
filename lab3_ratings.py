import sqlite3 as lite
import sys
import os 
import csv
import urllib
import re

ratingsList = "http://boxnumbertwo.com/MovieData/ratings.list"
response = urllib.urlopen(ratingsList)
movies = dict()
for line in response:
	words = re.sub(' +',' ',line.strip())
	
	line = words.split(" ",3)
	
	movies[line[3]]=line[2]

directoryForDB = "~/Desktop/Data_Analytics/"
if not os.path.exists(directoryForDB):
	os.makedirs(directoryForDB)

directoryForDB = directoryForDB + "movies.db"
## If database does not exist, creates items
## If database does exist, opens it

con = lite.connect(directoryForDB)
con.text_factory = str
with con:
	cur = con.cursor()
	cur.execute("DROP TABLE IF EXISTS MovieRatings")
	cur.execute("CREATE TABLE MovieRatings(movie TEXT, rating REAL)")
	for key in movies:
	    insertStatement = "INSERT INTO MovieRatings VALUES(?,?)"
	    parms=(key, movies[key])
	    cur.execute(insertStatement,parms)
	con.commit()

