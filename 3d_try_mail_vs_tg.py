import os
os.chdir("D:\\Study\\CL\\prj2")

import numpy as np
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import Counter
from sklearn import feature_extraction, model_selection, naive_bayes, metrics, svm

# from IPython.display import Image
import warnings
warnings.filterwarnings("ignore")

#data needed
#stops prep
stops=pd.read_csv("stops_tg.csv")
stoplist_mail= stops["word"].values.tolist()
#load data 
tg_mail=pd.read_csv("tg_mail.csv",  delimiter=";")

#start classif
f = feature_extraction.text.TfidfVectorizer(stop_words = stoplist_mail)
X = f.fit_transform(tg_mail["text"])
print(f.get_feature_names()[1000:1020])
X.shape

#split
X_train, X_test, y_train, y_test = model_selection.train_test_split(X, tg_mail['label'], test_size=0.2, random_state=50)
print(X_train.shape, X_test.shape)
print(y_train.shape, y_test.shape) 
#tune
list_C = np.arange(10, 500, 10) 
score_train = np.zeros(len(list_C))
score_test = np.zeros(len(list_C))
recall_test = np.zeros(len(list_C))
precision_test= np.zeros(len(list_C))

count = 0
for C in list_C:
    svc = svm.SVC(C=C)
    svc.fit(X_train, y_train)
    score_train[count] = svc.score(X_train, y_train)
    score_test[count]= svc.score(X_test, y_test)
    recall_test[count] = metrics.recall_score(y_test, svc.predict(X_test),pos_label='mails')
    precision_test[count] = metrics.precision_score(y_test, svc.predict(X_test),pos_label='mails')
    count = count + 1 

#check fit metrics
matrix = np.matrix(np.c_[list_C, score_train, score_test, recall_test, precision_test])
models = pd.DataFrame(data = matrix, columns = 
             ['C', 'Train Accuracy', 'Test Accuracy', 'Test Recall', 'Test Precision'])

#get best
best_index = models['Test Recall'].idxmax()
print(models.iloc[best_index])
models.tail(n=60)
best_C=models.iloc[best_index]

#final model
svc = svm.SVC(C=best_C[0])
svc.fit(X_test, y_test)
y_pred = svc.predict(X_test)

#check confusion matrix
new_df = pd.DataFrame(data = y_test)
new_df["predicted"]=svc.predict(X_test)
m_confusion_test = metrics.confusion_matrix(y_test, y_pred)
pd.DataFrame(data = m_confusion_test, columns = ['Predicted mail', 'Predicted tg'],
            index = ['Actual mail', 'Actual tg'])
