# objective: code template

# preparation
rm(list = ls())
# obtain the current source file work directory
wd <- getwd()


# load all the necessary packages
library(DBI)
library(RJDBC)
library(keyring)
library(readxl)
library(reshape)
library(tidyverse)
library(data.table)
library(lubridate)
library(patchwork)





#------------------------------------------------------------------------------#
########## step 0 define a few variables and functions###########
#------------------------------------------------------------------------------#
# define a few variables and functions
current_date <- Sys.Date()
username <- "b615197"

# a function to convert character vector to sql statement
vector_to_sql <- function(vec) {
        # given a character vector
        # output the corresponding sql statement such as ('a', 'b')
        
        statement <- ""
        for (i in 1:length(vec)) {
                element <- paste0("'", vec[i], "'")
                statement <- paste0(statement, ",", element)
        }
        # remove first `,`
        statement <- str_sub(statement, 2)
        statement <- paste0("(", statement, ")")
        return(statement)
}

# define a function to convert FW to calendar week or the other way
my_date_conversion <- function (my_date, df_lookup) {
        # given date input and date lookup table
        # return corresponding fiscal week or calendar week
        
        if (is.Date(my_date)) {
                my_date <- floor_date(my_date, unit = "week")
                output <- df_lookup$FW[df_lookup$week %in% my_date]
        } else if (grepl("FY", my_date)) {
                output <- df_lookup$week[df_lookup$FW %in% my_date]
        } else {
                output <- "my_date must be either a calendar date or a fiscal date"
        }
        
        return(output)
}

# a function to change y axis to thousands, millions, and billions based on the number range
add_units <- function(n) {
        labels <- ifelse(n < 1000, n,  # less than thousands
                         ifelse(n < 1e6, paste0(round(n/1e3), 'k'),  # in thousands
                                ifelse(n < 1e9, paste0(round(n/1e6), 'M'),  # in millions
                                       ifelse(n < 1e12, paste0(round(n/1e9), 'B'), # in billions
                                              ifelse(n < 1e15, paste0(round(n/1e12), 'T'), # in trillions
                                                     'too big!'
                                              )))))
        return(labels)
}




#------------------------------------------------------------------------------#
########## step 1 read raw files ###########
#------------------------------------------------------------------------------#

