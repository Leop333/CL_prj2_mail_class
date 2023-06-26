setwd("D:/Study/CL/prj2")
library(jsonlite)
library(readr)
library(dplyr)
library(tidytext)
library(stringr)
library(ggplot2)
library(forcats)
library(jsonlite)
# create corpus tg+news

tg_msg <- fromJSON("result.json",flatten = T)
#tg_msg <-fromJSON(readLines("result.json"), warn = F)
#read in
tg_tst <- tg_msg$messages
tg_tst$label <- "tg"
tg_corp <- tg_tst[,c(13,2,10,37)]
tg_corp$text <- as.character(tg_corp$text)
cl_tg <- which(tg_corp$text<1)
tg_corp <- tg_corp[-cl_tg,]
tryout1 <- read_csv("tryout1.csv")
mail_only <- filter(tryout1,label=="mails")
mail_corp <- mail_only[,3:6]
#label and combine
names(mail_corp)
names(tg_tst)
names(tg_corp) <- c("source","title","text","label")
names(mail_corp) <- c("source","title","text","label")
tg_mail <- rbind(tg_corp,mail_corp)
write.csv2(tg_mail,"tg_mail.csv",row.names = F)

#create stops
tgmail_words <- tg_mail %>%
  unnest_tokens(word, text)
all_neg <- which(str_detect(tgmail_words$word,"[^А-я]+"))
tgmail_stops_words <- data.frame(tgmail_words[all_neg,4])
names(tgmail_stops_words) <- "word"
#stops names
fnames <-  read_csv("master_russian_names.csv", col_names = c("word","n"))
snames <- read_csv("russian_surnames.csv", col_names = c("word","n"))
russianST <- read_csv("russianST.txt", col_names = FALSE)
names(russianST) <- "word"
fnames <- fnames[,1]
snames <- snames[,1]
customstops <- data.frame(c("алексеевна","пармаксиз","закарьян","борисовна","ильинична","вениаминовна",
                            "гужеля","примерытекстовдлядиктанта","валерьевич","сурдейкин","юра",
                            "пустынская","шулюпин","корешникова","окт","олеговна","курюмов",
                            "птюшкин","косоротикова","глуховцеву","самодерженков","григорьевна","пармаксизу",
                            "красногвардейский","проезд ","игоревич","доб","юрьевна","владимировна","проезд"
))
names(customstops) <- "word"
names(russianST) <- "word"
#final
stops_tg <- rbind(tgmail_stops_words,russianST,fnames,snames,customstops)
write.csv2(stops_tg,"stops_tg.csv",row.names = F)

#tokenizer
tg_mail_words <- tg_mail %>%
  unnest_tokens(word, text) %>% 
  anti_join(stops_tg, by = c("word" = "word")) %>% 
  count(label, word, sort = TRUE)

##total words by label
total_tg_mail_words <- tg_mail_words %>% 
  group_by(label) %>% 
  summarize(total = sum(n))

tg_mail_total_words <- left_join(tg_mail_words, total_tg_mail_words)

#freq TF
freq_by_tg_mail <- tg_mail_total_words %>% 
  group_by(label) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total) %>%
  ungroup()

#tfidif
tg_mail_tf_idf <- tg_mail_total_words %>%
  bind_tf_idf(word, label, n)%>%
  arrange(desc(tf_idf))

#plot comaprison
tg_mail_tf_idf %>%
  group_by(label) %>%
  slice_max(tf_idf, n = 25) %>%
  ungroup() %>%
  ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill = label)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~label, ncol = 2, scales = "free") +
  labs(x = "tf-idf", y = NULL)
