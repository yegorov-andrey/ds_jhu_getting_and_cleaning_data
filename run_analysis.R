library(readr)
library(dplyr)

get_feature_names <- function() {
        features <- read_delim('UCI HAR Dataset/features.txt', delim = ' ',
                               col_names = FALSE, trim_ws = TRUE)
        pull(features, 2)
}

get_dataset <- function(features, type) {
        basepath <- sprintf('UCI HAR Dataset/%s', type)

        measures <- read_delim(sprintf('%s/X_%s.txt', basepath, type),
                        delim = ' ', col_names = features,
                        trim_ws = TRUE)

        activities <- read_delim(sprintf('%s/y_%s.txt', basepath, type),
                                 delim = ' ', col_names = 'activity_id',
                                 trim_ws = TRUE)

        subjects <- read_delim(sprintf('%s/subject_%s.txt', basepath, type),
                               delim = ' ', col_names = 'subject', trim_ws = TRUE)
        
        mutate(measures, activities, subjects)
}

select_mean_and_std <- function(data) {
        features <- grep('-mean\\(\\)|-meanFreq\\(\\)|-std\\(\\)|activity_id|subject',
                         names(data), value = TRUE)
        select(data, features)
}

resolve_activities <- function(data) {
        activities <- read_delim('UCI HAR Dataset/activity_labels.txt',
                                 delim = ' ', col_names = c('id', 'activity'),
                                 trim_ws = TRUE)
        data %>%
                inner_join(activities, by = c('activity_id' = 'id')) %>%
                select(-activity_id)
        
}

# merge training and test data sets and select only mean and std variables
# with resolved activities (activity classes/codes replaced with activity names)
features <- get_feature_names()
train_data <- get_dataset(features, 'train')
test_data <- get_dataset(features, 'test')
data <- union_all(train_data, test_data) %>%
        select_mean_and_std %>%
        resolve_activities

# generate tidy data set with the average of each variable for each activity and each subject
tidy_data <- data %>% group_by(activity, subject) %>% summarize_all(mean)
write.table(tidy_data, 'tidy_data.txt', row.names = FALSE) 
