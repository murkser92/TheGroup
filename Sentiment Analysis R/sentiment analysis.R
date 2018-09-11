#Literatur https://www.tidytextmining.com/

library(tidytext)
library(tidyverse)
library(stringi)

#Die Ausgangsdatei ist mit Shauns Daten und mit Shauns Skript erstellt.
#Sie enthält je Zeile ein Artikel. Es wurde ein Zeilenindex als Artikelindex erstellt.

#Die Spalte Artikel hatte den Datentyp Factor. Das mag tidytext nicht. In art2 steht derselbe Text als Vektor
bubble_data2$art2 <- as.vector(bubble_data2$Artikel) 

#Hiermit wird die Ausgangsdatei in das Tidy-Text-Format gewandelt (ein Wort je Zeile). Die übrigen Spalten der Ausgangsdatei übernommen.
bubble_tidy <- bubble_data2 %>% unnest_tokens(word,art2)

#Herauslöschen der Stop-Words
library(stopwords)
stopw <- data_frame(word=stopwords("german"))
bubble_tidy_nostopw <- anti_join(bubble_tidy,stopw,by=c("word","word"))

#Eine Worthäufigkeitsanalyse
bubble_tidy_nostopw %>% count(word,sort=T)

#Für eine Sentimentanalyse werden Wortlisten benötigt, die deutsche(!) Worte einen Sentiment-Score zuweisen
# s.a. https://www.inwt-statistics.de/blog-artikel-lesen/text-mining-part-3-sentiment-analyse.html
#Quelle für die Sentimentdaten: http://wortschatz.uni-leipzig.de/de/download
#Die Struktur ist Stammwort - Sentimentscore - Beugungen des Stammwortes
#Im folgenden werden die Listen in die Form Wort - Sentimentscore gebracht

senti_neg <- read_delim("SentiNegative.txt",
"\t", escape_double = FALSE, col_names = FALSE,
trim_ws = TRUE)

senti_neg_var <- c("X1","X3","X4","X5","X6")

for (i in senti_neg_var){
  nam <- paste("neg",i,sep="_")
  sel <- !is.na(senti_neg[i])
  t <-  senti_neg[sel,c(tolower(i),"X2")]
  colnames(t)=c("negword","negscore")
  assign(nam,t)
}
neg_word <- rbind(neg_X1,neg_X3,neg_X4,neg_X5,neg_X6)
neg_word$negword <- tolower(neg_word$negword)
neg_word$negword <- gsub("[|]\\w*","",neg_word$negword)

neg_word$negword <- gsub("uß$","uss",neg_word$negword)
senti_pos <- read_csv("SentiPositiv.txt")

for (i in senti_neg_var){
  nam <- paste("pos",i,sep="_")
  sel <- !is.na(senti_pos[i])
  t <-  senti_pos[sel,c(i,"X2")]
  colnames(t)=c("posword","posscore")
  assign(nam,t)
}

pos_word <- rbind(pos_X1,pos_X3,pos_X4,pos_X5,pos_X6)
pos_word$posword <- tolower(pos_word$posword)
pos_word$posword <- gsub("[|]\\w*","",pos_word$posword)

#Anpassung an die neue deutsche Rechtschreibung :-)
pos_word$posword <- gsub("uß$","uss",pos_word$posword)
pos_word$posword <- gsub("einfluß","einfluss",pos_word$posword)
pos_word$posword <- gsub("entschluß","entschluss",pos_word$posword)
pos_word$posword <- gsub("genuß","genuss",pos_word$posword)
pos_word$posword <- gsub("luß","luss",pos_word$posword)
pos_word$posword <- gsub("schuß","schuss",pos_word$posword)

#Hier passiert das Eigentliche: Left Join der Scores an die tidy_text_datei
bubble_tidy_nostopw <- left_join(bubble_tidy_nostopw,neg_word, by=c("word"="negword"))
bubble_tidy_nostopw <- left_join(bubble_tidy_nostopw,pos_word, by=c("word"="posword"))

#Pro Artikel (Rowindex s.o.) werden verschiedene Metriken (Mean, Summe, Anzahl gescorter Worte) erstellt
bubble_negscore <- bubble_tidy_nostopw%>%group_by(rowindex)%>%
  summarise(meannegscore=mean(negscore,na.rm=T),sumnegscore=sum(negscore,na.rm=T),negwords=sum(!is.na(negscore)))

bubble_posscore <- bubble_tidy_nostopw%>%group_by(rowindex)%>%
  summarise(meanposscore=mean(posscore,na.rm=T),sumposscore=sum(posscore,na.rm=T),poswords=sum(!is.na(posscore)))

#Matchen der Scores an die Ausgangsdatei - eine Zeile je Artikel
bubble_data2 <- left_join(bubble_data2,bubble_negscore,by=c("rowindex"))
bubble_data2 <- left_join(bubble_data2,bubble_posscore,by=c("rowindex"))

#Weitere Spalten je Artikel
bubble_data2$sentiment <- with(bubble_data2,sumnegscore+sumposscore)

bubble_data2$possentiment <- bubble_data2$sentiment>0
bubble_data2$negsentiment <- bubble_data2$sentiment<0
bubble_data2$neutsentiment <- bubble_data2$sentiment==0

#Erstellung einer Exportdatei zur Visualisierung in Tableau. Zeitdimension ist Wochennummer, um sie mit den Google-Daten darstellen zu können.

zr_sentiment <- bubble_data2%>%group_by(date_week)%>%summarise(meansentiment=mean(sentiment),
                n_neg=sum(negsentiment),n_pos=sum(possentiment),n_neut=sum(neutsentiment))
write_csv(zr_sentiment,"zr_sentiment.csv")





