#load in libraries
library(data.table)
library(caret)

#load in data
train<-fread("./project/volume/data/raw/Stat_380_train.csv")
test<-fread("./project/volume/data/raw/Stat_380_test.csv")

#add a test ic50_Omicron column and set all values to zero
test$ic50_Omicron<-0

#add a column that lets you easily differentiate between train and test rows once they are together
test$train<-0
train$train<-1

#now bind them together

master<-rbind(train,test)
setkey(master,Id)


#set NA values to 1000
master$days_sincePosTest_latest[is.na(master$days_sincePosTest_latest)]<- 1000


#create new value column with the smaller value and label it Dose2 or PositiveTest
master$newvalue <- ifelse(master$days_sinceDose2 <  master$days_sincePosTest_latest, 'Dose2', 'PositiveTest')


#grab smaller value from the columns and add to accuratevalue
master$accuratevalue <- ifelse(master$days_sinceDose2 <  master$days_sincePosTest_latest, master$days_sinceDose2[], master$days_sincePosTest_latest[])
                           
master[is.na(master)]<-0


# split
train<-master[train==1]
test<-master[train==0]


# clean up columns
train$train<-NULL
test$train<-NULL
test$ic50_Omicron<-0


# write out to interim #
fwrite(train,"./project/volume/data/interim/train.csv")
fwrite(test,"./project/volume/data/interim/test.csv")

