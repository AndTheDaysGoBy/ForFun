openKeywordsWindow <- function() { #BFS
	#Top-level design
	keywordsWindow <- gtkWindow(show=F)
	keywordsWindow$setTitle("Keyword Inclusion/Exclusion")
	keywordsWindow['modal'] <- T

	#Window layout
	all <- gtkVBox(homogeneous = F) #H inside V since table layout doesn't look as good due to padding.
	keywordsWindow$add(all)

	#Window design
	forms <- gtkHBox(homogeneous = T)
	all$packStart(forms, expand=T, fill=T)

	#Want description label
	want <- gtkFrame(label="Want:")
	forms$packStart(want, padding=10)

	#Don't Want description label
	dont <- gtkFrame(label="Dont:")
	forms$packEnd(dont, padding=10)

	#ScrollWantPane
	ScrollWantPane <- gtkScrolledWindow()
	ScrollWantPane$setPolicy("never", "automatic")
	want$add(ScrollWantPane)

	#ScrollDontPane
	ScrollDontPane <- gtkScrolledWindow()
	ScrollDontPane$setPolicy("never", "automatic")
	dont$add(ScrollDontPane)

	#Want text display
	viewWant <- gtkTextView()
	bufferWant <- viewWant$getBuffer()
	if (!is.null(TERMS[['want']]))
		bufferWant$setText(paste(TERMS[['want']], collapse="\n"))
	ScrollWantPane$add(viewWant)

	#Don't Want text display
	viewDont <- gtkTextView()
	bufferDont <- viewDont$getBuffer()
	if (!is.null(globTerms[['dont']])) 
		bufferDont$setText(paste(TERMS[['dont']], collapse="\n"))
	ScrollDontPane$add(viewDont)

	#Save the keywords
	saveKeywords <- gtkButton("Save Settings")
	gSignalConnect(saveKeywords, "clicked", f=function(button) {
		textWant <- bufferWant$getText(bufferWant$getStartIter()$iter, bufferWant$getEndIter()$iter)
		textDont <- bufferDont$getText(bufferDont$getStartIter()$iter, bufferDont$getEndIter()$iter)

		TERMS['want'] <<- list(getKeywords(textWant))
		TERMS['dont'] <<- list(getKeywords(textDont))
	})
	all$packEnd(saveKeywords, expand = F, fill=F, padding=10)

	#Display
	keywordsWindow$show()
}
