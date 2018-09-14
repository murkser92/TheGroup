
library(lubridate)
library(XML)
library(rvest)
library(stringr)

i=0

#searchterm of the directory and file name that you want to scrape e.g. directory name = 3DPrinter and file name 3DPrinter1(the diget at the end has to increment by 1 for each file)
searchterm='In-Memory'

setwd(paste('C:/Users/deswint1/Desktop/Studium/BDBA Aufgabenpaket Woche 8/5-Fallstudie/1-Daten/1-HTML_Format/',searchterm,sep = ''))
number_of_files=length(list.files())

for(i in 1:number_of_files){
  P=+1
  if(i==1){
    
    #html datei lesen und in variable schreiben
    html <- read_html(paste(paste(searchterm,toString(i),sep=""),".html",sep = ""))
    
    #Zusätzliche Variable erstellen um später wieder zu verwenden, da html schon manipuliert ist
    htmlneu=html
    
    #nur id article aus html datei scrapen(mit richtigem Format, da zum Teil nur Artikel mit einer Referenz exestieren und kein Inhalt besitzen)
    html_article=htmlneu %>%
      html_nodes(xpath='//*[starts-with(@id, "article-")]/div[/.]')%>%
      html_text()
##Formatierung der HTML Datei für das spätere extrahieren der Datumswerte
    ##alle nachfolgende elemente werden entfernt
    
    ex_hd=html%>%  html_nodes(xpath='//*[@id="hd"]') 
    xml_remove(ex_hd) 
    ex_hd=html%>%   html_nodes(xpath='//*[@id="hd"]') 
    
    ex_auth=html%>% html_nodes(xpath='//*[@class="author"]') 
    xml_remove(ex_auth) 
    ex_auth=html%>% xml_nodes(xpath='//*[@class="author"]')  
    
    words_ex=html%>% html_nodes(xpath='//div[contains(text(), " words")]')  
    xml_remove(words_ex) 
    
    
    words_ex=html%>% html_nodes(xpath='//div[contains(text(), " words")]')  
    xml_remove(words_ex) 
    
    words_ex=html%>% html_nodes(xpath='//div[contains(text(), " words")]')
    
    carry_ex=html%>% html_nodes(xpath='//*[@id="carryOver"]') 
    xml_remove(carry_ex) 
    carry_ex=html%>% html_nodes(xpath='//*[@id="carryOver"]')
    
    p_ex=html%>% html_nodes(xpath='//p') 
    xml_remove(p_ex) 
    p_ex=html%>% html_nodes(xpath='//p')
    
    #Das Datum wird extrahiert
    html_date=html %>%
      html_nodes(xpath='//div[(contains(text(), "January ") or contains(text(), "February ") or contains(text(), "March ") or contains(text(), "April ") or contains(text(), "May ") or contains(text(), "June ") or contains(text(), "July ") or
              contains(text(), "August ") or contains(text(), "September ") or contains(text(), "October ") or contains(text(), "November ") or contains(text(), "December ")) and not(contains(text(),".")) and not(contains(text(),"-")) and not(contains(text(),"/"))  ]')%>%
      html_text()
    ##Cleansing der Artikel und Datum
    html_article_clean=gsub("[\r\n]", "", html_article)
    html_article_clean=gsub("[\r?\n]", "", html_article_clean)
    html_article_clean=str_replace_all(html_article_clean, '\"', "")
    html_article_clean=str_replace_all(html_article_clean, '""', "")
    html_article_clean=gsub('\"', "",html_article_clean, fixed = TRUE)
    html_article_clean=gsub('""', "",html_article_clean)
    html_article_clean=gsub('\\\"', "",html_article_clean)
    html_article_clean=gsub("[[:punct:]]", " ", html_article_clean)
    html_date_clean=gsub("[\r\n]", "", html_date)
    #Dataframe aus Datum und Artikel erstellen
    html_data=data.frame(Datum=html_date_clean,Artikel=html_article_clean)
    html_article_clean[1]
    

  }else{
    #html datei lesen und in variable schreiben
    html <- read_html(paste(paste(searchterm,toString(i),sep=""),".html",sep = ""))
    
    #Zusätzliche Variable erstellen um später wieder zu verwenden, da html schon manipuliert ist
    htmlneu=html
    
    #nur id article aus html datei scrapen(mit richtigem Format, da zum Teil nur Artikel mit einer Referenz exestieren und kein Inhalt besitzen)
    html_article=htmlneu %>%
      html_nodes(xpath='//*[starts-with(@id, "article-")]/div[/.]')%>%
      html_text()
    ##Formatierung der HTML Datei für das spätere extrahieren der Datumswerte
    ##alle nachfolgende elemente werden entfernt
    
    ex_hd=html%>%  html_nodes(xpath='//*[@id="hd"]') 
    xml_remove(ex_hd) 
    ex_hd=html%>%   html_nodes(xpath='//*[@id="hd"]') 
    
    ex_auth=html%>% html_nodes(xpath='//*[@class="author"]') 
    xml_remove(ex_auth) 
    ex_auth=html%>% xml_nodes(xpath='//*[@class="author"]')  
    
    words_ex=html%>% html_nodes(xpath='//div[contains(text(), " words")]')  
    xml_remove(words_ex) 
    
    
    words_ex=html%>% html_nodes(xpath='//div[contains(text(), " words")]')  
    xml_remove(words_ex) 
    
    words_ex=html%>% html_nodes(xpath='//div[contains(text(), " words")]')
    
    carry_ex=html%>% html_nodes(xpath='//*[@id="carryOver"]') 
    xml_remove(carry_ex) 
    carry_ex=html%>% html_nodes(xpath='//*[@id="carryOver"]')
    
    p_ex=html%>% html_nodes(xpath='//p') 
    xml_remove(p_ex) 
    p_ex=html%>% html_nodes(xpath='//p')
    
    #Das Datum wird extrahiert
    html_date=html %>%
      html_nodes(xpath='//div[(contains(text(), "January ") or contains(text(), "February ") or contains(text(), "March ") or contains(text(), "April ") or contains(text(), "May ") or contains(text(), "June ") or contains(text(), "July ") or
                 contains(text(), "August ") or contains(text(), "September ") or contains(text(), "October ") or contains(text(), "November ") or contains(text(), "December ")) and not(contains(text(),".")) and not(contains(text(),"-")) and not(contains(text(),"/"))  ]')%>%
      html_text()
    ##Cleansing der Artikel und Datum
    html_article_clean=gsub("[\r\n]", "", html_article)
    html_article_clean=gsub("[\r?\n]", "", html_article_clean)
    html_article_clean=str_replace_all(html_article_clean, '\"', "")
    html_article_clean=str_replace_all(html_article_clean, '""', "")
    html_article_clean=gsub('\"', "",html_article_clean, fixed = TRUE)
    html_article_clean=gsub('""', "",html_article_clean)
    html_article_clean=gsub('\\\"', "",html_article_clean)
    html_article_clean=gsub("[[:punct:]]", " ", html_article_clean)
    html_date_clean=gsub("[\r\n]", "", html_date)
   
     #Zusammenführen der erstellten dataframes
    name=paste("html_data",i,sep = "")
    assign(name,data.frame(Datum=html_date_clean,Artikel=html_article))
    
    html_data=rbind.data.frame(eval(parse(text = paste("html_data",toString(i),sep=""))),html_data)
  }
}

html_data=data.frame(html_data, qoute=FALSE)


html_data$Artikel=gsub("[\r\n]", "", html_data$Artikel)
html_data$Artikel=gsub("[\r?\n]", "", html_data$Artikel)
html_data$Artikel=str_replace_all(html_data$Artikel, '\"', "")
html_data$Artikel=str_replace_all(html_data$Artikel, '""', "")
html_data$Artikel=gsub('\"', "",html_data$Artikel, fixed = TRUE)
html_data$Artikel=gsub('""', "",html_data$Artikel)
html_data$Artikel=gsub('\\\"', "",html_data$Artikel)
html_data$Artikel=gsub("[[:punct:]]", " ", html_data$Artikel)
html_data$Artikel=gsub("[\r\n]", "", html_data$Artikel)

#Rightsubstring Funktion 
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}



#Erstellen von Datumsschnipsel
html_day=substrRight(trimws(paste("0",trimws(substr(html_data$Datum,1,2)),sep = "")),2)
html_year=substrRight(trimws(paste("0",html_data$Datum)),4)
html_month=trimws(substr(paste("0",trimws(substr(html_data$Datum,1,str_length(html_data$Datum)-4)),sep=""),4,str_length(html_data$Datum)))



#Zusammenfügen der Datumsschnipsel
html_month_year=paste(html_month,html_year,sep = "-")
search_date_complete=paste(html_day,html_month_year,sep = "-")
html_data$Datum=search_date_complete

Sys.setenv(TZ="Europe/Berlin")
print(Sys.getenv("TZ"))
#Datumsformat umwandeln in ein verarbeitbares Format
html_data$Datum=as.Date(parse_date_time(x = html_data$Datum,
                                          orders = c("d m y", "d B Y", "m/d/y"),
                                          locale = "eng"),"ymd")



#Dataframe in csv schreiben
write.csv(file=paste(searchterm, '.csv', sep = ''),html_data)
