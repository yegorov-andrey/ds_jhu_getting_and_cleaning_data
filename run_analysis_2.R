library(dplyr)

# check if zip file with the raw data already exists
if (!file.exists("UCI_HAR_Dataset.zip")) {
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, "UCI_HAR_Dataset.zip", method="curl")
}  

# check if folder exists with the raw data already exists
if (!file.exists("UCI HAR Dataset")) { 
        unzip("UCI_HAR_Dataset.zip") 
}

# 0. Load all data sets, including feature names, activity labels, training and test sets.
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("id", "name"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$name, check.names = FALSE)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$name, check.names = FALSE)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

# 1. Merge training and the test sets to create one data set.
train <- cbind(subject_train, y_train, x_train)
test <- cbind(subject_test, y_test, x_test)
data <- rbind(train, test)

# 2. Extract only the measurements on the mean and standard deviation for each measurement.
data <- data %>% select(Subject, code, contains(c("-mean()", "-meanFreq()", "-std()")))

# 3. Use descriptive activity names to name the activities in the data set.
data$code <- activities[data$code, 2]

# 4. Label the data set with descriptive variable names.
names(data)[2] <- "Activity"
names(data) <- names(data) %>%
        gsub("Acc", "Accelerometer", .) %>%
        gsub("Gyro", "Gyroscope", .) %>%
        gsub("BodyBody", "Body", .) %>%
        gsub("Mag", "Magnitude", .) %>%
        gsub("^t", "Time", .) %>%
        gsub("^f", "Frequency", .) %>%
        gsub("tBody", "TimeBody", .) %>%
        gsub("-mean\\(\\)", ".Mean", .) %>%
        gsub("-meanFreq\\(\\)", ".MeanFrequency", .) %>%
        gsub("-std\\(\\)", ".STD", .) %>%
        gsub("-freq\\(\\)", ".Frequency", .) %>%
        gsub("angle", "Angle", .) %>%
        gsub("gravity", "Gravity", .) %>%
        gsub("-", ".", .)

# 5. Create tidy data set with the average of each variable for each activity and each subject.
agg_data <- data %>%
        group_by(Subject, Activity) %>%
        summarise_all(mean)
write.table(agg_data, "output_data.txt", row.names = FALSE)
