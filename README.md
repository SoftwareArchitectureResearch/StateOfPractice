# Content
In this package, please find the  following content:

* Investigated Papers.bib
	A BibTeX file with all papers investigated in the paper "Evaluation Methods and Replicability of Software Architecture Research Objects"
* Raw-Data-Table Content-Data.html and Raw-Data-Table Meta-Data.html
	Tables with the raw data as extracted during the systematic literature review
* Colection of Data Visualizations.pdf
	Multiple visualizations of the raw data for analysis. A copy of summary.pdf as described below.
* Data and Visualization
	Contains:
	- The data as CSV files,
	- scripts for creating visualizations
		- *.awk -- Awk scripts are used to create the corresponding of the ```*.csv``` files in data
    	- *.rb -- Ruby scripts to build the respective figures in figs as ```*.tex``` files
    	- make-all.sh -- A script to call all other scripts for creating diagrams and the summary
		- make-paper-figures.sh -- A script to build ```paper-figures.pdf``` with all diagrams used in the accompanying paper
	- A documentation of the contained scripts (```Data and Visualization/README.md```)
	- summary.pdf -- A collection of diagrams (as built by ```make-all.sh```)
	- paper-figures.pdf -- A collection of all diagrams as used in the accompanying paper (as built by ```make-paper-figures.sh```)
* Wiki/
	A copy of the wiki used during data extraction.
	Constains:
	- descriptions of all data items
	- the process description
	- the taxonomy used for data extraction


# Reproduction
You can reproduce the visualizations with the following commands in a UNIX command line environment.

´´´
cd "Data and Visualization"
./make-paper-figures.sh
./make-all.sh
´´´

The requirements are:
* A UNIX command line environment (e.g., bash) with awk installed
* Ruby (>2.5)
* latex (e.g., tex-live)


The command ```./make-paper-figures.sh``` produces the file ```paper-figures.pdf```, which contains all diagrams that are used in the paper.
The command ```./make-all.sh``` produces the file ```summary.pdf```, which contains diagrams used for data analysis, and the file ```paper-figures.pdf```. All figures describing the results in the paper are also in ```summary.pdf```.
These commands each take about 2 (```/make-paper-figures.sh```) / 8 (```./make-all.sh```) minutes to run on current standard laptop (Intel i5-8250U, 16 GB memory).
Calling the commands produces many log statements (information and warnings), which show the progress and can be ignored.

