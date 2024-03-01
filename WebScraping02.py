# web scraping from the beginning with no good knowledge of beautiful soup and request modules.
# this could be done simplier- but it were the beginnings. And the most important is that it works ;P

from bs4 import BeautifulSoup
import requests
import re

urlBase='http://www.scrapethissite.com/pages/forms/?page_num='
numOfSites=24  # total number of pages with data
siteNum=1
siteNumStr = str(siteNum)
url=urlBase+siteNumStr # url as a string ready to chew for further functions

htmlContent=requests.get(url).text
soup=BeautifulSoup(htmlContent, 'lxml')

# pulling table header
tableHeaderRaw=soup.find_all('th')
headerTitle=''
columnNames=[] # list with column names
for header in tableHeaderRaw:    # looping by all tags that have been pulled from table header
    headerTitle=header.get_text()  # retrieving text from tags
    hRaw = re.search('\n(.+?)\n', headerTitle)
    if hRaw:
        columnName = hRaw.group(1).strip()
    columnNames.append(columnName)

# pulling table content

tableContent=[] # list with data from table
singleRow=[] # container for each row in table
for siteNum in range(1,numOfSites+1):
    siteNumStr = str(siteNum)
    url=urlBase+siteNumStr
    page=requests.get(url).text
    soup2=BeautifulSoup(page,'lxml')
    tableContentRaw = soup2.find_all('tr', class_='team')
    for rowTable in tableContentRaw:
        singleRow = []  # container for each row in table
        rowRaw=rowTable.get_text().strip()
        rowRaw=rowRaw.split('\n\n')
        for row in rowRaw:
            row2=row.replace('\n','').strip()
            singleRow.append(row2)
        tableContent.append(singleRow)
    siteNum += 1

# joining header and content into one table:

fullTableTemp=[]
fullTableTemp.append(columnNames)
fullTable= fullTableTemp + tableContent #full table: header + content

for i in fullTable: # displaying table row by row
    print(i)














# teams=soup.find_all('tr', class_="team")
#
#
# header=soup.find_all('th')




