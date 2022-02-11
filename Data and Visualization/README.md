Here we briefly outline the different scripts and their purpose:

> **Please be patient when running the Make scripts, as they take a long time to complete, due to the limitations of LaTeX to render diagrams.**

* **Make Scripts**

    * `make-all.sh`  
        This script calls all other Ruby and AWK scripts to collect the data from the `ECSA-ICSA-Proceedings.bib` into the `data` folder and compiles both the `summary.pdf` and `paper-figures.pdf`.
    * `make-paper-figures.sh`  
                This script calls all other Ruby and AWK scripts to collect the data from the `ECSA-ICSA-Proceedings.bib` into the `data` folder and only compiles the `paper-figures.pdf`, which only contains the figures presented in the paper.

* **Ruby Scripts**

    * `bibfilter.rb`  
        Is a lightweight commandline tool to filter bibtex files. It was tailored to work together with gsresearch and the SLR Toolkit. The tool and its documentation can be found [here](https://github.com/Eden-06/bibfilter).
    * `mkartifactevaluation.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Unique_Artifact_Evaluation.csv` into the `figs` folder, indicating the distribution and occurence of artifacts for replication.
    * `mkevaluationmethod.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Unique_Evaluation_Methods.csv` into the `figs` folder, indicating the distribution and occurence of evaluation methods (per research object).
    * `mkpaperclassperevaluation.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Evaluation_Method_to_Paper_class.csv` into the `figs` folder, indicating the relation between evaluation method and paper class.
    * `mkpaperclass.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Unique_Paper_Class.csv` into the `figs` folder, indicating the distribution and occurence of classes of papers.
    * `mkpropertyperevaluation.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Evaluation_Method_to_Property.csv` into the `figs` folder, indicating the relation between evaluated properties and evaluation method.
    * `mkreplicationperevaluation.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Evaluation_Method_to_Replication_Package.csv` into the `figs` folder, indicating the relation between evaluation method and replication package provided.
    * `mkresearchobject.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Unique_Research_Objects.csv` into the `figs` folder, indicating the distribution and occurence of research objects.        
    * `mkresearchperproperties.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Research_Object_to_Property.csv` into the `figs` folder, indicating the relation between research object and properties evaluated.
    * `mkthreatsperevaluation.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Evaluation_Method_to_Threats_to_Validity.csv` into the `figs` folder, indicating the relation between threats to validity and evaluation method.
    * `mkthreatstovalidity.rb`  
        Is a tailored script to generate various pgfplots diagrams, e.g., histogram, stacked bar charts, or portfolie diagrams, from the data in the `Unique_Threats_to_Validity.csv` into the `figs` folder, indicating the distribution and occurence of threats to validity discussions.
    
* **AWK Scripts**
    
    * `replicationevaluation.awk`  
        This scripts collates the fields Tool Support, Input Data, Replication Package to create a combined classification as Artifact none, used, available or packaged.


