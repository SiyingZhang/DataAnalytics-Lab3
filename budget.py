from BeautifulSoup import *
# from bs4 import BeautifulSoup 
import urllib
import os
import sqlite3 as lite
import sys


siteHTML = "http://boxnumbertwo.com/MovieData/budget.html"
html = urllib.urlopen(siteHTML).read()
soup = BeautifulSoup(html)
tables = soup.findAll("table")
# for table in tables:
# 	print(table)
for row in soup('table')[0].findAll('tr'):
	budget_dic={}
	# tds=row('td')
	for td in row.findAll('td')[2:3]:
		budget_dic['data']=td.text

	for td in row.findAll('td')[3:4]:
		budgetValue = []
		budgetValue = td.text.replace(',','')
		budgetValue=budgetValue.replace('$','')
		budget_dic['budget']=budgetValue

	for td in row.findAll('td')[5:6]:
		domesticValue=[]
		domesticValue = td.text.replace(',','')
		domesticValue=domesticValue.replace('$','')
		budget_dic['domestic']=domesticValue

	for td in row.findAll('td')[6:]:
		worldwideValue=[]
		worldwideValue = td.text.replace(',','')
		worldwideValue=worldwideValue.replace('$','')
		budget_dic['worldwide']=worldwideValue

	print(budget_dic)
