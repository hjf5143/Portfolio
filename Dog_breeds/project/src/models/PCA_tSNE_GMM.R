library(data.table)
library(Rtsne)
library(caret)
library(ggplot2)
library(ClusterR)

#load in data 
data<-fread("./project/volume/data/raw/dog_data.csv")
example_sub<-fread("./project/volume/data/raw/example_sub.csv")

drops<- c('id')

data<-data[, !drops, with = FALSE]


#do a pca
pca<-prcomp(data)

#look at the percent variance explained by each pca
screeplot(pca)

#look at the rotation of the variables on the PCs
pca

#see the values of the scree plot in a table 
summary(pca)

#create a biplot of the first 2 PCs
biplot(pca)

#use the unclass() function to get the data in PCA space
pca_dt<-data.table(unclass(pca)$x)


#run tsne model

tsne<-Rtsne(pca_dt,pca = F,perplexity=50,check_duplicates = F)

# grab out the coordinates
tsne_dt<-data.table(tsne$Y)

#plot V1 and V2
ggplot(tsne_dt,aes(x=V1,y=V2))+geom_point()



# use a gaussian mixture model to find optimal k and probability for each cluster

#fits a gmm to the data for all k=1 to k= max_clusters, to look for a major change in likelihood between k values
k_bic<-Optimal_Clusters_GMM(tsne_dt[,.(V1,V2)],max_clusters = 10,criterion = "BIC")

#calculate change in successive k values
delta_k<-c(NA,k_bic[-1] - k_bic[-length(k_bic)])

#create plot to see best k value
del_k_tab<-data.table(delta_k=delta_k,k=1:length(delta_k))

# plot 
ggplot(del_k_tab,aes(x=k,y=-delta_k))+geom_point()+geom_line()+
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10))+
  geom_text(aes(label=k),hjust=0, vjust=-1)


#set optimal k parameter
opt_k<-4

#run model with chosen optimal k value
gmm_data<-GMM(tsne_dt[,.(V1,V2)],opt_k)

# model give log likelihood for the clusters

l_clust<-gmm_data$Log_likelihood^8

l_clust<-data.table(l_clust)

#covert log-likelihood into a probability

net_lh<-apply(l_clust,1,FUN=function(x){sum(1/x)})

cluster_prob<-1/l_clust/net_lh

#plot of cluster_1

tsne_dt$Cluster_1_prob<-cluster_prob$V1

ggplot(tsne_dt,aes(x=V1,y=V2,col=Cluster_1_prob))+geom_point()

#merge cluster_prob and the example submission

cluster_prob$idval <- 1:nrow(cluster_prob)
example_sub$idval <- 1:nrow(example_sub)

master <- merge(cluster_prob, example_sub, by = "idval")

master$breed_1 <-master$V1
master$breed_2 <-master$V2
master$breed_3 <-master$V4
master$breed_4 <-master$V3

#write out submission
fwrite(master[,.(id,breed_1,breed_2,breed_3,breed_4)],'./project/volume/data/processed//submit.csv')







