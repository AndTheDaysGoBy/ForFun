openMainWindow <- function() {
	
	#Top-Level design
	mainWindow <- gtkWindow(show=F)
	mainWindow$setTitle("Job Search Filter")
	mainWindow$setDefaultSize(600,400)

	#Window layout
	all <- gtkVBox()
	mainWindow$add(all)

	#Window design
	menu <- gtkMenuBar()
	core <- gtkHBox(homogeneous=T, spacing=10)
	all$packStart(menu, expand=F, fill=F)
	all$packStart(core)

	#Core
	jobList <- gtkFrame("Job List")
	jobPage <- gtkFrame("Job Page")
	core$packStart(jobList, fill=T)
	#core$packStart(jobPage, fill=T)

	#jobList
	scrollJobPane <- gtkScrolledWindow()
	scrollJobPane$setPolicy("never", "automatic")
	jobList$add(scrollJobPane)

	#scrollJobPane
	renderedJobs <- gtkVBox(homogeneous=T, spacing=5)
	scrollJobPane$addWithViewport(renderedJobs)

	#jobPage
	notebook <- gtkNotebook()
	notebook$appendPage(gtkLabel("Page 1"), gtkLabel("Tab 1"))
	notebook$appendPage(gtkLabel("Page 2"), gtkLabel("Tab 2"))
	jobPage$add(notebook)

	#Menubar
	mFile <- gtkMenuItemNewWithLabel("File", show = T)
	mConstraints <- gtkMenuItemNewWithLabel("Constraints", show=T)
	mRefresh <- gtkMenuItemNewWithMnemonic("_Refresh", show=T)
	gSignalConnect(mRefresh, "activate", f=function(a, data) {
		filteredDF <- useFilters(JOBS, FILTERS)
		rerendered <- renderAll(filteredDF, type='job', extra=TERMS)
		clearContainer(renderedJobs)
		renderedJobs <- addAllContainer(rerendered, renderedJobs)
	})
	menu$add(mFile)
	menu$add(mConstraints)
	menu$add(mRefresh)

	#File submenu
	subFile <- gtkMenu()
	mFile$setSubmenu(subFile)

	#File submenu:pull item
	mPull <- gtkMenuItemNewWithLabel("Pull", show = T)
	gSignalConnect(mPull, "activate", f=function(a, data) {
		renderedJobs <- pull(renderedJobs)
	})
	subFile$append(mPull)

	#File submenu:save item
	mSave <- gtkMenuItemNewWithLabel("Save", show=T)
	gSignalConnect(mSave, "activate", f=function(a, data) {
		save()
	})
	subFile$append(mSave)

	#File submenu:load item
	mLoad <- gtkMenuItemNewWithLabel("Load", show=T)
	gSignalConnect(mLoad, "activate", f=function(a, data) {
		load()
	})
	subFile$append(mLoad)

	#Constraints submenu
	subConstraints <- gtkMenu()
	mConstraints$setSubmenu(subConstraints)

	#Constraints submenu:keyword item
	mKeywords <- gtkMenuItemNewWithLabel("Keywords", show=T)
	gSignalConnect(mKeywords, "activate", f=function(a, data) {
		openKeywordsWindow()
	})
	subConstraints$append(mKeywords)

	mFilters <- gtkMenuItemNewWithLabel("Filter(s)", show=T)
	gSignalConnect(mFilters, "activate", f=function(a, data) {
		openFilterWindow()
	})
	subConstraints$append(mFilters)
	
	#Display
	mainWindow$show()
}
