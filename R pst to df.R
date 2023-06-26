#remotes::install_github("hrbrmstr/freepst")

library(freepst)
setwd("D:/Study/CL/prj2")
mymail <- read_pst("my_em.pst")
mailshort <- mymail[,c(1,2,12,13)]

#explore
names(mymail)
length(unique(mymail$subject))
table(mailshort$folder)
table(mailshort$sent_by)
table(mailshort$subject)
length(unique(mailshort$subject))
length(unique(mailshort$sent_by))

#clean 
which(length(mailshort[3,4])<10)

#clean
length(mailshort[3,4])
length(mailshort[,4])
which(length(mailshort[3,4])<10)
small <- which(mailshort$body<50)
mail_shrt_cln<- mailshort[-small,]
#clean emptys
table(mail_shrt_cln$folder)
which(mail_shrt_cln$folder!="Входящие")

#write
write.csv2(mail_shrt_cln,"mail_fromr_clean.csv",row.names=FALSE)
  length(unique(mail_shrt_dirt$subject))
