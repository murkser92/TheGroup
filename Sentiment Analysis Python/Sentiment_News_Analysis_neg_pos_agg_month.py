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

global highestred
global highestblue
global lowestred
global lowestblue
global highest
global lowest
global meanpos
global meanneg


with open(infile, 'r') as csvfile:
    rows = csv.reader(csvfile)
    next(rows, None)
    for row in rows:
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
        bloblist.append((date,blob.sentiment.polarity,positive,negative))

df = pd.DataFrame(bloblist, columns = ['date','polarity','positive','negative'])

df['date']=pd.to_datetime(df['date'], format='%Y-%m-%d')

df['month']=df['date'].astype(str).str[:7]

df.sort_values("date", inplace=True)

df = df[["month", "positive","negative"]]

df = df.set_index(df['month'])



df=df.groupby(df['month']).agg(
    {'positive': 'sum', 'negative': 'sum' }).reset_index()

highestred=max(df['positive'])
highestblue=max(df['negative'])
lowestred=min(df['positive'])
lowestblue=min(df['negative'])
if highestred > highestblue:
    highest=highestred
else:
    highest=highestblue

if lowestred > lowestblue:
    lowest=lowestred
else:
    lowest=lowestblue
    

df['meanpos']=np.mean(df['positive'])
df['meanneg']=np.mean(df['negative'])
plt.ylim(lowest,highest)
plt.plot(df['month'],df['positive'],'r', label='Positive Sentiment')
plt.plot(df['month'],df['negative'],'b',label='Negative Sentiment')
plt.plot(df['month'],df['meanpos'],'ro', label='Positive Sentiment Mean')
plt.plot(df['month'],df['meanneg'],'b^', label='Negative Sentiment Mean')
plt.xticks(rotation=40)

plt.legend()
plt.show()

df['positive']=df['positive'].astype(float).round(4).astype(str).str.replace('.',',')
df['negative']=df['negative'].astype(float).round(4).astype(str).str.replace('.',',')

df.to_csv('Data_Sentiment_Result.csv', sep=';', encoding='utf-8',index=False)



