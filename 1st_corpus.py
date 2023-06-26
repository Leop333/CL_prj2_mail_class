# first corpus, model omitted as unsuccessful
import os
os.chdir("D:\\Study\\CL\\prj2")
import numpy as np
import numpy as np
import pandas as pd
#load mails and toxic corpus
mail=pd.read_csv("mail_fromr_clean.csv",  delimiter=";")
toxic=pd.read_csv("Inappapropriate_messages.csv")

mail.columns
mail.rename(columns={'body':'text'},inplace = True)
#labelling
mail=mail.assign(label="mails")
toxic=toxic.assign(label="random")
#save
tryout=mail.append(toxic)
tryout['label'].value_counts()
tryout.to_csv("tryout1.csv")
