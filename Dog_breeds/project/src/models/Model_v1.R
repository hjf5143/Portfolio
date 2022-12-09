library(data.table)
library(Rtsne)
library(ggplot2)
library(caret)
library(ggplot2)
library(ClusterR)


#load in data 
data<-fread("./project/volume/data/interim/dog_data.csv")
example_sub<-fread("./project/volume/data/raw/example_sub.csv")

drops<- c('id')

data<-data[, !drops, with = FALSE]

#run pca
pca<-prcomp(data)

#look at the percent variance explained by each pca
screeplot(pca)

#look at the rotation of the variables on the PCs
pca

#see the values of the plot in a table 
summary(pca)

#create a biplot of the first 2 PCs
biplot(pca)

#use the unclass() function to get the data in PCA space
pca_dt<-data.table(unclass(pca)$x)

#plot pca values
ggplot(pca_dt,aes(x=PC1,y=PC2))+geom_point()



#combine pca and example_sub into 1 table
pca_dt$idval <- 1:nrow(pca_dt)
example_sub$idval <- 1:nrow(example_sub)
 
master <- merge(pca_dt, example_sub, by = "idval")

#assign probability of the breeds for each cluster
master$breed_4 <- ifelse(master$PC1 >  11, 0.7, 0.25)
master$breed_2 <- ifelse(master$PC1 >  11, 0.1, 0.25)
master$breed_3 <- ifelse(master$PC1 >  11, 0.1, 0.25)
master$breed_1 <- ifelse(master$PC1 >  11, 0.1, 0.25)


#write out submission
fwrite(master[,.(id,breed_1,breed_2,breed_3,breed_4)],'./project/volume/data/processed//submit.csv')






