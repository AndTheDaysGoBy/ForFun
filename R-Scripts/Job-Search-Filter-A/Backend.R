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
	#Back up new applied jobs, and correct any changed applied jobs.
	if (!is.null(JOBS) && nrow(JOBS) > 0) {
		activeList <- unlist(llply(JOBS$applied, "[[", 'active'))
		
		#Change (note, since finite, injective=surjective)
		changes <- activeList[which(JOBS$id %in% APPLIED)]
		if (length(changes) > 0) {
			APPLIED[which(APPLIED %in% JOBS$id)] <<- changes
		}
		
		#New
		activeJobIds <- JOBS$id[activeList]
		newApplieds <- activeJobIds[!(activeJobIds %in% APPLIED)]
		if (length(newApplieds) > 0)
			APPLIED <<- append(APPLIED, newApplieds)
	}
	
	#Pull job data.
	JOBS <<- createQueryResult(QUERY, MAXJOBS)

	JOBS$applied <<- replicate(length(JOBS$id), gtkCheckButtonNewWithLabel("Applied", show = TRUE))
	
	#Compare against applied, and construct the applied column.
	tmp <- JOBS$id %in% APPLIED
	JOBS[tmp,]$applied <<- replicate(sum(tmp), createCheckButton("Applied", active=T))
	
	#Filter the job data.
	filtered <- useFilters(JOBS, FILTERS)
	
	rendered <- renderAll(filtered, type='job', TERMS)
	#Renders the data.
	display <- clearContainer(display)
	display <- addAllContainer(rendered, display)
}

#Saves the inclusion/exclusion settings (terms), the applied jobs, and the filters.
save <- function() {
	#Save separately for the sake of customizability
	saveRDS(TERMS, "Job-Search-A-TERMS.rds")
	saveRDS(APPLIED, "Job-Search-A-APPLIED.rds")
	saveRDS(FILTERS, "Job-Search-A-FILTERS.rds")
}

#Load the inclusion/exclusion settings (terms), the filters, and the applied to jobs.
load <- function() {
	tryCatch({
			TERMS <<- readRDS("Job-Search-A-TERMS.rds")
			APPLIED <<- readRDS("Job-Search-A-APPLIED.rds")
			FILTERS <<- readRDS("Job-Search-A-FILTERS.rds")
	},
	error=function(cond) {
			print("One of the files failed to load. Make sure all three are in your working directory.")
	})
		
}

loadLibs <- function() {
	
	if (!require("RCurl"))
		install.packages("RCurl")
	if (!require("XML"))
		install.packages("XML")
	if (!require("plyr"))
		install.packages("plyr")
	if (!require("stringr"))
		install.packages("stringr")
	if (!require("RGtk2"))
		install.packages("RGtk2")
	
	loaded <- all(c("RCurl", "XML", "plyr", "stringr", "RGtk2") %in% installed.packages())
	if (loaded)
		print("Libraries Loaded.")
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
	totalJobs <- xpathSApply(tree, "//div[@id='searchCount']", xmlValue)
	totalJobs <- as.numeric(gsub("(.*of | jobs|,)", "", totalJobs))
	jobs <- data.frame(id=c(), title=c(), company=c(), city=c(), state=c(), zip=c(), date=c())
	
	completed <- 0
	while ((completed < totalJobs) && (completed < MAX)) {
		tree <- getTree(url) #Either way, have to call getTree() 1+ times than necessary.
		pJobs <- getJobs(tree)
		jobs <- rbind(jobs, pJobs)
		
		completed <- completed + nrow(pJobs)
		#if (completed > 450)
		#	browser()
		url <- paste(queryURL, "&start=", completed, sep="")
		print(url)
	}
	
	jobs
}

######################################################################
#Page Processing Specific

#Takes in a query and returns the tree form of the page.
getTree <- function(url) {
	page <- getURL(url, .opts = curlOptions(followlocation=T, timeout=1))
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
	location <- parseLocations(location)
	
	date <- xpathSApply(tree, "//div[@data-tn-component='organicJob']//span[@class='date']", xmlValue)
	date <- regmatches(date,gregexpr("\\b[[:digit:]]+.", date))
	date[grepl("+", date, fixed = T)] <- "31" #if 30+ days old, just mark as 31.
	date <- as.numeric(date)
	
	df <- data.frame(id=id, title=title, company=company, city=location$city, state=location$state, zip=location$zip, date=date)
}

#Attempts to extract all valuable text from a webpage (Thanks to R-blogger for the code).
getPageText <- function(url) {
	text <- tryCatch({
		page <- getURL(url, .opts = curlOptions(followlocation=T, ssl.verifypeer=F, timeout=2))
		page <- getURL(url, .opts = curlOptions(followlocation=T, ssl.verifypeer=F, timeout=2))
		page <- htmlParse(page, asText=TRUE)
		xpathSApply(page, "//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)][not(ancestor::form)]", xmlValue)
	},
	error=function(cond) {
		" "
	})
	return(text)
}

#Get's the city, state, zip for each location found.
parseLocations <- function(locations) {
	#Handle city, state <zip>
	locations <- gsub(' (?=\\d{5})',', ', locations, perl=T)
	locationDF <- as.data.frame(matrix(data=NA, nrow=length(locations), ncol=3))
	colnames(locationDF) <- c("city", "state", "zip")
	splitLocations <- strsplit(locations[grepl(",", locations)], ", ");
	locationDF[grepl(",", locations),] <- t(sapply(splitLocations, '[', seq(max(sapply(splitLocations,length)))))
	
	#Handle state
	states <- locations %in% state.name
	ifelse(states, locationDF[states, "state"] <- getAbbrv(locations[states]), NA)
	
	#Handle city
	cities <- !(grepl(",", locations) | states | (locations == "United States"))
	ifelse(cities, locationDF[cities, "city"] <- locations[cities], NA)
	
	#Handle Remote/Country by leaving as NA.
	locationDF
}

#Get abbreviation of state names.
getAbbrv <- function(state) {
	state.abb[grep(state, state.name)]
}

#Parse inclusion/exclusion words
getKeywords <- function(textfield) {
	keywords <- unlist(strsplit(textfield, "\n"))
	keywords <- gsub("\\[|\\\\|\\^|\\$|\\.|\\||\\?|\\*|\\+|\\(|\\)|\\{|\\}", " ", keywords)
	keywords <- trimws(keywords, which="both")
	keywords <- keywords[keywords != ""]
	if (length(keywords) == 0)
		return(NULL)
	else
		return(keywords)
}

#Counts how many times each keyword occurs in text. Assume keywords prepared for regex search.
countKeywords <- function(text, keywords) {
	if (is.null(keywords))
		return(NULL)
	sum(str_count(text, keywords))
}

######################################################################
#Core Filter Specific##################################################

#Filter the dataframe using all filters in filter.
useFilters <- function(df, filters) {
	filteredDF <- df
	if (!is.null(df) && nrow(filters) > 0) {
		for (i in seq(nrow(filters)))
			filteredDF <- useFilter(filteredDF, filters[i,])	
	}
	filteredDF
}

#Filters dataframe using the filter.
useFilter <- function(df, filter) {
	fclass <- filter[['class']] #Class names are made such that they're always the same name as df columns.
	condition <- evalType(filter[['type']])(evalClass(fclass)(df[[fclass]], filter[['condition']]))
	df <- as.data.frame(df[condition,], col.names=c("type","class","condition"))
}

#Determines how to compare based off of the class. Assumption: user filter bound on RHS.
evalClass <- function(class='title') {
	if (class=='company' || class=='title' || class=='state' || class=='city')
		`==`
	else if (class=='date')
		`>=` #Present implementation only works for "posted after X" (not "posted before X")
}
	       
#Manipulates the logical condition for the filter based off of the type.
evalType <- function(type='MUST') {
	if (type=='CANNOT')
		`!`
	else
		`%i%`
}

#Identity operator
`%i%` <- function(x) { x }

######################################################################
#Core Render Specific##################################################
######################################################################
#Render Specific

#Takes dataframe and renders each row (different result between type='job' and type='filter').
renderAll <- function(df, type='filter', extra) {
	rownames(df) <- NULL
	if (type=='job') {
		for (i in seq(nrow(df))) {
			parent <- df$applied[[i]]$getParent()
			if (!is.null(parent))
				clearContainer(parent)
		}
	}
	alply(df, 1, render, type, extra)
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
	inner$packEnd(job[['applied']][[1]]) #For some reason, need [[1]]
	inner$packEnd(gtkVSeparator())
	inner$packEnd(gtkLabel(paste(job[['city']], ", ", job[['state']], sep="")))
	inner$packEnd(gtkVSeparator())

	#Build job description
	info <- gtkVBox(homogeneous=T)
	info$add(gtkLabel(paste(job[['title']], job[['company']], sep=" ; ")))
	
	text <- getPageText(paste("https://www.indeed.com", job[['id']], sep="")) #Assume only Indeed compatibility for now. Later use domain()
	want <- terms[['want']]
	dont <- terms[['dont']]
	shouldHave <- countKeywords(text, want)
	shouldntHave <- countKeywords(text, dont)
	
	green <- "<span foreground='green'>%s</span>"
	red <- "<span foreground='red'>%s</span>"
	foundGood <- paste("Found (Good):", paste(want[which(shouldHave > 0)], collapse="; "))
	foundGood <- sprintf(green, foundGood)
	foundBad <- paste("Found (Bad):", paste(dont[which(shouldntHave > 0)], collapse="; "))
	foundBad <- sprintf(red, foundBad)
	
	fGood <- gtkLabel()
	fGood$setMarkup(foundGood)
	fBad <- gtkLabel()
	fBad$setMarkup(foundBad)
	
	info$add(fGood)
	info$add(fBad)
	inner$packEnd(info)
	inner
}

#Renders the part unique to a filter.
renderFilter <- function(filter, display) {
	inner <- gtkHBox(homogeneous=F, spacing=0)
  remove <- gtkButtonNewFromStock("gtk-delete")
  gSignalConnect(remove, "clicked", f=function(button) {
    	children <- display$getChildren()
    	match <- NULL
    	for (i in seq(children)) {
      		filter_render <- remove$getParent()$getParent()$getParent()
      		if (identical(children[[i]], filter_render)) {
       			match <- i
						break
       		}
			}
			FILTERS <<- FILTERS[-i,, drop=F] #Necessary global call? Useful due to function copy overhead.				display$remove(child)
			filter_render$destroy() #Not sure if need (since child no longer referenced -> destroyed).
	})
  inner$packEnd(remove, expand=F)
  inner$packEnd(gtkVSeparator())
  inner$packEnd(gtkLabelNew(str=filter[['condition']]))
  inner$packEnd(gtkVSeparator())
  inner$packEnd(gtkLabelNew(str=filter[['class']]))
  inner$packEnd(gtkVSeparator())
  inner$packEnd(gtkLabelNew(str=filter[['type']]))
  inner
}

#Clears a GtkContainer.
clearContainer <- function(container) {
	for (child in container$getChildren())
		container$remove(child)
	container
}

#Adds all the widgets to the container.
addAllContainer <- function(widgets, container, expand=T, fill=F) {
	for (widget in widgets)
		container$packStart(widget, expand=expand, fill=fill)
	container
}
		      
createCheckButton <- function(label, active=F) {
	checkbox <- gtkCheckButtonNewWithLabel(label, show = TRUE)
	#Remove/Add from applied list. (Done for persistance between pulls)
	gSignalConnect(checkbox, "toggled", function(button) {
		for (i in seq(JOBS$applied)) {
			if (identical(JOBS$applied[[i]], button)) {
				if (button['active'])
					APPLIED <- c(APPLIED, JOBS$id[[i]])
				else
					APPLIED <- APPLIED[which(APPLIED != JOBS$id[[i]])]
					
				break
			}
		}
	})
	checkbox['active'] <- active
	checkbox
}
		      
######################################################################
