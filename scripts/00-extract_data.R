# EXTRACT DATA 

# The 00-extract_data.R file is used to extract data from the Demographic and Health Survey Program 
# website. The file is used to extract the report stored on pages 31 and 32 of the pdf stored at 
# https://dhsprogram.com/pubs/pdf/FRIND1/FRIND1.pdf. The script reads the pdf and converts each line 
# into a row of the CSV file raw_data.csv

library(pdftools)
library(tidyverse)
library(dplyr)

options(timeout = max(1000, getOption("timeout")))

url <- "https://dhsprogram.com/pubs/pdf/FRIND1/FRIND1.pdf"
filepath_pdf <- "inputs/India National Family Health Survey 1992-1993.pdf"
filepath_csv <- "inputs/data/raw_data.csv"

download.file(url, filepath_pdf, mode="wb")

raw_pdf <- pdf_text(filepath_pdf) 
raw_pdf <- read_lines(raw_pdf)

raw_table <- tibble(raw_pdf[1129:1245])

colnames(raw_table) <- c("raw_data")

write.csv(raw_table, filepath_csv, row.names=FALSE)
