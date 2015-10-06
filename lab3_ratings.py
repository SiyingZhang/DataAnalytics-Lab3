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
count = 0

for line in response:
	words = re.sub(' +',' ',line.strip())	
	line = words.split(" ",3)

	# remove special characters "2 or more characters, not A-Z a-z 0-9 { } \" 'space' " 
	wordReplace1 = re.sub('[^A-Z^a-z^0-9^{^}^\(^\)^\"^ ]{2,}','',line[3])
	#remove "{.*}" behind of the string (423431 results / 3376 match)
	wordReplace2 = re.sub(' {.*}', '', wordReplace1)
	# remove '(TV)' '(V)' () (422585 results)
	wordReplace3 = re.sub(r' \(\D*\)', '', wordReplace2)
	# change (2007/I) into (2007) (422303 results / 3572 match)
	wordReplace4 = re.sub(r'\/.{1,3}\)',')', wordReplace3)
	# remove the \" at the begining
	wordReplace5 = re.sub(r'^\"','', wordReplace4)
	# handle the last \" and the begining 'space'
	wordReplace6 = wordReplace5.replace("\" "," ").lstrip()	
	# store the value into dict, if there are movies with the same name then chose the first one (Max votes).
	if wordReplace6 not in movies:
		movies[wordReplace6] = {'rating': line[2], 'votes': line[1], 'year': wordReplace6[-5:-1]}


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
	cur.execute("CREATE TABLE ratings(movieName TEXT,year INT, rating REAL, votes INT)")
	for key in movies:
		insertStatement = 'INSERT INTO ratings VALUES(?, ?, ?, ?)'
		parms = (key, movies[key]['year'], movies[key]['rating'], movies[key]['votes'])
		count+=1
		cur.execute(insertStatement, parms)
		print "Inserting: ", key
	con.commit()
	print 'Total records: ',count