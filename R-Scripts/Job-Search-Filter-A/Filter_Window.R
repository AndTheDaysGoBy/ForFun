openFilterWindow <- function() {
	#Top-level design
	filterWindow <- gtkWindow(show=F)
	filterWindow$setTitle("Filters")

	#Window design
	all <- gtkVBox(homogeneous=F)
	filterWindow$add(all)

	#Filter input and display
	input <- gtkHBox()
	filterList <- gtkFrame("Filters")
	all$packStart(input, expand=F, fill=F)
	all$add(filterList)

	#Filter input
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
	sapply(c("title", "company", "date", "state", "city"), filterClass$appendText)


	#Filter display
	scrollFilterPane <- gtkScrolledWindow()
	scrollFilterPane$setPolicy("never", "automatic")
	filterList$add(scrollFilterPane)

	renderedFilters <- gtkVBox(homogeneous=T, spacing=5)
	scrollFilterPane$addWithViewport(renderedFilters)

	if (nrow(FILTERS) > 0)
		renderAll(FILTERS, type='filter', renderedFilters)

	#Filter submit
	gSignalConnect(filterSubmit, "clicked", f=function(button) {
		if (filterClass['active'] == -1)
			return(NULL)

		clearContainer(renderedFilters)

		actives <- sapply(radio, '[', "active")
		active <- names(actives)[which(actives==T)]

		filterData <- t(matrix(c( active, filterClass$getActiveText(), filterCondition$getText())))
		colnames(filterData) <- c("type", "class", "condition")
		FILTERS <<- rbind(FILTERS, filterData)

		addAllContainer(renderAll(FILTERS, type='filter', renderedFilters), renderedFilters)
	})

	if (nrow(FILTERS) > 0) {
		prerender <- renderAll(FILTERS, type='filter', extra=renderedFilters)
		renderedFilters <- addAllContainer(prerender, renderedFilters)
	}
	
	filterWindow$show()
}
