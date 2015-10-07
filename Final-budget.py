# using BeautifulSoup to parse the web  -  Dealing with HTML tags
from BeautifulSoup import * 		
# importing SQLite3 to deal with Database objects. "As" make alias 
import sqlite3 as lite     	
# using urllib  library for openning a web site
import urllib
# use os library for dealing with operating system objects
import os
import sys

# assign the url to a variable 
siteHTML = "http://boxnumbertwo.com/MovieData/budget.html"
# open a specific website
html = urllib.urlopen(siteHTML).read()
# using soup to parse the website 
soup = BeautifulSoup(html)
# Find the all tables in the in the page  
tables = soup.findAll("table")

# using the current directory to make a file 
directoryForDB = "./MovieData/"
# if the file does not exist, it will make a new one
if not os.path.exists(directoryForDB):
	os.makedirs(directoryForDB)
# naming the Database and assing it to the current directory 
directoryForDB = directoryForDB + "movies.db"
## If database does not exist, creates items
## If database does exist, opens it
## make the connection 
con = lite.connect(directoryForDB)
#use 8-bit strings instead of unicode string
con.text_factory = str

### open the connection

with con:
	count=0  ## counting for how many rows that have been inserted 
	cur = con.cursor()  # object used to execute 
	cur.execute("DROP TABLE IF EXISTS budget") # Drop a database if dose not exits
	#Create a table named "budget", movieName as the primary key, and budget is another column.
	cur.execute("CREATE TABLE budget(movieName TEXT PRIMARY KEY,year INT, month INT, budget REAL, domestic REAL, worldwide REAL)")
	# looping through the first table and find the whole table rows
	for row in soup('table')[0].findAll('tr'):
		budgetDic = dict()  # make empty dic for budget
		yearDic = dict()	#  dic for years
		monthDic =dict()	# dic for months
		domesticDic=dict()	# dic for domestic 
		worldwideDic=dict() # dic for worldwide 
		key = ''  # empty sting to store the movies names 
		if len(row.findAll('td')) != 0:    ## store just the occupied table data 
			for td in row.findAll('td')[2:3]:  # find the td for movies names which is in td 2 
				key+=td.text  	# store the text of that data cell - movies name
	
			for td in row.findAll('td')[1:2]:    # looping through td 1 "The date"
				key+=' ('+(str)(td.text)[-4:]+')'  ### store the years (2009)
				yearDic[key] = (str)(td.text)[-4:]  
				if(td.text[1]=='/'):    ### store the months 5/10/2014 if its two digits  -> 5
					monthDic[key] = td.text[0]   
				else:	
					monthDic[key] = td.text[0:2]  # months 10/3/2013  -> 10
	
			for td in row.findAll('td')[3:4]:   ## looping through budget 
				budgetValue = []   # empty list for elimentation 
				budgetValue = td.text.replace(',','')  # replacing the comma with nothing 
				budgetValue=budgetValue.replace('$','')  # removing $
				budgetDic[key]=(str)(budgetValue)  # store them in a dic using movies names as keys and make them String
	
			for td in row.findAll('td')[4:5]:   # looping through domestic colimns 
				domesticValue=[]
				domesticValue = td.text.replace(',','')
				domesticValue=domesticValue.replace('$','')
				domesticDic[key]=(str)(domesticValue)   ## storing 
	
			for td in row.findAll('td')[5:6]:  ## worldwide budget 
				worldwideValue=[]
				worldwideValue = td.text.replace(',','')
				worldwideValue = worldwideValue.replace('$','')
				worldwideDic[key] = (str)(worldwideValue)   # stroing to dic
			
			##inset every dic into a table 
			insertStatement = 'INSERT INTO budget VALUES(?,?,?,?,?,?)'
			# using a parameters to store them more efficiently and fast
			parms = (key,yearDic[key],monthDic[key],budgetDic[key],domesticDic[key],worldwideDic[key])
			# execute the params
			cur.execute(insertStatement, parms)
			# using the print to show the progress and how many records have been inserted
			print "Inserting: ", key
			# print >>f, "Inserting: ", key
			count+=1
		con.commit()  # use to commit the changes 
	print 'Total records: ',count
# 	print >> f, 'Total records: ',count
# f.close()