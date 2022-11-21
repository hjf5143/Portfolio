library(data.table)
library(Metrics)

#load in data from interim
train <- fread("./project/volume/data/interim/train.csv")
test <- fread("./project/volume/data/interim/test.csv")

#take mean of ic50_Omicron by sex
averageic50 <- train[,.(ic50_Omicron=mean(ic50_Omicron)),by=sex]


#set key values
setkey(averageic50,sex)
setkey(test,sex)

#merge test and average50 and order by Id
test <- merge(test,averageic50, all.x=T)


#write to processed folder
test <- test[order(Id)]
fwrite(test[,.(Id,ic50_Omicron)],'./project/volume/data/processed/NullModel.csv')

     

