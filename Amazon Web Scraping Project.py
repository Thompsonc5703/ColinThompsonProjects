#!/usr/bin/env python
# coding: utf-8

# # Amazon Web Scraping

# In[205]:


# import libraries 

from bs4 import BeautifulSoup
import requests
import time
import datetime
import smtplib
import csv
import pandas as pd


# In[231]:


# Connect to Website and pull in data

URL = 'https://www.amazon.com/Funny-Data-Systems-Business-Analyst/dp/B07FNW9FGJ/ref=sr_1_4?crid=U0ZKOAX9CQC7&keywords=data%2Banalyst%2Btshirt&qid=1682819531&sprefix=data%2Banalyst%2Btshirt%2Caps%2C130&sr=8-4'

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

page = requests.get(URL, headers=headers)

soup = BeautifulSoup(page.content, "html.parser")

title = soup.find('span',{'id': 'productTitle'}).get_text().strip()

price = soup.find('span', {'class':'a-price-whole'}).get_text().replace("$","") + soup.find('span', {'class':'a-price-fraction'}).get_text()

print(title)
print(price)


# In[ ]:


# Create a Timestamp for your output to track when data was collected

today = datetime.date.today()


# In[208]:


# Create CSV and write headers and data into the file

header = ['Title', 'Price', 'Date']
data = [title,price,today]

with open('AmazonWebScraperDataset.csv', 'w', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)


# In[233]:


#CSV reader

df = pd.read_csv(r'C:\Users\thomp\AmazonWebScraperDataset.csv')

print(df)


# In[216]:


#Appending data to the csv

with open('AmazonWebScraperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)


# In[220]:


#Combine all of the above code into one function

def check_price():
    URL = 'https://www.amazon.com/Funny-Data-Systems-Business-Analyst/dp/B07FNW9FGJ/ref=sr_1_4?crid=U0ZKOAX9CQC7&keywords=data%2Banalyst%2Btshirt&qid=1682819531&sprefix=data%2Banalyst%2Btshirt%2Caps%2C130&sr=8-4'

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

    page = requests.get(URL, headers=headers)

    soup = BeautifulSoup(page.content, "html.parser")

    title = soup.find('span',{'id': 'productTitle'}).get_text().strip()

    price = soup.find('span', {'class':'a-price-whole'}).get_text().replace("$","") + soup.find('span', {'class':'a-price-fraction'}).get_text()
    
    today = datetime.date.today()
    
    header = ['Title', 'Price', 'Date']

    data = [title,price,today]
    
    with open('AmazonWebScraperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)
        
    if(price < 30):
        send_mail()
        


# In[ ]:


# Runs check_price after a set time and inputs data into your CSV

while(True):
    check_price()
    time.sleep(86400)


# In[ ]:


# Send yourself an email when a price hits below a certain level

def send_mail():
    server = smtplib.SMTP_SSL('smtp.gmail.com',465)
    server.ehlo()
    #server.starttls()
    server.ehlo()
    server.login('Thompsonc5703@gmail.com','xxxxxxxxx')
    
    subject = "The Shirt you want is below $15! Now is your chance to buy!"
    body = "Colin, This is the moment we have been waiting for. Now is your chance to pick up the shirt of your dreams. Don't mess it up! Link here: https://www.amazon.com/Funny-Data-Systems-Business-Analyst/dp/B07FNW9FGJ/ref=sr_1_4?crid=U0ZKOAX9CQC7&keywords=data%2Banalyst%2Btshirt&qid=1682819531&sprefix=data%2Banalyst%2Btshirt%2Caps%2C130&sr=8-4"
   
    msg = f"Subject: {subject}\n\n{body}"
    
    server.sendmail(
        'Thompsonc5703@gmail.com',
        msg
     
    )

