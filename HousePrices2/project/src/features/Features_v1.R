#load in libraries
library(data.table)
library(caret)

#load in data
train<-fread("./project/volume/data/raw/Stat_380_train2022.csv")
test<-fread("./project/volume/data/raw/Stat_380_test2022.csv")



#add a test SalePrice column and set all values to zero
test$SalePrice<-0


#add a column that lets you easily differentiate between train and test rows once they are together
test$train<-0
train$train<-1

#now bind them together and set key
master<-rbind(train,test)
setkey(master,Id)


# split
train<-master[train==1]
test<-master[train==0]


# clean up columns
train$train<-NULL
test$train<-NULL
test$SalePrice<-NULL


# write out to interim
fwrite(train,"./project/volume/data/interim/train.csv")
fwrite(test,"./project/volume/data/interim/test.csv")

