# HW 5 
# Group: Elizabeth Braatz (had to skip lecture due to family health emregency) 


####################### 
#Installing libraries 
#####################
#install.packages("dplyr")
#install.packages("readxl")
#install.packages('here')
#install.packages('writexl')
#install.packages('readr') 

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

#Write our files

#Write csv 
data_file_path = here("Output","fish.csv")
write.csv(fish, data_file_path, row.names = FALSE) 

#write xlsx 
data_file_path = here("Output","fish.xlsx")
library(readxl)
library(writexl)
write_xlsx(fish, data_file_path)

#write rds 
library(readr)
data_file_path = here("Output","fish.rds")
write_rds(fish, data_file_path)

#2. Compare file sizes using file.info() for the three files containing the same data.

file.info(c("Output/fish.csv", "Output/fish.xlsx", "Output/fish.rds"))$size

#3. Write a short note: which format is best for (a) sharing, (b) compact storage?

# If the person receiving the data has R, I imagine that rds is the best way to share because it preserves the data structure, so they can just read it right into R and be where you were. If the person does not have R, I imagine that sharing in xlsx is the best format because Excel is a very nicely formatted and pretty universal program. However, if you need compact storage, it looks like csv is the best format because it had the smallest size (12,000 vs 17,000 with rds). 

#####################################################################
#Problem 3 -- wrangling pipelines with dplyr 
####################################################################

#Task 1 
target_fish = c("Walleye","Yellow Perch","Smallmouth Bass") 
target_lake = c("Erie","Michigan") 
fish_output = fish %>% 
  filter(Species %in% target_fish, Lake %in% target_lake) %>% 
  select(-Age_years) %>%
  mutate(Length_mm = Length_cm*10)

#Task 2 
#Define bins and labels 
bins = c(0, 200, 400, 600, Inf)   
labels = c("<= 200", "200-400", "400-600", ">600") 
fish_output = fish_output %>%
  mutate(len_bin = cut(Length_mm, breaks = bins, labels = labels, right = FALSE)) %>%
  count(Species,len_bin, name = "n") %>% 
  group_by(Species, len_bin) 

#Task 3 
fish_output = fish %>%
  group_by(Species, Year) %>% 
  summarise(
    mean_weight = mean(Weight_g, na.rm = TRUE), 
    median_weight = median(Weight_g, na.rm = TRUE), 
    sample_size = n(), 
    .groups = "drop"
  )

#Task 4 
library(ggplot2)
p = ggplot(fish_output, aes(x = Year, y = mean_weight, color = Species)) + 
  geom_line(linewidth = 1) + 
  geom_point() + 
  labs(title = "Mean Weight by Species and Year", 
       x = "Year", 
       y = "Mean Weight (g)") + 
  theme_minimal() 
p

#Task 5 

#write fish_output into csv 
data_file_path = here("Output","fish_output.csv") 
write.csv(fish_output, data_file_path, row.names = FALSE) 

#Save teh ggplot2 
data_file_path = here("Output")
ggsave("mean_weight.png", 
       path = data_file_path)

#####################################################################
#Problem 4 -- reading multiple files at once 
####################################################################

# List all files 
all_files <- list.files("Data/Multiple_files", full.names = TRUE)
all_files

# Read them all into a list
all_list_csv <- lapply(all_files, read.csv)
class(all_list_csv)
View(all_list_csv) #this is a list, not a dataframe 

# Combine into one data frame
all_data <- dplyr::bind_rows(all_list_csv) #wait, did we just remake what you gave us earlier?! Hmph! :/ 

#####################################################################
#Problem 5 --  Bootstrapping in series and parallel 
####################################################################

# Setup 

library(parallel)                            #already built in, just call it 
fish = all_data                              #renaming our dataframe 
species_list = unique(fish$Species)               #list of species to loop over 
library(dplyr)

#creating a bootstrap function 

boot_mean_weight = function(Species, n_boot, sample_size) {
  #nboot = number of bootstraps 
  #sample_size means sample 200 fish each time for each species 
  x = fish %>% 
  filter(Lake == "Erie", Species == !!Species) %>% 
  pull(Weight_g) #it works like select but for a vector intsead of dataframe 
  means = replicate(n_boot, mean(sample(x, size = sample_size, replace = TRUE)))
  mean(means)
}

#testing bootstrap function 
boot_mean_weight(species_list[3], 10000,200) #yep it's working 

# Serial Option -----------------------------------------------------------

t_serial <- system.time({                   # time the whole serial run
  res_serial <- lapply(                     # loop over species in the main R process
    species_list,                                # input: vector of species names
    boot_mean_weight,                              # function to apply
    n_boot = 10000,                           # number of bootstrap resamples per species
    sample_size = 200                       # bootstrap sample size
  )
})

t_serial
# elapsed time = 1.69 seconds 

# Parallel processing --------------------------------------------------------

detectCores() #let's test how many cores my computer has, it says 14 but it probably multithreads, so it could be either 7 or 14-1 = 13 that we should use 


n_cores <- max(1, detectCores() - 1)   # use all but one core (be nice to your laptop)
n_cores = max(1, detectCores() / 2)# actually just using half our cores is better 
cl <- makeCluster(n_cores)                  # start worker processes

clusterSetRNGStream(cl, iseed = 123)        # make random numbers reproducible across workers

# Send needed objects to workers (function + data + species vector)
clusterEvalQ(cl, library(dplyr)) #apparently we need to load the dplyr library into the cluster evaluation or it gets real mad 
clusterExport(cl, varlist = c("fish", "boot_mean_weight", "species"), envir = environment())
# library("dplyr") originally I just tried calling hte dplyr library separately but it got confused 
t_parallel <- system.time({                 # time the parallel run
  res_parallel <- parLapply(                # same API as lapply(), but across workers
    cl,                                     # the cluster
    species,                                # each worker gets one species (or more)
    boot_mean_weight,                              # function to run
    n_boot = 10000,                           # same bootstrap settings as serial
    sample_size = 200
  )
})
stopCluster(cl)                             # always stop the cluster when done

t_parallel
#our elapsed time is 0.64, much smaller 
#Interestingly, I ran it with n-1 cores = 13, but running it with 7 cores was even faster (0.59 seconds), probably due to hyperthreading. 


# Overall: the series was slowest, running for 1.69 seconds. The parallel processing using all but one core was second fastest at 0.64 seconds. The parallel process using half hte cores was the fastest at 0.59 seconds, likely due to hyperthreading (it can process two cores from every one of its physical cores, but they might be sharing some resources and it could be easiest to just use your physical cores) 
