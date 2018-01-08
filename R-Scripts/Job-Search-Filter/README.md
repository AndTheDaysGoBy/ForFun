**EXPO**


This iteration of the Job-Search-Filter was created over the course of the last week solely for me to learn how to use R and GTK. In the future, a new iteration (separate from this one) will be created. Since the overhaul will make use of packages better suited for certain jobs (as opposed to from scratch), editing these files would be pointless.
The next iteration will make an attempt to use what I've learned and fix certain things I though about as I created the program. These things are:
- Keeping the rendering and data separate (i.e. no global variable interference if possible: at worst, a wrapper function will access the globals)
- The only things that will be nulled will be user-defined variables, the others will not be null, but named
- The XML library will be used for parsing as opposed to just regex
- The RCurl library will be used to obtain pages so that they may exist temporarily (as opposed to downloaded to a specific file)
- Make the render functions more generic due to overlap in the job display and filter display code
- Change the OLDER/NEW/ON entry for "DATE" with a combobox
- Make the jobs rendered clickable so that the URL is rendered on the RHS
- Add functionality to the apply checkbox, which goes hand in hand with storing objects as opposed to values for certain fields (e.g. active field)
- Making pulling and setting the inclusion/exclusion words commutative
- Add color to inclusion/exclusion labels


**PURPOSE**


I have recently graduated university, and have been looking at jobs. I noticed that these job search engines don't have certain functionalities I would like (e.g. I don't want to work in certain areas due to the cost of living). So, I decided to implement a program which would take this data and filter it. Since R seems most suited for data analytics and filteration, I thought it most suitable for the job (although, the creating of a GUI was a bit more tedious than I'd hoped due to not being familiar with GTK). In short, this program does the following:
- Only/Don't want to work for a specific company? DONE
- Only/Don't want to work for positions which have certain names? DONE
- Only/Don't want to see positions past/prior a certain date? DONE
- Want to see if a job has requirements/desireds you like/don't like? DONE


**USAGE**


The program at present has two things that are not necessary, these are the applied checkbox on the rendered jobs and the RHS. At its core, this program works as follows:<br/>
In main_window.R, assign to globQuery the string resulting from a search on Indeed. Proceed to run the library calls in main_window.R, and then run back_end.R, filter_window.R, and incex_window.R scripts in order to initialize the functions. Proceed to run the rest of main_window.R.


The window should be visible. On this window, the RHS notebook can be ignored, it has no purpose. Now, youu have two options, define the filters before pulling, or define the filters after pulling, both work. This is not true for the list of keywords you find good/bad. These should be set before pulling, or you'll have to pull again once they're set.<br/>
For the Inclusion/Exclusion window, there are two text area columns. The keywords will be delimited by newlines (although space within the same line will be ignored if it's on the ends). The save button must be pressed so that the words are stored, exiting will not do so.


For the filter window, the MUST/CANNOT radio button is self-explanatory. The following combobox is used to define which class of filter is to be used (i.e., filter w.r.t. the job title, the company name, or the date). Then, there is the entry form wherein the input for these filters is set. This data differs by the filter:<br/>
The "Job Title" filter takes in a string.<br/>
The "Company Name" filter takes in a string.<br/>
The "Date" filter takes in one of three strings, "OLDER", "NEWER", and "ON". Note, the comparisons for "OLDER" and "NEWER" are strict.<br/>
Note, the filters for the job title and the company name look for the entry as a substring (not an exact match).<br/>
Lastly, is the button for submission. This will add a new filter.


There are two more menu items on the main window, these are save and load. These save and load only a single thing, the jobs applied to (Indeed URLs). The purpose of this is so that there is some persistance between sessions (and since the result of a pull is liable to change between sessions, saving it seems unnecessary).


**COPYRIGHT**<br/>
It's open source of course.


**VERSION**<br/>
0.0.1 (Alpha)
