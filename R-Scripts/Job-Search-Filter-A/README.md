**EXPO**


This iteration of the Job-Search-Filter was (once again) created on and off last week. This iteration attempts to correct most of the issues present in the first iteration. It also attempts to add features that were not present in the first. The hope is that the current design will be full functional and complete enough to satisfy me. I will then proceed to modify the program once more into a webApp version using Shiny (which, hopefully, will be an easy task due to my present implementation with GTK). As for the things corrected/implemented, they are:
- The rendering and data was kept as separate as possible, only a few times on higher-level functions are references to global variables made.
- All global variables not set by a user are initialized to empty, named, versions of themselves.
- The XML library was used to fetch the page data as opposed to regex.
- The RCurl library was used to obtain the webpages as opposed to actually downloading the pages to a file.
- The render functions were made sufficiently generic such that everything merely calls renderAll().
- The date field in the filters has an associated combobox for choosing greater than or less than.
- The jobs are clickable such that the webpage is opened in the default browser.
- The "applied" checkboxes now work and properly persist between filter applications.
- Color was added to the "Found Good" and "Found Bad" text fields.


**PURPOSE**


Thi program does the following:
- Only/Don't want to work for a specific company? DONE
- Only/Don't want to work for positions which have certain names? DONE
- Only/Don't want to see positions past/prior a certain date? DONE
- Want to see if a job has requirements/desireds you like/don't like? DONE


**USAGE**

Merely set the QUERY field to an Indeed job query URL (making sure to append &filter=0) and proceed to run the Start_Script.R. This will bring up the main window. At the main window the user can choose to either load variables in (for keywords, applied jobs, or filters) or insert them manually via the "Constraints" menu item's "Keywords" submenu item and "Filter(s)" submenu item. To actually acquire job data to view, pull under the File menu item must be clicked. This can occur either before or after setting the keywords or filters. If one wishes to change the filters/keywords searched over this particular pull, merely click refresh. Once done with the program, merely click save and the applied to jobs, the terms, and the filters will be stored to *.rds files.

**COPYRIGHT**<br/>
It's open source of course.


**VERSION**<br/>
0.0.2 (Alpha)
