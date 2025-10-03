# HW 5 
# Group: Elizabeth Braatz (had to skip lecture due to family health emregency) 


####################### 
#Installing libraries 
#####################
#install.packages("dplyr")
#install.packages("readxl")
#install.packages('here')


#########################
# Setting up filepaths 
#########################

library(here)
data_file_path = here("Data","fish.csv") #Create a filepath in the 'input' subdirectory of your peojct root 
test = read.csv(data_file_path)


#####################################################################
#Problem 1 – Reading Different Data Types
####################################################################

#Download three files
#https://github.com/xucamel/Quantitative_course_week5/tree/main/HW/Data
#• A .csv file (fish.csv)
#• An .xlsx file (fish.xlsx)
#• An .rds file (fish.rds)
#Tasks
#1. Import all three into R.
#2. Print the first five rows of each dataset.

#Downloading and displaying first 5 rows of fish.csv 
data_file_path = here("Data","fish.csv") #Create a filepath in the 'input' subdirectory of your peojct root 
fish = read.csv(data_file_path)
head(fish, 5)

#Downloading and displaying first 5 rows of fish.xlsx 
library(readxl)
data_file_path = here("Data","fish.xlsx")
fish_xlsx <- read_excel(data_file_path,sheet = 1)
head(fish_xlsx, 5)

#Downloading and displaying first five rows of fish.rds 
data_file_path = here("Data","fish.rds")
fish_rds = readRDS(data_file_path)
head(fish_rds, 5)

#####################################################################
#Problem 2 – Writing Different Data Types
####################################################################

#Take a fish dataset and save it as .csv, .rds, and .xlsx in an output folder 

#Create an output folder 
path = "C:/Users/Elizabeth/Documents/School/2025 Semester 1/ZOO800 Stats/Homework Assignments/HW5/Data"
newfolder = "Output"
#dir.create(file.path(dirname(path), newfolder)) #Commenting this out so we don't keep trying to make new output folders 


#2. Compare file sizes using file.info() for the three files containing the same data.
#3. Write a short note: which format is best for (a) sharing, (b) compact storage?






