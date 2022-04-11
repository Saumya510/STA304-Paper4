# DATA CLEANING

# The purpose of this file is to clean the raw_data.csv file to create clean_data.csv.
# We use this file to create a matrix of all the numeric values read from the raw_data.csv file 
# and create a dataframe that has the appropriate column and row names.

# We test the data produced using pointblank and gnerate the report for the same. 

library(tidyverse)
library(pointblank)
library(dplyr)

raw_data <- read_csv("inputs/data/raw_data.csv")

# remove nas 
raw_data <- na.omit(raw_data)
# extract only the rows with the table values
raw_data <- raw_data[-c(1:11, 13, 20, 23, 27, 35, 43:59, 67, 70, 74, 82, 86, 91:98),]

# remove spaces at the start and the 
raw_data <- mutate(raw_data, raw_data=str_trim(raw_data))
raw_data <- mutate(raw_data, raw_data=str_squish(raw_data))

# replace all the incorrect characters produced while reading the pdf 
# into decimal points 

for (i in 1:52){
  values <- strsplit(raw_data$raw_data[i], " ")[[1]] 
  for (j in 1:length(values)){
    values[j] <- str_replace(values[j][1], "-", ".") 
    values[j] <- str_replace(values[j][1], "_", ".") 
    values[j] <- str_replace(values[j][1], " .", ".")
  }
  raw_data[i,] <- toString(values)
}

# create a matrix to store all the numeric values on page 31
x1 <- matrix(rep(0, 312), nrow=26, byrow=TRUE)

for (i in 1:26) {
  arr1 <- strsplit(raw_data$raw_data[i], ", ")[[1]] # extract all the numbers in a row of this datafrmae
  
  # We reverse the string to extract the last 12 values in each row 
  # We refered to the logic in https://statisticsglobe.com/rev-r-function and 
  # https://www.geeksforgeeks.org/reverse-the-values-of-an-object-in-r-programming-rev-function/
  arr1 <- rev(arr1) 
  
  # the first 12 values in the reserved strings are values of interest 
  arr1 <- arr1[1:12] 
  
  # reverses the string again to get the correct order
  arr1 <- rev(arr1)
  
  # convert it back to numberic to be inserted into our matrix
  arr1 <- as.numeric(arr1) 
  
  # add these values into the matrix
  x1[i, ] <- arr1 
}

# we have hardcoded a value in x1 as it wasnt read correctly from the pdf
x1[x1 == "0.6"] <- "17.6"


# obtain the datapoints to fill a 26x11 matrix
x2<- matrix(rep(0, 286), nrow=26, byrow=TRUE)

# now for page 2
for (i in 27:52) {
  
  arr2 <- strsplit(raw_data$raw_data[i], ", ")[[1]] # extract all the numbers in a row of this datafrmae
  
  # We reverse the string to extract the last 11 values in each row 
  # We refered to the logic in https://statisticsglobe.com/rev-r-function and 
  # https://www.geeksforgeeks.org/reverse-the-values-of-an-object-in-r-programming-rev-function/
  arr2 <- rev(arr2)
  
  # the first 11 values in the reserved strings are values of interest 
  arr2 <- arr2[1:11] 
  
  # reverses the string again to get the correct order
  arr2 <- rev(arr2)
  
  # convert it back to numberic to be inserted into our matrix
  arr2 <- as.numeric(arr2) 
  
  # add these values into the matrix
  x2[i-26, ] <- arr2 
}

# we have hardcoded two value in x2 as it wasnt read correctly from the pdf
x2[12, 8] <- 53.6
x2[2, 10] <- 43.2

# merge the two matrices 
mat_final <- cbind(x1, x2)

df_columns <- c("Percent illiterate (females age 6+)",
                "Percent attending school (females age 6-14)",
                "Percent of households with drinking water from pump/pipe",
                "Percent of households with no toilet facility",
                "Percent women age 20-24 married before age 18",
                "Crude Birth Rate", 
                "Total Fertility Rate", 
                "Percent of women using any contraceptive method", 
                "Percent of women using sterilization", 
                "Unmet need for family planning", 
                "Infant mortality rate", 
                "Under 5 mortality", 
                "Mothers receiving antenatal care (last 4 years)", 
                "Mothers receiving two doses of tetanus vaccine (last 4 years)", 
                "Births delivered in health facility (last 4 years)", 
                "Deliveries assisted by health professional (last 4 years)", 
                "Children who received ORS for diarrhea (last 4 years)", 
                "Percent of children fully immunized (age 12-23 months)", 
                "Percent of children exclusively breasted (age 0-3 months)", 
                "Percent of children receiving breastmilk and solid food (age 6-9 months)", 
                "Percent of children under 4 years of age underweight", 
                "Percent of children under 4 years of age  stunted", 
                "Percent of children under 4 years of age  wasted")

df_state <- c("India", "Delhi", "Haryana", "Himachal Pradesh", 
              "Jammu & Kashmir", "Punjab", "Rajasthan", "Madhya Pradesh", 
              "Uttar Pradesh", "Bihar", "Orissa", "West Bengal", 
              "Arunachal Pradesh", "Assam", "Manipur", "Meghalaya", 
              "Mizoram", "Nagaland", "Tripura", "Goa", "Gujarat", 
              "Maharashtra", "Andhra Pradesh", "Karnataka", "Kerala", 
              "Tamil Nadu")


df_final <- data.frame(mat_final)

colnames(df_final) <- df_columns

df_final$`States` <- df_state

df_final <- select(df_final, `States`, everything())

# Test the data generated using pointblank
agent <-
  create_agent(tbl = df_final) %>%
  col_is_numeric(columns = 1:23) %>% # test that the variables that should be numeric are
  col_is_character(columns = vars(States)) %>% # test that the variables that should be characters are
  interrogate()

report <- get_agent_report(agent)

# Save cleaned data csv
write.csv(df_final, "inputs/data/clean_data.csv", row.names=FALSE)
