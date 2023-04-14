#Import packages
import numpy as np
import pandas as pd
import pickle
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score


#Load in Data
df = pd.read_csv('C:\\Users\\frist\\OneDrive\\Desktop\\DiabetesPredictionWebsite\\DiabetesData\\diabetes_binary_5050split_health_indicators_BRFSS2015.csv')
#print(df.head())
X = df.drop(columns=['Diabetes_binary', 'Age', 'Income', 'GenHlth', 'NoDocbcCost', 'Age', 'Education'])
y = df['Diabetes_binary']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=1)


from sklearn.neighbors import KNeighborsClassifier
KNNModel = KNeighborsClassifier().fit(X_train, y_train)
#Save the Model
filename = 'FinalKNNModel.sav'
pickle.dump(KNNModel, open(filename, 'wb'))

predictions = KNNModel.predict(X_test)
results = accuracy_score(y_test, predictions)
print(results)

