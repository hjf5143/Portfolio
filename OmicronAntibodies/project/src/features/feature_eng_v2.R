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


#bind test and train together and set key variable
master<-rbind(train,test)

setkey(master,Id)


#setting NA values to 1000 so that they are not included when finding smallest value
master$days_sinceDose2[is.na(master$days_sinceDose2)] <- 1000
master$days_sinceDose3[is.na(master$days_sinceDose3)] <- 1000
master$days_sincePosTest_latest[is.na(master$days_sincePosTest_latest)] <- 1000


#removing any values that are less than 1 day after the events
master$days_sinceDose2 <- ifelse(master$days_sinceDose2 < 1, 1000, master$days_sinceDose2[])
master$days_sinceDose3 <- ifelse(master$days_sinceDose3 < 1, 1000, master$days_sinceDose3[])
master$days_sincePosTest_latest <- ifelse(master$days_sincePosTest_latest < 1, 1000, master$days_sincePosTest_latest[])


#creating a new type column to find which event happened most recently
master$type <- ifelse(master$days_sinceDose2 <  master$days_sincePosTest_latest & master$days_sinceDose3, 'Dose2',
                          ifelse(master$days_sincePosTest_latest < master$days_sinceDose3 & master$days_sinceDose2, 'PositiveTest',
                                 ifelse(master$days_sinceDose3 < master$days_sincePosTest_latest & master$days_sinceDose2, 'Dose3', 'Other')))


#creating a new type column to find value of event that happened most recently
master$accuratevalue <- ifelse(master$days_sinceDose2 <  master$days_sincePosTest_latest & master$days_sinceDose3,  master$days_sinceDose2[],
                            ifelse(master$days_sincePosTest_latest < master$days_sinceDose3 & master$days_sinceDose2, master$days_sincePosTest_latest[],
                                ifelse(master$days_sinceDose3 < master$days_sincePosTest_latest & master$days_sinceDose2, master$days_sinceDose3[], 1000)))


#if accurate value column turns out to include 1000 still, set value to the mean of the column
master$accuratevalue <- ifelse(master$accuratevalue == 1000, mean(master$accuratevalue,na.rm=T), master$accuratevalue[])

                           
#remove any NA values and set to zero
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

