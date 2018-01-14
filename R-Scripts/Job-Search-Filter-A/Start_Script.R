#USER PRESETS
QUERY <- NULL
MAXJOBS <- 900

#GLOBALS
FILTERS <- as.data.frame(matrix(nrow = 0, ncol= 3))
colnames(FILTERS) <- c("type", "class", "condition")
JOBS <- NULL
TERMS <- array(list(c(),c()))
APPLIED <- list()
dimnames(TERMS) <- list(c('want', 'dont'))

source("Backend.R")
source("Filter_Window.R")
source("Keywords_Window.R")
source("Main_Window.R")

main()
