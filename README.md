In this package, please find the  following content:

* Investigated Papers.bib
	* A BibTeX file with all papers investigated in the paper "Evaluation Methods and Replicability of Software Architecture Research Objects"
* Raw-Data-Table Content-Data.html and Raw-Data-Table Meta-Data.html
	* Tables with the raw data as extracted during the SLR
* Colection of Data Visualizations.pdf
	* Multiple visualizations of the raw data for analysis.
* Data and Visualization
	* Contains:
		+ The data as CSV files,
		+ scripts for creating visualizations
			- *.awk -- Awk scripts are used to create the corresponding of the *.csv files in data
    		- .rb -- Ruby scripts to build the respective figures in figs as .*.tex files
    		- make.sh -- A script to call all other scripts for creating diagrams and the summary.
		+ Requirements: A UNIX commandline environment (e.g., bash) with awk installed; Ruby (2.5 or higher)
		+ To create the diagrams, please run the script make.sh in a UNIX commandline environment
* [Wiki](https://gitlab.com/SoftwareArchitectureResearch/StateOfPractice/-/wikis/home)
	* A copy of the wiki used during data extraction.
	* Constains:
		+ descriptions of all data items
		+ the process description
		+ the taxonomy used for data extraction