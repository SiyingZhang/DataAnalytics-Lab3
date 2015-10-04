###########################################
### Creates Database
### Updates Database with Movie Rating Data
###########################################

import sqlite3 as lite
import sys
import os 
import csv
import urllib
import re

#Open the object list in the website and store it in the dict.
ratingsList = "http://boxnumbertwo.com/MovieData/ratings.list"
response = urllib.urlopen(ratingsList)
movies = dict()

for line in response:
	words = re.sub(' +',' ',line.strip())	
	line = words.split(" ",3)

	#remove special characters at the beginning of the string
	wordReplace1 = re.sub('["\$#@&''*!.]','',line[3])
	#remove "{.*}" behind of the string
	wordReplace2 = re.sub('{.*}', '', wordReplace1)
	#store the modified value into dict.
	movies[wordReplace2]=line[2]

## Set directory to YOUR computer and folder
directoryForDB = "./MovieData/"
if not os.path.exists(directoryForDB):
	os.makedirs(directoryForDB)

directoryForDB = directoryForDB + "movies.db"
## If database does not exist, creates items
## If database does exist, opens it
con = lite.connect(directoryForDB)
#use 8-bit strings instead of unicode string
con.text_factory = str

with con:
	cur = con.cursor()
	cur.execute("DROP TABLE IF EXISTS ratings") 
	#Create a table named "ratings", movieName as the primary key, and ratings is another column.
	cur.execute("CREATE TABLE ratings(movieName TEXT PRIMARY KEY, rating REAL)")
	for key in movies:
		insertStatement = 'INSERT INTO ratings VALUES(?,?)'
		parms = (key,movies[key])
	
		cur.execute(insertStatement, parms)
	con.commit()