#DEFINITIONS
#QUERY is a user set value. It's the URL resulting from a search for a job.
#FILTERS is a matrix of 3 columns: 'type', 'class', 'condition'
#TERMS is a list of vectors: the first vector is 'want', the second is 'dont'
#JOBS is a dataframe of columns: 'id', 'title', 'company', 'city', 'state', 'zip', 'date', 'applied'
#APPLIED is a character vector. This exists since all applied jobs might not appear in a pull.
#Note, 'applied' in JOBS stores checkbox objects.
#Level of allowed interference: No globals, allow column names, knowledge of if NULL.
######################################################################
#Wrapper Specific#####################################################
#Main Window Element Specific

#Allowed global interference

#Pulls the results from a query and loads them into the display window.
pull <- function(display) {
	#Pull job data.
	JOBS <<- createQueryResult(QUERY, MAX)

	JOBS$applied <<- gtkCheckButtonNewWithLabel("Applied", show = TRUE) #depending on recycling
	
	#Compare against applied, and construct the applied column.
	JOBS[JOBS$id %in% APPLIED,]$applied <<- createCheckButton("Applied", active=T) #depending on recycling
	
	#Filter the job data.
	filtered <- useFilters(JOBS, FILTERS)
	
	#Renders the data.
	addAllContainer(renderAll(filtered, type='job', TERMS), display)
	display
}

#Saves the inclusion/exclusion settings (terms), the applied jobs, and the filters.
save <- function() {
	save(TERMS, APPLIED, FILTERS, "Job-Search-A-Settings.rda")
}

#Load the inclusion/exclusion settings (terms), the filters, and the applied to jobs.
load <- function() {
	load("Job-Search-A-Settings.rda", .GlobalEnv)
}

loadLibs <- function() {
	loaded <- require("RCurl") && require("XML") && require("plyr") && require("stringr") && require("RGtk2")
	if (loaded)
		print("Libraries Loaded.\n");
	else
		print("Libraries failed to load. Check to see the proper packages are installed.")
	loaded
}

main <- function() {
	#Initialize
	options(stringsAsFactors = FALSE)
	if (!loadLibs())
		stop("The program failed to start.")
	
	#Load the main window.
	openMainWindow()
}

######################################################################
#Core Dataframe Specific##############################################
######################################################################
#Query Data Construction Specific

#Creates a dataframe of all job data acquired from the URL.
createQueryResult <- function(queryURL, MAX=500) {
	url <- queryURL
	tree <- getTree(url)
	totalJobs <- xpathSApply(pagetree, "//div[@id='searchCount']", xmlValue)
	totalJobs <- as.numeric(regmatches(totalJobs,gregexpr("\\b([[:digit:]])[[:digit:]]\\b", totalJobs)))
	jobs <- data.frame(id=id, title=title, company=company, city=location$X1, state=c(), zip=c(), date=c())
	
	completed <- 0
	while ((completed < totalJobs) && (completed < MAX)) {
		tree <- getTree(url) #Either way, have to call getTree() 1+ times than necessary.
		pJobs <- getJobs(tree)
		jobs <- rbind(jobs, pJobs)
		
		completed <- completed + nrow(pJobs)
		url <- paste(starturl, "&start=", completed, sep="")
	}
	
	jobs
}

######################################################################
#Page Processing Specific

#Takes in a query and returns the tree form of the page.
getTree <- function(url) {
	page <- getURL(url, .opts = curlOptions(followlocation=T))
	page <- readLines(tc <- textConnection(page)); close(tc)
	tree <- htmlTreeParse(page, error=function(...){}, useInternalNodes = TRUE)	
}

#Extracts the job info. for all jobs on the page's html tree.
getJobs <- function(tree) {
	#This id get method doesn't necessary conform to jk=&fccid= form. I could use the data-jk field of the "organicJob" to construct it, but it's more computation.
	id <- xpathSApply(tree, "//div[@data-tn-component='organicJob']//a[@class='turnstileLink']/@href")
	title <- xpathSApply(tree, "//div[@data-tn-component='organicJob']//a[@class='turnstileLink']/@title")
	company <- trimws(xpathSApply(tree, "//div[@data-tn-component='organicJob']//span[@class='company']", xmlValue), which="both")
	
	location <- xpathSApply(tree, "//div[@data-tn-component='organicJob']//span[@class='location']", xmlValue)
	location <- gsub(' (?=\\d{5})',',', location, perl=T)
	location <- strsplit(location, ',')
	location <- rbind.fill(lapply(location, function(x) data.frame(t(x))))

	date <- xpathSApply(tree, "//div[@data-tn-component='organicJob']//span[@class='date']", xmlValue)
	date <- regmatches(date,gregexpr("\\b[[:digit:]]+.", date))
	date[grepl("+", date, fixed = T)] <- "31" #if 30+ days old, just mark as 31.
	date <- as.numeric(date)
	
	df <- data.frame(id=id, title=title, company=company, city=location$X1, state=location$X2, zip=location$X3, date=date)
}

#Attempts to extract all valuable text from a webpage (Thanks to R-blogger for the code).
getPageText <- function(url) {
	page <- getURL(url, followlocation = TRUE)
	page <- htmlParse(html, asText=TRUE)
	text <- xpathSApply(page, "//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)][not(ancestor::form)]", xmlValue)
}
				      
#Counts how many times each keyword occurs in text. Assume keywords prepared for regex search.
countKeywords <- function(text, keywords) {
	str_count(text, keywords)
}

######################################################################
Core Filter Specific##################################################

#Filter the dataframe using all filters in filter.
useFilters <- function(df, filters) {
	filteredDF <- df
	for (i in seq(filters)) {
		filteredDF <- useFilter(filteredDF, filters[i,])	
	}
}

#Filters dataframe using the filter.
useFilter <- function(df, filter) {
	class <- filter['class'] #Class names are made such that they're always the same name as df columns.
	df %>% filter(evalType(type)(evalClass(class)(class, filter['condition']))
}

#Determines how to compare based off of the class. Assumption: user filter bound on RHS.
evalClass <- function(class='title', input) {
	if (class=='company' || class=='title')
		`==`
	else if (class=='date')
		`>=` #Present implementation only works for "posted after X" (not "posted before X")
}
	       
#Manipulates the logical condition for the filter based off of the type.
evalType <- function(type='1') {
	if (type=='0')
		`!`
}

######################################################################
Core Render Specific##################################################
######################################################################
#Render Specific

#Takes dataframe and renders each row (different result between type='job' and type='filter').
renderAll <- function(df, type='filter', extra) {
	adply(df, 1, render, type, extra)
}

#Render an array properly depending on whether it's a filter or a job.
#The extra is the terms for renderJob(), and the box containing all the filters for renderFilter().
render <- function(arr, type='filter', extra) {
	border <- gtkFrame()
	bg <- gtkEventBox()
	
	if (type == 'job')
		inner <- renderJob(arr, extra)
	else
		inner <- renderFilter(arr, extra)
		
	bg$add(inner)
	bg$modifyBg('normal', 'white')
	border$add(bg)
	border
}

#Renders the part unique to a job.
renderJob <- function(job, terms) {
	inner <- gtkHBox(homogeneous=F, spacing=0)
	inner$packEnd(job[['applied']])
	inner$packEnd(gtkVSeparator())
	inner$packEnd(gtkLabel(paste(job[['city']], ", ", job[['state']], sep="")))
	inner$packEnd(gtkVSeparator())

	#Build job description
	info <- gtkVBox(homogeneous=T)
	info$add(gtkLabel(paste(job[['title']], job[['company']], sep=" ; ")))
	
	text <- getPageText(paste("https://www.indeed.com/", job[['id']], sep="")) #Assume only Indeed compatibility for now. Later use domain()
	want <- terms[['want']]
	dont <- terms[['dont']]
	shouldHave <- countKeywords(text, want)
	shouldntHave <- countKeywords(text, dont)
	
	green <- "<span foreground='green'>%s</span>"
	red <- "<span foreground='red'>%s</span>"
	foundGood <- paste("Found (Good):", paste(want[which(shouldHave > 0)], collapse="; "))
	foundGood <- sprintf(green, foundGood)
	notFoundGood <- paste("Not Found (Good):", paste(want[which(shouldHave <= 0)], collapse="; "))
	notFoundGood <- sprintf(green, notFoundGood)
	foundBad <- paste("Found (Bad):", paste(dont[which(shouldntHave > 0)], collapse="; "))
	foundBad <- sprintf(red, foundBad)
	notFoundBad <- paste("Not Found (Bad):", paste(dont[which(shouldntHave <= 0)], collapse="; "))
	notFoundBad <- sprintf(red, notFoundBad)
	
	info$add(gtkLabel(foundGood))
	info$add(gtkLabel(notFoundGood))
	info$add(gtkLabel(foundBad))
	info$add(gtkLabel(notFoundBad))
	inner$packEnd(info)
	inner
}

#Renders the part unique to a filter.
renderFilter <- function(filter, display) {
	inner <- gtkHBox(homogeneous=F, spacing=0)
  	remove <- gtkButtonNewFromStock("gtk-delete")
  	gSignalConnect(remove, "clicked", f=function(button) {
    		children <- filterDisplay$getChildren() #Necessary global? If pass in, will it point to the same?
    		match <- NULL
    		for (i in seq(children)) {
      			filter_render <- remove$getParent()$getParent()$getParent()
      			if (identical(children[[i]], child)) {
        			match <- i
				break
			}
		}
    	}
	globFilters <<- globFilters[-i,, drop=F] #Necessary global call? Useful due to function copy overhead.
	filterDisplay$remove(child)
	child$destroy()
  })
  filter$packEnd(remove, expand=F)
  
  filter$packEnd(gtkLabelNew(str=filter[['condition']]))
  filter$packEnd(gtkLabelNew(str=filter[['class']]))
  filter$packEnd(gtkLabelNew(str=filter[['type']]))
  filter
}

#Clears a GtkContainer.
clearContainer <- function(container) {
	for (child in container$getChildren())
		container$remove(child)
}

#Adds all the widgets to the container.
addAllContainer <- function(widgets, container) {
	for (widget in widgets)
		container$add(widget)
}
		      
createCheckButton <- function(label, active=F) {
	checkbox <- gtkCheckButtonNewWithLabel(label, show = TRUE)
	#Remove/Add from applied list. (Done for persistance between pulls)
	gSignalConnect(checkbox, "toggled", function(button) {
		for (i in seq(JOBS$applied))
			if (identical(JOBS$applied[[i]], button) {
				if (button['active'])
					APPLIED <- c(APPLIED, JOBS$id[[i]])
				else
					APPLIED <- APPLIED[which(APPLIED != JOBS$id[[i]])]
					
				break
			}
		}
	})
	checkbox['active'] <- active
}
		      
######################################################################
