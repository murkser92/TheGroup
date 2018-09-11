

searchterm='In-Memory'

setwd(paste('C:/Users/deswint1/Desktop/Studium/BDBA Aufgabenpaket Woche 8/5-Fallstudie/1-Daten/1-HTML_Format/',searchterm,sep = ''))
number_of_files=length(list.files())

library(lubridate)
library(stringr)
library(XML)
library(rvest)
i=0
P=0

for(i in 1:number_of_files){
  P=+1
  if(i==1){
    #html datei lesen und in variable schreiben
    search <- read_html(paste(paste(searchterm,toString(i),sep=""),".html",sep = ""))
    
    #nur headlines aus html variable scrapen
    search_headline_pre=search %>%
      html_nodes(xpath='//*[@id="hd" or @class="headlines"]')%>%
      html_text()
    
    
    #nur article klassen aus html datei scrapen
    search_article_pre=search %>%
      html_nodes(xpath='//*[@class="article deArticle" or @class="article enArticle" or @class="printheadline deHeadline"  ]')%>%
      html_text()
    
    ##Datums Wert aus jedem Kopfteil eines Artikels
    search_date_pre=search %>%
      html_nodes(xpath='//div[(contains(text(), "January ") or contains(text(), "February ") or contains(text(), "March ") or contains(text(), "April ") or contains(text(), "May ") or contains(text(), "June ") or contains(text(), "July ") or
                 contains(text(), "August ") or contains(text(), "September ") or contains(text(), "October ") or contains(text(), "November ") or contains(text(), "December ")) and not(contains(text(),".")) and not(contains(text(),"-")) and not(contains(text(),"/")) ]')%>%
      html_text()
    
    ##Überarbeiten Werte im Datumsfeld(Format Probleme)
    for (n in 1:length(search_date_pre)){
      if(grepl(',',search_date_pre[n])){
        search_date_pre[n]=sapply(strsplit(search_date_pre[n], ","), "[", 3)
      }
    }
    
    
    length(search_date_pre)
    length(search_headline_pre)
    length(search_article_pre)
    
    ##Entfernen von Artikel veröffentlicht von der Europäischen Kommission(Format Probleme)
    for (n in 1:length(search_headline_pre)){
      if(grepl('Anfragen der Mitglieder',search_headline_pre[n])){
        search_headline_pre=search_headline_pre[-n]
        search_article_pre=search_article_pre[-n]
        search_date_pre=search_date_pre[-n]
      }
    }
    
    ##Entfernen von Artikel veröffentlicht von des Bundesanzeigers(Format Probleme)
    for (n in 1:length(search_article_pre)){
      if(grepl('Bundesanzeiger',search_article_pre[n])){
        search_headline_pre=search_headline_pre[-n]
        search_article_pre=search_article_pre[-n]
        search_date_pre=search_date_pre[-n]
      }
    }
    

    
    
    #Entfernen von line brake usw.
    search_headline=gsub("[\r\n]", "", search_headline_pre)
    search_article=gsub("[\r\n]", "", search_article_pre)
    search_date=gsub("[\r\n]", "", search_date_pre)
   
    
    #Dataframe aus Datum, Titel und Artikel erstellen
    search_data=data.frame(Datum=search_date,Titel=search_headline,Artikel=search_article)
    
  }else{
    
    #html datei lesen und in variable schreiben
    search <- read_html(paste(paste(searchterm,toString(i),sep=""),".html",sep = ""))
    
    #nur headlines aus html variable scrapen
    search_headline_pre=search %>%
      html_nodes(xpath='//*[@id="hd" or @class="headlines"]')%>%
      html_text()
    
    #nur article klassen aus html datei scrapen
    search_article_pre=search %>%
      html_nodes(xpath='//*[@class="article deArticle" or @class="article enArticle" or @class="printheadline deHeadline"  ]')%>%
      html_text()

    ##Datums Wert aus jedem Kopfteil eines Artikels
    search_date_pre=search %>%
      html_nodes(xpath='//div[(contains(text(), "January ") or contains(text(), "February ") or contains(text(), "March ") or contains(text(), "April ") or contains(text(), "May ") or contains(text(), "June ") or contains(text(), "July ") or
                 contains(text(), "August ") or contains(text(), "September ") or contains(text(), "October ") or contains(text(), "November ") or contains(text(), "December ")) and not(contains(text(),".")) and not(contains(text(),"-")) and not(contains(text(),"/")) ]')%>%
      html_text()
    
    ##Überarbeiten Werte im Datumsfeld(Format Probleme)
    for (n in 1:length(search_date_pre)){
      if(grepl(',',search_date_pre[n])){
        search_date_pre[n]=sapply(strsplit(search_date_pre[n], ","), "[", 3)
      }
    }
    
    length(search_article_pre)
    ##Entfernen von Artikel veröffentlicht von der Europäischen Kommission(Format Probleme)
    for (n in 1:length(search_headline_pre)){
      if(grepl('Anfragen der Mitglieder',search_headline_pre[n])){
        search_headline_pre=search_headline_pre[-n]
        search_article_pre=search_article_pre[-n]
        search_date_pre=search_date_pre[-n]
      }
    }
    
    length(search_article_pre)
    ##Entfernen von Artikel veröffentlicht von des Bundesanzeigers(Format Probleme)
    for (n in 1:length(search_article_pre)){
      if(grepl('Bundesanzeiger',search_article_pre[n])){
        search_headline_pre=search_headline_pre[-n]
        search_article_pre=search_article_pre[-n]
        search_date_pre=search_date_pre[-n]
      }
    }

    
    
    #Entfernen von line brake usw.
    search_headline=gsub("[\r\n]", "", search_headline_pre)
    search_article=gsub("[\r\n]", "", search_article_pre)
    search_date=gsub("[\r\n]", "", search_date_pre)
    
    
    
    name=paste("search_data",i,sep = "")
    assign(name,data.frame(Datum=search_date,Titel=search_headline,Artikel=search_article))
    
    search_data=rbind.data.frame(eval(parse(text = paste("search_data",toString(i),sep=""))),search_data)
  }
  
  
  
}




#Rightsubstring Funktion 
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}



#Erstellen von Datumsschnipsel
search_day=substrRight(trimws(paste("0",trimws(substr(search_data$Datum,1,2)),sep = "")),2)
search_year=substrRight(trimws(paste("0",search_data$Datum)),4)
search_month=trimws(substr(paste("0",trimws(substr(search_data$Datum,1,str_length(search_data$Datum)-4)),sep=""),4,str_length(search_data$Datum)))



#Zusammenfügen der Datumsschnipsel
search_month_year=paste(search_month,search_year,sep = "-")
search_date_complete=paste(search_day,search_month_year,sep = "-")
search_data$Datum=search_date_complete

#Datumsformat umwandeln in ein verarbeitbares Format
search_data$Datum=as.Date(parse_date_time(x = search_data$Datum,
                                          orders = c("d m y", "d B Y", "m/d/y"),
                                          locale = "eng"),"ymd")

#Dataum umwandeln mit führender Null und hinzufügen von einem Bindestrich
#search_data$Datum=paste(substrRight(trimws(paste("0",substr(search_data$Datum,1,2),sep = "")),2),paste(trimws(substr(substrRight(trimws(paste("0",search_data$Datum)),str_length(search_data$Datum)-2),1,str_length(substrRight(trimws(paste("0",search_data$Datum)),str_length(search_data$Datum)-2))-4)),substrRight(trimws(paste("0",search_data$Datum)),4),sep = "-"),sep = "-")

#Dataframe in csv schreiben
write.csv(file=paste(searchterm, '.csv', sep = ''),search_data)









