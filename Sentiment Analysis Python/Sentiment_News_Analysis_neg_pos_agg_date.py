import datetime
import sys
import time
import csv
from textblob import TextBlob
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

os.chdir(r'C:\Users\const\Documents\TheGroup\Data Transformation\Sample Data')
infile = '3DPrint.csv'

csv.field_size_limit(100000000)
bloblist = list()

global positive
global negative


global meanacount
global articlecount
articlecount=0

with open(infile, 'r') as csvfile:
    rows = csv.reader(csvfile)
    next(rows, None)
    for row in rows:
        articlecount=1
        date = row[1]
        title = row[2]
        sentence = row[3]
        blob = TextBlob(sentence)
        if blob.sentiment.polarity >= 0:
            positive=blob.sentiment.polarity
            negative=0
        else:
            negative=blob.sentiment.polarity*(-1)
            positive=0
        bloblist.append((date,blob.sentiment.polarity,positive,negative,articlecount))

df = pd.DataFrame(bloblist, columns = ['date','polarity','positive','negative','articlecount'])

df['date']=pd.to_datetime(df['date'], format='%Y-%m-%d')

df['month']=df['date'].astype(str).str[:7]

df.sort_values("date", inplace=True)

df = df[["date","articlecount"]]

df = df.set_index(df['date'])



df=df.groupby(df['date']).agg(
    {'articlecount': 'sum'}).reset_index()
   

df['meanpacount']=np.mean(df['articlecount'])
plt.ylim(min(df['articlecount']),max(df['articlecount']))
plt.plot(df['date'],df['articlecount'],'r', label='Number of News Articles per Day')
plt.plot(df['date'],df['meanpacount'],'ro', label='Mean of counted News Articles')
plt.xticks(rotation=40)

plt.legend()
plt.show()


df.to_csv('Data_Sentiment_Result.csv', sep=';', encoding='utf-8',index=False)



