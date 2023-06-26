library(readr)
library(dplyr)
library(tidytext)
library(readr)

tryout1 <- read_csv("tryout1.csv")

#pre-stops
russianST <- read_csv("russianST.txt", col_names = c("rustop"))
russtop <- as.vector(russianST)
russtop <- russtop[[1]]
#new stops
library(stringr)
mail_stops_words <- tryout1 %>%
  unnest_tokens(word, text)
digits_2 <- which(str_detect(tryout_tf_idf$word,"[[:digit:]]+"))
latin_2 <- which(str_detect(tryout_tf_idf$word,"[a-zA-Z]+"))
all <- which(str_detect(mail_stops_words$word,"[A-z0-9]+"))
all_neg <- which(str_detect(mail_stops_words$word,"[^А-я]+"))
all_df <- unique(mail_stops_words[all,])
table(all_df$label)
my_stops <- c("rsv.ru","екатерина","возможностей","ано","россия","страна")
stops2 <- c(stops3,russtop)
stops2_df <- data.frame(stops2)
#3
stops3 <- c(all_df[7])
stops3 <- stops3[[1]]
stops3_plus <- c(stops3,russtop)
write.csv2(stops2_df,"stops2.csv")
stops3_plus <- data.frame(stops3_plus)
names(stops2_df)<-"word"
names(stops3_plus)<-"word"

#tokenize
mail_tryot_words <- tryout1 %>%
  unnest_tokens(word, text) %>% 
  anti_join(stops3_plus, by = c("word" = "word")) %>% 
count(label, word, sort = TRUE)

#stops_found <- right_join(mail_tryot_words,stops2_df, by = c("word" = "word"))

##total words by label
total_words_tryout <- mail_tryot_words %>% 
  group_by(label) %>% 
  summarize(total = sum(n))

tryout_words <- left_join(mail_tryot_words, total_words_tryout)
library(ggplot2)

ggplot(tryout_words, aes(n/total, fill = label)) +
  geom_histogram(show.legend = FALSE) +
  xlim(NA, 0.0009) +
  facet_wrap(~label, ncol = 2, scales = "free_y")


#freq
# use for stops
freq_by_rank_tryout <- tryout_words %>% 
  group_by(label) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total) %>%
  ungroup()


#plot
freq_by_rank_tryout %>% 
  ggplot(aes(rank, `term frequency`, color = label)) + 
  geom_line(size = 1.1, alpha = 0.8, show.legend = T) + 
  scale_x_log10() +
  scale_y_log10()

#tfidif
tryout_tf_idf <- tryout_words %>%
  bind_tf_idf(word, label, n)%>%
  arrange(desc(tf_idf))


library(forcats)

tryout_tf_idf %>%
  group_by(label) %>%
  slice_max(tf_idf, n = 25) %>%
  ungroup() %>%
  ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill = label)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~label, ncol = 2, scales = "free") +
  labs(x = "tf-idf", y = NULL)



