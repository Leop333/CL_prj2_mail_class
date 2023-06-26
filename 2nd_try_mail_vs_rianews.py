import os
os.chdir("D:\\Study\\CL\\prj2")
import numpy as np
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from collections import Counter
from sklearn import feature_extraction, model_selection, naive_bayes, metrics, svm

from sklearn.neighbors import KNeighborsClassifier

# from IPython.display import Image
import warnings
warnings.filterwarnings("ignore")

#data prep

#stops load
#prepared in R
stops=pd.read_csv("stops.csv")
stoplist_mail= stops["word"].values.tolist()

#load data 
news_mail=pd.read_csv("news_mail.csv",  delimiter=";")

#start classif
f = feature_extraction.text.CountVectorizer(stop_words = stoplist_mail) 
X = f.fit_transform(news_mail["text"])
print(f.get_feature_names()[1000:1020])
X.shape
#split
X_train, X_test, y_train, y_test = model_selection.train_test_split(X, news_mail['label'], test_size=0.2, random_state=50)

print(X_train.shape, X_test.shape)
print(y_train.shape, y_test.shape) 
#prep hyper
list_alpha = np.arange(1/100000, 20, 0.11) 
print(len(list_alpha))
score_train = np.zeros(len(list_alpha)) 
score_test = np.zeros(len(list_alpha)) 
recall_test = np.zeros(len(list_alpha)) 
precision_test= np.zeros(len(list_alpha)) 

count = 0 
for alpha in list_alpha:
    bayes = naive_bayes.MultinomialNB(alpha=alpha) 
    bayes.fit(X_train, y_train) 
    score_train[count] = bayes.score(X_train, y_train)
    score_test[count]= bayes.score(X_test, y_test) 
    recall_test[count] = metrics.recall_score(y_test, bayes.predict(X_test),pos_label='mails')
    precision_test[count] = metrics.precision_score(y_test, bayes.predict(X_test),pos_label='mails')
    count = count + 1 


matrix = np.matrix(np.c_[list_alpha, score_train, score_test, recall_test, precision_test])
models = pd.DataFrame(data = matrix,
                      columns = ['alpha',
                                 'Train Accuracy',
                                 'Test Accuracy',
                                 'Test Recall',
                                 'Test Precision'])

print(matrix.shape)
print(models.head(10))
#get best
best_index = models['Test Accuracy'].idxmax()
print(models.iloc[best_index])

#final model
bayes = naive_bayes.MultinomialNB(alpha=2.530010, ) # используем лучшее значение alpha
bayes.fit(X_train, y_train)
y_pred = bayes.predict(X_test)

#check fit metrics
new_df = pd.DataFrame(data = y_test)
new_df["predicted"]=bayes.predict(X_test)
m_confusion_test = metrics.confusion_matrix(y_test, y_pred)
pd.DataFrame(data = m_confusion_test, columns = ['Predicted mail', 'Predicted news'],
            index = ['Actual news', 'Actual random'])
