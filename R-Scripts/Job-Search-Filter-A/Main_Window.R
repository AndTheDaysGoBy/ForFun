#USER PRESETS
QUERY <- NULL
MAXJOBS <- 900

#GLOBALS
FILTERS <- matrix(nrow = 0, ncol= 3)
colnames(FILTERS) <- c("class", "type", "condition")
DF <- NULL
TERMS <- array(list(c(),c()))
dimnames(TERMS) <- list(c('want', 'dont'))

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

#Menubar
mFile <- gtkMenuItemNewWithLabel("File", show = T)
mConstraints <- gtkMenuItemNewWithLabel("Constraints", show=T)
menu$add(mfile)
menu$add(mconstraints)

#File submenu
subFile <- gtkMenu()
mFile$setSubmenu(subFile)

#File submenu:pull item
mPull <- gtkMenuItemNewWithLabel("Pull", show = T)
gSignalConnect(mPull, "activate", f=function(a, data) {
	pull(NULL)
})
subFile$append(mPull)

#File submenu:save item
mSave <- gtkMenuItemNewWithLabel("Save", show=T)
gSignalConnect(mSave, "active", f=function(a, data) {
	save()
})
subFile$append(mSave)

#File submenu:load item
mLoad <- gtkMenuItemNewWithLabel("Load", show=T)
gSignalConnect(mLoad, "active", f=function(a, data) {
  load()
})
subFile$append(mLoad)

#Constraints submenu
subConstraints <- gtkMenu()
mConstraints$setSubmenu(subConstraints)

#Constraints submenu:keyword item
mKeywords <- gtkMenuItemNewWithLabel("Keywords", show=T)
gSignalConnect(mKeywords, "activate", f=function(a, data) {
	openKeywordWindow()
})
subConstraints$append(mKeywords)

mFilters <- gtkMenuItemNewWithLabel("Filter(s)", show=T)
gSignalConnect(mFilters, "activate", f=function(a, data) {
	openFilterWindow()
})
subConstraints$append(mFilters)

#Core
jobList <- gtkFrame("Job List")
jobPage <- gtkFrame("Job Page")
core$packStart(jobList, fill=T)
core$packStart(jobPage, fill=T)

#jobList
scrollJobPane <- gtkScrolledWindow()
scrollJobPane$setPolicy("never", "automatic")
jobList$add(scrollJobPane)

#scrollJobPane
renderedJobs <- gtkVBox(homogeneous=T, spacing=5)
scrolled$addWithViewport(renderedJobs)

#jobPage
notebook <- gtkNotebook()
notebook$appendPage(gtkLabel("Page 1"), gtkLabel("Tab 1"))
notebook$appendPage(gtkLabel("Page 2"), gtkLabel("Tab 2"))
jobPage$add(notebook)

#Display
mainWindow$show()
