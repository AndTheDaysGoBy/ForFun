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

#Extracts the job info. for all jobs on the page.
getJobs <- function(page) {

}

#Extracts the dates corresponding to jobs on a page (excludes sponsored jobs).
getDates <- function(jobs, page) {

}

#Counts how many times each keyword occurs on the page.
countKeywords <- function(keywords, page) {
	#Apply
}

#Counts how many times a tunes a keyword occurs on the page.
countKeyword <- function(keyword, page) {

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
renderAll <- function(df, type='job') {
	#Apply
	return(rendered_objs)
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
