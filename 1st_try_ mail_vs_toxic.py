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

#start classif
f = feature_extraction.text.CountVectorizer(stop_words = stoplist_mail)
X = f.fit_transform(tryout["text"])
print(f.get_feature_names()[1000:1020])
print(X.toarray())
X.shape
X_train, X_test, y_train, y_test = model_selection.train_test_split(X, tryout['label'], test_size=0.2, random_state=50)
print(X_train.shape, X_test.shape)
print(y_train.shape, y_test.shape) 

#tune
list_alpha = np.arange(1/100000, 20, 0.11) 
print(len(list_alpha))
score_train = np.zeros(len(list_alpha)) # accuracy on train set
score_test = np.zeros(len(list_alpha)) #accuracy on test set
recall_test = np.zeros(len(list_alpha)) # recall on test
precision_test= np.zeros(len(list_alpha)) 

count = 0 
for alpha in list_alpha: # для каждого значения в списке альф
    bayes = naive_bayes.MultinomialNB(alpha=alpha) # вызываем модель
    bayes.fit(X_train, y_train) # тренируем модель
    score_train[count] = bayes.score(X_train, y_train) # итерируемся по индексу в листе, добавляем значения accuracy on train
    score_test[count]= bayes.score(X_test, y_test) # то же самое,но для accuracy на тестовой выборке
    # а теперь для precision и recall
    recall_test[count] = metrics.recall_score(y_test, bayes.predict(X_test),pos_label='mails')
    precision_test[count] = metrics.precision_score(y_test, bayes.predict(X_test),pos_label='mails')
    count = count + 1 # после одной итерации, делаем новый шаг,  чтобы пройтись по всем alpha

#check fit metrics
matrix = np.matrix(np.c_[list_alpha, score_train, score_test, recall_test, precision_test])
models = pd.DataFrame(data = matrix,
                      columns = ['alpha',
                                 'Train Accuracy',
                                 'Test Accuracy',
                                 'Test Recall',
                                 'Test Precision'])


print(models.head(10))
print(matrix.shape)
#get best metrics
best_index = models['Test Accuracy'].idxmax()
print(models.iloc[best_index])
bayes = naive_bayes.MultinomialNB(alpha=16.390010, )
bayes.fit(X_train, y_train)
y_pred = bayes.predict(X_test)

#сделаем датафрейм с колонками для настоящего класса(это y_test) и для предсказанного (y_pred)

new_df = pd.DataFrame(data = y_test)
new_df["predicted"]=bayes.predict(X_test)
m_confusion_test = metrics.confusion_matrix(y_test, y_pred)
pd.DataFrame(data = m_confusion_test, columns = ['Predicted mail', 'Predicted random'],
            index = ['Actual mail', 'Actual random'])
