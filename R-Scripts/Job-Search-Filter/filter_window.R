openFilterWindow <- function() {
  filtersWin <- gtkWindow(show=F) #accepts only one child
  filtersWin$setTitle("Filters")
  gSignalConnect(filtersWin, "delete-event", function(event,...) {
    dispDF <- filter(globDF, globFilters)
    renderJobs(dispDF, globTerms)
    #filtersWin$destroy()
  })
  all <- gtkVBox(homogeneous=F)
  filtersWin$add(all)
  
  #Overall filter input + display
  input <- gtkHBox()
  filters <- gtkFrame("Filters")
  all$packStart(input, expand=F, fill=F)
  all$add(filters)
  
  #Add a new filter
  filterType <- gtkVBox()
  filterClass <- gtkComboBoxNewText()
  filterCondition <- gtkEntry()
  filterSubmit <- gtkButtonNewWithLabel("Add Filter")
  input$add(filterType)
  input$add(filterClass)
  input$add(filterCondition)
  input$add(filterSubmit)
  
  #Filter type
  labels <- c("MUST", "CANNOT")
  radio <- list()
  radio[[labels[1]]] <- gtkRadioButton(label=labels[1])
  radio[[labels[2]]] <- gtkRadioButton(radio, label=labels[2])
  sapply(radio, gtkBoxPackStart, object=filterType)
  
  #Filter class
  sapply(c("Job Title", "Company Name", "Age of Posting"), filterClass$appendText)
  
  
  #Filters display
  scrolled <- gtkScrolledWindow()
  scrolled$setPolicy("never", "automatic")
  filters$add(scrolled)
  
  filtersDisplay <- gtkVBox(homogeneous=T, spacing=5)
  scrolled$addWithViewport(filtersDisplay)
  
  if (nrow(globFilters) > 0)
    apply(globFilters, 1, renderFilterApply, filtersDisplay)
  
  #Filter submit
  gSignalConnect(filterSubmit, "clicked", f=function(button) {
    if (filterClass['active'] == -1)
      return(NULL)
    
    for (child in filtersDisplay$getChildren()) {
      filtersDisplay$remove(child)
    }
  
    actives <- sapply(radio, '[', "active")
    active <- names(actives)[which(actives==T)]
    cat(filterClass$getActiveText())
    filterDisp <- c(filterClass$getActiveText(), active, filterCondition$getText())

    globFilters <<- rbind(globFilters, filterDisp)
    
    apply(globFilters, 1, renderFilterApply, filtersDisplay)
  })
  
  filtersWin$show()
}
