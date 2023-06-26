setwd("D:/Study/CL/prj2")
library(readr)
library(dplyr)
library(tidytext)
library(stringr)
library(ggplot2)
library(forcats)
library(jsonlite)
#load main data
russian_news <- read_csv("russian_news.csv")
tryout1 <- read_csv("tryout1.csv")
russianST <- read_csv("russianST.txt", col_names = FALSE)
names(russianST)<-"word"

#check colnams
names(russian_news)

#look
table(russian_news$source)
ria_news <- filter(russian_news,source== "ria.ru")
mail_only <- filter(tryout1,label=="mails")

# create corpus mail+news
ria_news$label <- "news"
names(mail_only)
mail_corp <- mail_only[,3:6]
names(mail_corp)
names(ria_news)
news_corp <- ria_news[,c(1,2,3,6)]
names(news_corp)
names(mail_corp) <- c("source","title","text","label")
news_mail <- rbind(news_corp,mail_corp)
write.csv2(news_mail,"news_mail.csv",row.names = F)

#create stops
mail_words <- news_mail %>%
  unnest_tokens(word, text)
all_neg <- which(str_detect(mail_words$word,"[^А-я]+"))
mail_stops_words <- mail_words[all_neg,4]

#stops names
midnams <-lapply(readLines("midnames.json"), fromJSON,simplifyDataFrame=T,flatten=T)
fnames <-  read_csv("master_russian_names.csv", col_names = c("word","n"))
snames <- read_csv("russian_surnames.csv", col_names = c("word","n"))
fnames <- fnames[,1]
snames <- snames[,1]
customstops <- data.frame(c("алексеевна","пармаксиз","закарьян","борисовна","ильинична","вениаминовна",
                            "гужеля","примерытекстовдлядиктанта","валерьевич","сурдейкин","юра",
                            "пустынская","шулюпин","корешникова","окт","олеговна","курюмов",
                            "птюшкин","косоротикова","глуховцеву","самодерженков","григорьевна","пармаксизу"
                            ))
names(customstops) <- "word"
#final stops
stops <- rbind(mail_stops_words,russianST,fnames,snames,customstops)
write.csv2(stops,"stops.csv",row.names = F)

#check
nrow(news_mail)
nrow(news_corp)+nrow(mail_corp)

#tokenizer
news_mail_words <- news_mail %>%
  unnest_tokens(word, text) %>% 
  anti_join(stops, by = c("word" = "word")) %>% 
  count(label, word, sort = TRUE)

##total words by label
total_words_news_mail <- news_mail_words %>% 
  group_by(label) %>% 
  summarize(total = sum(n))

news_mail_total_words <- left_join(news_mail_words, total_words_news_mail)
#plot
ggplot(news_mail_total_words, aes(n/total, fill = label)) +
  geom_histogram(show.legend = FALSE) +
  xlim(NA, 0.0009) +
  facet_wrap(~label, ncol = 2, scales = "free_y")

#freq TF
freq_by_news_mail <- news_mail_total_words %>% 
  group_by(label) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total) %>%
  ungroup()

#plot TF
freq_by_news_mail %>% 
  ggplot(aes(rank, `term frequency`, color = label)) + 
  geom_line(size = 1.1, alpha = 0.8, show.legend = T) + 
  scale_x_log10() +
  scale_y_log10()

#tfidif
news_mail_tf_idf <- news_mail_total_words %>%
  bind_tf_idf(word, label, n)%>%
  arrange(desc(tf_idf))


#plot comaprison
news_mail_tf_idf %>%
  group_by(label) %>%
  slice_max(tf_idf, n = 25) %>%
  ungroup() %>%
  ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill = label)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~label, ncol = 2, scales = "free") +
  labs(x = "tf-idf", y = NULL)

#add to custom stops
tfidf_mails <- filter(news_mail_tf_idf,label=="mails")
print(tfidf_mails,n=150)
