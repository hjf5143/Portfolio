#load in libraries
library(data.table)
library(caret)
library(Metrics)
library(xgboost)

#Load in Files
train<-fread("./project/volume/data/interim/train.csv")
test<-fread("./project/volume/data/interim/test.csv")
example_sub<-fread("./project/volume/data/raw/Stat_380_sample_submission.csv")


#Prepare data for Modeling
drops<- c('Id')

train<-train[, !drops, with = FALSE]
test<-test[, !drops, with = FALSE]

y.train<-train$SalePrice
test$SalePrice<-0


#Create the dummies
dummies <- dummyVars(SalePrice~ ., data = train)
x.train<-predict(dummies, newdata = train)
x.test<-predict(dummies, newdata = test)

#Setting up xgboost matrices
dtrain <- xgb.DMatrix(x.train,label=y.train,missing=NA)
dtest <- xgb.DMatrix(x.test,missing=NA)

hyper_perm_tune<-NULL

#Setting Parameters

param <- list(  objective           = "reg:linear",
                gamma               = 0.00,
                booster             = "gbtree",
                eval_metric         = "rmse",
                eta                 = 0.01,
                max_depth           = 3,
                min_child_weight    = 5,
                subsample           = 0.5,
                colsample_bytree    = 1.0,
                tree_method = 'hist'
)


XGBm<-xgb.cv( params=param,nfold=5,nrounds=100000000,missing=NA,data=dtrain,print_every_n=1,early_stopping_rounds=25)

best_ntrees<-unclass(XGBm)$best_iteration

new_row<-data.table(t(param))

new_row$best_ntrees<-best_ntrees

test_error<-unclass(XGBm)$evaluation_log[best_ntrees,]$test_rmse_mean
new_row$test_error<-test_error
hyper_perm_tune<-rbind(new_row,hyper_perm_tune)

#Add to watchlist
watchlist <- list( train = dtrain)

#Fit the full model
XGBm<-xgb.train( params=param,nrounds=best_ntrees,missing=NA,data=dtrain,watchlist=watchlist,print_every_n=1)

#Create the prediction
pred<-predict(XGBm, newdata = dtest)


#Make a submission file by adding prediction to example_submission file
example_sub$SalePrice<-pred
submit<-example_sub


#Write out submission to processed folder
fwrite(submit,"./project/volume/data/processed/submit.csv")

#Write out hyper_perm_tune engineering
fwrite(hyper_perm_tune,"./project/volume/data/interim/hyper_perm_tune.csv")

