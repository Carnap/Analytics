library(tidyr)#, include.only=c('unite', 'pivot_wider'))
library(forcats, include.only = 'fct_reorder')
library(ggplot2)
library(dplyr)
library(data.table)
library(gtools, include.only = c('mixedsort','mixedorder'))
library(stringi, include.only = c('stri_detect_regex', 'stri_sub', 'stri_detect_regex', 'stri_join', 'stri_replace_all_regex'))
library(jsonlite)
library(httr)
#library(psy)
#library(directlabels)
library(lubridate)
library(DescTools, include.only = c('UncertCoef', 'CramerV', 'CronbachAlpha'))
library(shiny)
library(shinyjs)
#library(markdown)


source('carnapServer.R')
source('carnapUI.R')


shinyApp(ui = carnapUI, server = carnapServer)