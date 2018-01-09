#DEFINITIONS
#FILTERS is a matrix of 3 columns: 'type', 'class', 'condition'
#TERMS is a list of vectors: the first vector is 'want', the second is 'dont'
#JOBS is a dataframe of columns: 'id', 'title', 'company', 'city', 'state', 'zip', 'date', 'applied'
#Note, 'applied' in JOBS stores checkbox objects.
#Level of allowed interference: No globals, allow column names, knowledge of if NULL.
######################################################################
#Wrapper Specific#####################################################
#Main Window Element Specific

#Allowed global interference

#Pulls the results from a query and loads them into the display window.
pull <- function() {

}

#Saves the inclusion/exclusion settings (terms), the filters, and the applied to jobs.
save <- function() {

}

#Load the inclusion/exclusion settings (terms), the filters, and the applied to jobs.
load <- function() {

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

#Counts how many times each keyword occurs on the page's HTML tree (mainly text).
countKeywords <- function(keywords, tree) {
	#Apply
}

#Counts how many times a tunes a keyword occurs on the page (mainly text).
countKeyword <- function(keyword, tree) {

}

######################################################################
Core Filter Specific##################################################

#Filter the dataframe using all filters in filter.
useFilters <- function(df, filters) {
	
}

#Filters dataframe using the filter.
useFilter <- function(df, filter) {

}

######################################################################
Core Render Specific##################################################
######################################################################
#Render Specific

#Takes dataframe and renders each row (different result between type='job' and type='filter').
renderAll <- function(df, type='filter') {
	adply(df, 1, render, type)
}

#Render an array properly depending on whether it's a filter or a job.
render <- function(arr, type='filter') {
	border <- gtkFrame()
	bg <- gtkEventBox()
	
	if (type == 'job')
		inner <- innerrenderJob(arr)
	else
		inner <- renderFilter(arr)
		
	bg$add(inner)
	bg$modifyBg('normal', 'white')
	border$add(bg)
	border
}

#Renders the part unique to a job.
renderJob <- function(job) {
	return(job_rendition)
}

#Renders the part unique to a filter.
renderFilter <- function(filter) {
	return(filter_rendition)
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

######################################################################
