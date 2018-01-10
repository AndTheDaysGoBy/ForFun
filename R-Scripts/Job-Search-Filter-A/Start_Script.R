#USER PRESETS
QUERY <- NULL
MAXJOBS <- 900

#GLOBALS
FILTERS <- matrix(nrow = 0, ncol= 3)
colnames(FILTERS) <- c("class", "type", "condition")
DF <- NULL
TERMS <- array(list(c(),c()))
dimnames(TERMS) <- list(c('want', 'dont'))

source("Backend.R")
source("Filter_Window.R")
source("Keywords_Window.R")

main()
