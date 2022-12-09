library(data.table)

#load in data
dog_dt<-fread("./project/volume/data/raw/data.csv")

#write to interim folder
fwrite(dog_dt,"./project/volume/data/interim/dog_data.csv")


#sample_1 is breed 3
#sample_5 is breed 2
#sample_6 is breed 4