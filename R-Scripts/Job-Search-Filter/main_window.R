library("RGtk2")
library("gWidgets")
options(stringsAsFactors = FALSE)

#globals
globFilters <- matrix(nrow = 0, ncol=3)
colnames(globFilters) <- c("class", "type", "condition")
globApplied <- list()
globQuery <- NULL #user defined (use Indeed job search URL)
globDF <- NULL
globTerms <- array(list(c(),c()))

#assign via globTerms['want'] <- list(NULL) to empty a part.
dimnames(globTerms) <- list(c('want', 'dont'))
maxJobs <- 900

#Top-Level design
window <- gtkWindow(show=F) #accepts only one child
window$setTitle("Job Search Filter")
window$setDefaultSize(600,400)
all <- gtkVBox()
menu <- gtkMenuBar()
core <- gtkHBox(homogeneous=T, spacing=10) #pixel distance
all$packStart(menu, expand=F, fill=F)
all$packStart(core)

window$add(all)

#menu
mfile <- gtkMenuItemNewWithLabel("File", show = T)
mconstraints <- gtkMenuItemNewWithLabel("Constraints", show=T)
menu$add(mfile)
menu$add(mconstraints)

#file submenu
subfile <- gtkMenu()
mpull <- gtkMenuItemNewWithLabel("Pull", show = T)
gSignalConnect(mpull, "activate", f=function(a, data) {
	pull(globQuery)
})
subfile$append(mpull)
msave <- gtkMenuItemNewWithLabel("Save", show=T)
gSignalConnect(msave, "active", f=function(a, data) {
  if (!is.null(globDF))
    write.csv(globDF[globDF['applied']==T,'id'], "applied.csv")
})
subfile$append(msave)
mload <- gtkMenuItemNewWithLabel("Load", show=T)
gSignalConnect(mload, "active", f=function(a, data) {
  globApplied <- readLines("applied.csv")
})
subfile$append(mload)
mfile$setSubmenu(subfile)

#constraints submenu
subcon <- gtkMenu()
mincex <- gtkMenuItemNewWithLabel("Incl/exclusion", show=T)
gSignalConnect(mincex, "activate", f=function(a, data) {
  openIncexWindow()
})
subcon$append(mincex)
mfilters <- gtkMenuItemNewWithLabel("Filter(s)", show=T)
gSignalConnect(mfilters, "activate", f=function(a, data) {
  openFilterWindow()
})
subcon$append(mfilters)
mconstraints$setSubmenu(subcon)

#Core
lhs <- gtkFrame("LHS")
rhs <- gtkFrame("RHS")
core$packStart(lhs, fill=T)
core$packStart(rhs, fill=T)
core$add(all)

#LHS
scrolled <- gtkScrolledWindow()
scrolled$setPolicy("never", "automatic")
lhs$add(scrolled)

#scrollable jobs
jobs <- gtkVBox(homogeneous=T, spacing=5)
scrolled$addWithViewport(jobs)

#RHS
notebook <- gtkNotebook()
notebook$appendPage(gtkLabel("Page 1"), gtkLabel("Tab 1"))
notebook$appendPage(gtkLabel("Page 2"), gtkLabel("Tab 2"))
rhs$add(notebook)

#display
window$show()
