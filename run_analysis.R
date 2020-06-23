# load required libraries
library(tidyverse)
library(magrittr)

# read the names of features and activities from file
Feature <- read_table2("UCI HAR Dataset/features.txt",col_names = F)
Activity <- read_table2("UCI HAR Dataset/activity_labels.txt",col_names = F)

# read test data
Data_test <- read_table2("UCI HAR Dataset/test/X_test.txt",col_names = F)
Activity_test <- read_table2("UCI HAR Dataset/test/Y_test.txt",col_names = F)
Subject_test <- read_table2("UCI HAR Dataset/test/subject_test.txt",col_names = F)

# read train data
Data_train <- read_table2("UCI HAR Dataset/train/X_train.txt",col_names = F)
Activity_train <- read_table2("UCI HAR Dataset/train/Y_train.txt",col_names = F)
Subject_train <- read_table2("UCI HAR Dataset/train/subject_train.txt",col_names = F)

# merge test and train measurements and extract the columns contain mean & std
Merged_data <- bind_rows(Data_test, Data_train)
Merged_data %<>%
        .[, grep("std|mean", pull(Feature, 2))]

# add the name of each measurement
names(Merged_data) <- grep("std|mean", pull(Feature, 2), value = T)

# merge test and train subjects and add column name
Merged_subject <- bind_rows(Subject_test, Subject_train)
names(Merged_subject) <- "Subject"

# merge test and train activity labels and change it to activitiy names
Merged_activity_label <- bind_rows(Activity_test, Activity_train)
Activity %<>%
        .[pull(Merged_activity_label),2]
names(Activity) <- "Activity"

# merge the 3 tibbles above
All_data <- bind_cols(Merged_subject, Activity, Merged_data)

# make column names more readable (and descriptive?)
names(All_data) %<>%
        gsub(pattern = "\\(\\)", replacement = "") %>%
        gsub(pattern = "\\-", replacement = "_")

# create a tidy data set with the average of each variable for each
# activity and each subject
Tidy_data <- All_data %>%
        group_by(Subject, Activity) %>%
        summarize_each(funs = mean)

# write the tidy data set into a file
write.table(Tidy_data, file = "TidyDataSet.txt", row.names = FALSE)