#Parse inclusion/exclusion words
getKeywords <- function(textfield) {
  keywords <- unlist(strsplit(textfield, "\n"))
  keywords <- trimws(keywords, which="both")
  keywords <- keywords[keywords != ""]
  if (length(keywords) == 0)
    return(NULL)
  else
    return(keywords)
}

#extract data between quotes.
extract <- function(text) {
	text <- unlist(strsplit(text, ""))
	textpos <- which("'"==text)

	y <- vector(mode="character", length=(length(textpos)/2))
	for (i in seq(from=1,length(textpos),by=2)) {
		y[(i + 1)/2] <- paste(text[(textpos[i] + 1):(textpos[i+1] - 1)], collapse="")
	}
	return(y)
}


#Takes in the query URL & obtains the job DF for all results.
#Depends on global var. maxJobs
getQueryResult <- function(starturl) {
	firstPage <- getPage(starturl)
	numjobs <- firstPage[grep('<div id="searchCount"', firstPage) + 1] #in future, use HTML parser
	numjobs <- as.numeric(regmatches(numjobs,gregexpr("\\b([[:digit:]])[[:digit:]]\\b", numjobs)))
	numinfo <- 18 #how much info. to store per job (liable to change)
	jobs <- data.frame(matrix(NA, nrow=numjobs, ncol=numinfo), stringsAsFactors=FALSE)
	rownames(jobs) <- NULL

	completed <- 0
	url <- starturl
	while ((completed < numjobs) && (completed < maxJobs)) {
		#get a page
	  cat("HERE")
		page <- getPage(url)
		partDF <- createPageDF(page)
		numr <- nrow(partDF)
		jobs[(completed+1):(completed+numr),] <- partDF
		colnames(jobs) <- colnames(partDF) #could make so only called once later

		#add to completed.
		completed <- completed + numr
		url <- paste(starturl, "&start=", completed, sep="")
	}
	
	return(jobs)
}

#Converts a query url to a downloaded page to be processed.
getPage <- function(queryurl) {
	download.file(queryurl, destfile = 'quote.html', method="libcurl",
	              extra='-L') #in future, convert into memory
	page <- readLines('quote.html')
}

#Converts one query page into a dataframe.
createPageDF <- function(page) {

	#create datatframe of extracted data.
	jobs <- page[grep('^jobmap\\[[[:digit:]]\\]', page)]
	df <- t(as.data.frame(lapply(jobs, extract), stringsAsFactors=FALSE))
	rownames(df) <- NULL
	colnames(df) <- c("jk", "efccid", "srcid", "cmpid", "num", "srcname", "cmp", "cmpesc", "cmplnk", "locl", "country", "zip", "city", "title", "locid", "rd")

	states <- sapply(strsplit(df[,'locl'], ", "), "[[", 2)
	df <- cbind(df, state=sapply(strsplit(states, " "), "[[", 1))

	#had issue of sponsored jobs having dates, thus dates column != rest, fixed via this
	locs <- grep('pj_',page)
	page <- page[-(1:(locs[length(locs)]+30))]
	dates <- page[grep('class="date"', page)]
	s <- gsub('^.*<span [^>]*>([^<]*)</span>.*$', '\\1', dates)
	dates <- regmatches(s,gregexpr("\\b[[:digit:]]+.", s))
	dates[grepl("+", dates, fixed = T)] <- "31"
	df <- cbind(df, date=unlist(dates))
	
	return(df)
}

#checks a page to see how often each term in the keyword list appears.
#attempts to convert string to regex compliant (escaping certain characters)
#Could be made for situations such as other job titles on page (false positives)
keywordCheck <- function(terms, page) {
	#matches <- grep(paste(toMatch,collapse="|"), page, value=TRUE))

	#substitute special chars for regex equivalent (needed for grep)
	for (i in seq(terms)) {
		term <- unlist(strsplit(terms[i], ""))
		for (j in seq(term)) {
			if (term[j] %in% c("+", "^","$",".","?","(",")")) {
				term[j] <- paste("\\",term[j], sep="")
			}
		}
		terms[i] <- paste(term, collapse="")
	}
	
	#count occurrences of each term
	result <- vector(mode="numeric", length=length(terms))
	for (i in seq(terms)) {
		result[i] <- length(grep(terms[i], page))
	}
	return(result)
}

#assume the df is a queryResult.
finalizeDF <- function(df) {
	joblinks <- paste("https://www.indeed.com","/rc/clk?jk=",df[,'jk'], "&fccid=", df[,'cmpid'], sep="")
	df <- cbind(id=joblinks, subset(df, select=c("title","cmp", "city", "state", "zip","date")))
}

#top-level method to fill out the gui from the df.
#Dependent on the global var. globApplied, globTerms, globDF
pull <- function(query) {

	if (is.null(query))
		return(NULL)

	#get query results
	globDF <<- getQueryResult(query)
	globDF <<- finalizeDF(globDF)

	#Determine what is applied to already
	joblinks <- globDF[,"id"]
	dfApplied <- vector(mode="logical", length=length(joblinks))
	#compare elements in df to those in list of applied to.
	for (i in seq(joblinks)) {		
		dfApplied[i] <- (joblinks[i] %in% globApplied)
	}

	globDF["applied"] <<- dfApplied
	
	#filter according to filters
	dispDF <- filter(globDF, globFilters)

	renderJobs(dispDF, globTerms)
	
}

#returns list of rendered jobs. References the window's 'jobs' element.
renderJobs <- function(df, terms) {
  if (length(df[,1]) == 0)
    return(NULL)
  
  for (child in jobs$getChildren()) {
    jobs$remove(child)
  }

  for (i in 1:nrow(df)) {
    jobs$packStart(renderJob(df[i,], terms))
  }
}

renderJob <- function(x, terms) {
	bg <- gtkEventBox()
	#Build job
	job <- gtkHBox(homogeneous=F, spacing=0)
	checkbox <- gtkCheckButtonNewWithLabel("Applied", show = TRUE)
	gSignalConnect(checkbox, "toggled", function(button) {
	})
	checkbox$active <- x[['applied']]
	job$packEnd(checkbox)
	job$packEnd(gtkVSeparator())
	job$packEnd(gtkLabel(paste(x[["city"]], ", ", x[["state"]], sep="")))
	job$packEnd(gtkVSeparator())

	#Build job description
	info <- gtkVBox(homogeneous=T)
	print(x)
	print(length(x))
	page <- getPage(x[['id']])
	want <- terms[['want']]
	dont <- terms[['dont']]
	shouldHave <- keywordCheck(want, page)
	shouldntHave <- keywordCheck(dont, page)
	info$add(gtkLabel(paste(x[["title"]], x[["cmp"]], sep=" ; ")))
	info$add(gtkLabel(paste("Found (Good):", paste(want[which(shouldHave > 0)], collapse="; "))))
	info$add(gtkLabel(paste("Not Found (Good):", paste(want[which(shouldHave <= 0)], collapse="; "))))
	info$add(gtkLabel(paste("Found (Bad):", paste(dont[which(shouldntHave > 0)], collapse="; "))))
	info$add(gtkLabel(paste("Not Found (Bad):", paste(dont[which(shouldntHave <= 0)], collapse="; "))))
	job$packEnd(info)

	#Add styling to job
	bg$add(job) #needed for drawing bg
	bg$modifyBg("normal",'white')
	border <- gtkFrame()
	border$add(bg)
	
	return(border)
}


renderFilterApply <- function(filter, display) {
  item <- renderFilter(filter)
  display$add(item)
}

#Takes in the filter parameters via a list.
renderFilter <- function(filter) {
  border <- gtkFrame()
  bg <- gtkEventBox()
  #Build job
  filterDisplay <- gtkHBox(homogeneous=F, spacing=0)
  remove <- gtkButtonNewFromStock("gtk-delete")
  gSignalConnect(remove, "clicked", f=function(button) {

    children <- filtersDisplay$getChildren()
    match <- NULL
    for (i in seq(children)) {
      child <- remove$getParent()$getParent()$getParent()

      if (identical(children[[i]], child))
        match <- i
    }
	  
    globFilters <<- globFilters[-i,, drop=F]
    filtersDisplay$remove(child)
    child$destroy
  })
  filterDisplay$packEnd(remove, expand=F)
  
  condition <- gtkLabelNew(str=filter[['condition']])
  filterDisplay$packEnd(condition)
  
  class <- gtkLabelNew(str=filter[['class']])
  filterDisplay$packEnd(class)
  
  type <- gtkLabelNew(str=filter[['type']])
  filterDisplay$packEnd(type)
  
  
  #Add styling to job
  bg$add(filterDisplay) #needed for drawing bg
  bg$modifyBg("normal",'white')
  border$add(bg)
  
  return(border)
}


filter <- function(df, filters) {
  if (is.null(filters) || nrow(filters) == 0)
    return(df)
  
  dfDisp <- df
  for (i in seq(filters[,1])) {
    row <- filters[i,]
    class <- row['class']
    if (class == 'Company Name') {
      interest <- grepl(row['condition'], dfDisp[,'cmp'], fixed = T)
      if (row['type'] == 'MUST')
        dfDisp <- dfDisp[interest,,drop=F]
      else
        dfDisp <- dfDisp[-interest,,drop=F]
    }
    else if (class == 'Job Title') {
      interest <- grepl(row['condition'], dfDisp[,'title'], fixed = T)
      if (row['type'] == 'MUST')
        dfDisp <- dfDisp[interest,,drop=F]
      else
        dfDisp <- dfDisp[-interest,,drop=F]
    }
    else if (class == 'date') {
      date <- as.numric(row['date'])
      if (row['condition'] == 'OLDER')
        dfDisp <- dfDisp[dfDisp['date'] < date,,drop=F]
      else if (row['condition'] == 'NEWER')
        dfDisp <- dfDisp[dfDisp['date'] > date,,drop=F]
      else if (row['condition'] == 'ON')
        dfDisp <- dfDisp[dfDisp['date'] == date,,drop=F]
      
    }
  }
  
  return(dfDisp)
}
