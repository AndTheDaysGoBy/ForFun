openIncexWindow <- function() {
  incexWin <- gtkWindow(show=F)
  window$setTitle("Keyword Inclusion/Exclusion")
  incexWin['modal'] <- T
  
  all <- gtkVBox(homogeneous = F)
  forms <- gtkHBox(homogeneous = T)
  all$packStart(forms, expand=T, fill=T)
  incexWin$add(all)
  
  #Create the two text displays.
  viewWant <- gtkTextView()
  bufferWant <- viewWant$getBuffer()
  if (!is.null(globTerms[['want']]))
    bufferWant$setText(paste(globTerms[['want']], collapse="\n"))
  viewDont <- gtkTextView()
  bufferDont <- viewDont$getBuffer()
  if (!is.null(globTerms[['dont']])) 
    bufferDont$setText(paste(globTerms[['dont']], collapse="\n"))
  
  lhs <- gtkFrame(label="Want:")
  forms$packStart(lhs, padding=10)
  rhs <- gtkFrame(label="Dont:")
  forms$packEnd(rhs, padding=10)
  
  scrollL <- gtkScrolledWindow()
  scrollL$setPolicy("never", "automatic")
  lhs$add(scrollL)
  
  scrollR <- gtkScrolledWindow()
  scrollR$setPolicy("never", "automatic")
  rhs$add(scrollR)
  
  scrollL$add(viewWant)
  scrollR$add(viewDont)
  
  saveIncex <- gtkButton("Save Settings")
  gSignalConnect(saveIncex, "clicked", f=function(button) {
    textWant <- bufferWant$getText(bufferWant$getStartIter()$iter, bufferWant$getEndIter()$iter)
    textDont <- bufferDont$getText(bufferDont$getStartIter()$iter, bufferDont$getEndIter()$iter)
    
    globTerms['want'] <<- list(getKeywords(textWant))
    globTerms['dont'] <<- list(getKeywords(textDont))
  
  })
  all$packEnd(saveIncex, expand = F, fill=F, padding=10)
  
  incexWin$show()
}
