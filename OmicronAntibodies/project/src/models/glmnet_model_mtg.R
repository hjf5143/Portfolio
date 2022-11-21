library(data.table)
library(caret)
library(Metrics)
library(glmnet)
library(plotmo)
library(lubridate)



#read in data from interim and raw folder
train<-fread("./project/volume/data/interim/train.csv")
test<-fread("./project/volume/data/interim/test.csv")
example_sub<-fread("./project/volume/data/raw/Stat_380_sample_submission.csv")


#drop the Id column from train and test
drops<- c('Id')

train<-train[, !drops, with = FALSE]
test<-test[, !drops, with = FALSE]


#save the response var because dummyVars will remove
train_y<-train$ic50_Omicron

test$ic50_Omicron<-0


#create dummy vars
dummies <- dummyVars(ic50_Omicron ~ ., data = train)
train<-predict(dummies, newdata = train)
test<-predict(dummies, newdata = test)


train<-data.table(train)
test<-data.table(test)


# Use cross validation
train<-as.matrix(train)

test<-as.matrix(test)

gl_model<-cv.glmnet(train, train_y, alpha = 1,family="gaussian")

bestlam<-gl_model$lambda.min


#fit a logistic model
gl_model<-glmnet(train, train_y, alpha = 1,family="gaussian")

plot_glmnet(gl_model)

#save model
saveRDS(gl_model,"./project/volume/models/gl_model.model")

test<-as.matrix(test)

#use model on test data to get prediction
pred<-predict(gl_model,s=bestlam, newx = test)

bestlam
predict(gl_model,s=bestlam, newx = test,type="coefficients")
gl_model


# make a submission file by adding prediction to example_submission file
example_sub$ic50_Omicron<-pred
submit<-example_sub


#write out submission to processed folder
fwrite(submit,"./project/volume/data/processed/submit.csv")

