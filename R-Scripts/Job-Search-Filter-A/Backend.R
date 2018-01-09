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
createQueryResult <- function(queryURL) {

}

######################################################################
#Job Data Construction Specific

#Create a dataframe of job data on a page.
createJobDF <- function(page) {
	return(jobDF)
}

######################################################################
#Page Processing Specific

#Extracts the job info. for all jobs on the page's html tree.
getJobs <- function(tree) {

}

#Extracts the dates corresponding to jobs on a page's html tree (excludes sponsored jobs).
getDates <- function(jobs, tree) {

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
