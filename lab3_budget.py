################################
### Creates Database
### Updates Database with Data
################################

from BeautifulSoup import *
import urllib
import os
import sqlite3 as lite
import sys


siteHTML = "http://boxnumbertwo.com/MovieData/budget.html"
html = urllib.urlopen(siteHTML).read()
soup = BeautifulSoup(html)
tables = soup.findAll("table")
##budgets=dict()
for row in soup('table')[0].findAll('tr'):
    for col in row.findAll('td'):
        print col.text
print(type(col.text))



## Set directory to YOUR computer and folder
#directoryForDB = "C:/Users/Pudders/Desktop/MovieData/"
#if not os.path.exists(directoryForDB):
	#os.makedirs(directoryForDB)

#directoryForDB = directoryForDB + "movies.db"
## If database does not exist, creates items
## If database does exist, opens it
#con = lite.connect(directoryForDB)

### ADD MORE HERE