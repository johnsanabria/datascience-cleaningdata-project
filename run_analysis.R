# run_analysis.R
# To read activity labels
#
# reading activity_labels.txt
#
ini_time <- Sys.time()
activity <- read.table("activity_labels.txt", colClasses = "character")
names(activity) <- c("id", "name")
activity$id <- as.numeric(activity$id)
#
# reading features.txt
#
features <- read.table("features.txt", colClasses = "character")
names(features) <- c("id", "name")
features$id <- as.numeric(features$id)
#####################
# Reading train dir #
#####################
subject_train <- read.table("train/subject_train.txt") # one column
names(subject_train) <- c("subject_id")
X_train <- read.table("train/X_train.txt")
names(X_train) <- as.vector(features$name)
y_train <- read.table("train/y_train.txt") # one column
names(y_train) <- c("activity")
y_train$activity <- sapply(y_train$activity, function(x) activity[activity$id == x,]$name)
train <- cbind(y_train, X_train)
train <- cbind(subject_train, train)
#####################
# Reading test dir #
#####################
subject_test <- read.table("test/subject_test.txt") # one column
names(subject_test) <- c("subject_id")
X_test <- read.table("test/X_test.txt")
names(X_test) <- as.vector(features$name)
y_test <- read.table("test/y_test.txt") # one column
names(y_test) <- c("activity")
y_test$activity <- sapply(y_test$activity, function(x) activity[activity$id == x,]$name)
test <- cbind(y_test, X_test)
test <- cbind(subject_test, test)
# 
# Consolidation
#
data <- rbind(train, test)
data <- data[order(data$subject_id),]
datamean <- data[,features[grep("*mean*",features$name),]$name]
datastd <- data[,features[grep("*std*",features$name),]$name]

if (file.exists("data.txt"))
  file.remove("data.txt")
for (i in 1:30) {
  x <- data[data$subject_id == i,]                
  for (j in activity$name) {
    y <- x[x$activity == j,]
    for (k in features$name) {
      m <- mean(y[,k])
      s <- sd(y[,k])
      write(sprintf("%i %s %s %f %f",i,j,k,m,s), file="data.txt", append=TRUE)
    }
  }
}
consolidateddata <- read.table(file = "data.txt")
names(consolidateddata) <- c("subject_id", "activity", "feature", "mean", "standard deviation")
if (file.exists("data5.txt"))
  file.remove("data5.txt")
write.table(consolidateddata,file = "data5.txt", row.name=FALSE)
print(Sys.time() - ini_time)