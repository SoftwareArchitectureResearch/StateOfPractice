#!/bin/bash
INPUT="ECSA-ICSA-Proceedings.bib"
DATADIR="data"
TEMP="$DATADIR/Temp.csv";

# RQ 1: What is the distribution of research objects and their evaluation, and how did their proportions change over time?

# 1.1.	What is the proportion of research objects in the body of literature per year?

RESEARCHOBJECTS="$DATADIR/Unique_Research_Objects.csv";

echo "$RESEARCHOBJECTS"


ruby bibfilter.rb -csv --fields"year,key" --classes"First Research Object.Research Object" --sep"|" --noheading "$INPUT" > "$TEMP";
ruby bibfilter.rb -csv -i"/Second Research Object/" --fields"year,key" --classes"Second Research Object.Research Object" --sep"|" --noheading "$INPUT"  >> "$TEMP";

echo "Year|Paper ID|Research Object" > "$RESEARCHOBJECTS";
sort -u "$TEMP" >> "$RESEARCHOBJECTS";

#creates research_objects_* diagrams
ruby mkresearchobject.rb

# 1.2.	What is the proportion of evaluation methods in the body of literature per year?

EVALUATIONTYPES="$DATADIR/Unique_Evaluation_Methods.csv";

echo "$EVALUATIONTYPES"

ruby bibfilter.rb -csv --fields"year,key" --classes"First Research Object.Research Object,First Research Object.First Evaluation.Evaluation Method,First Research Object.Second Evaluation.Evaluation Method" --sep"|" --noheading "$INPUT" > "$TEMP";

ruby bibfilter.rb -csv -i"/Second Research Object/" --fields"year,key" --classes"Second Research Object.Research Object,Second Research Object.First Evaluation.Evaluation Method,Second Research Object.Second Evaluation.Evaluation Method" --sep"|" --noheading "$INPUT" >> "$TEMP";

echo "Year|Paper ID|Research Object|Evaluation Method" > "$EVALUATIONTYPES";
awk -F"|" '{if($5=="None") a[$2"|"$3]=$4; else a[$2"|"$3]=$4","$5; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' "$TEMP" | sort -u >> "$EVALUATIONTYPES";

#creates evaluation_methods_* diagrams
ruby mkevaluationmethod.rb

# 1.3.	What is the proportion of papers for which artifacts were provided for replication per year?

ARTIFACTEVALUATION="$DATADIR/Unique_Artifact_Evaluation.csv";

echo "$ARTIFACTEVALUATION"

ruby bibfilter.rb -csv --fields"year,key" --classes"Validity.Tool Support,Validity.Input Data,Validity.Replication Package" --sep"|" --noheading "$INPUT" > "$TEMP";

echo "Year|Paper ID|Tool Support|Input Data|Replication Package|Artifacts" > "$ARTIFACTEVALUATION";
awk -F"|" '{rep=""; if($5=="Yes"){ rep="packaged"; }else{ if ($3=="available" || $4=="available"){ rep="available" }else{ if ($3=="used" || $4=="used") rep="used"; else rep="none";  }  } print $1"|"$2"|"$3"|"$4"|"$5"|"rep; }' "$TEMP" | sort -u >> "$ARTIFACTEVALUATION";

ruby mkartifactevaluation.rb


# RQ 2: How are specific research objects evaluated, and how accessible are their evaluation artifacts?

# RQ 2.1 What is the relationship between the evaluation method and the research object?

# allready created via RQ 1.1

# RQ 2.2 What is the relationship between the research object and the evaluated property?

RO_PROPERTIES="$DATADIR/Research_Object_to_Property.csv";

echo "$RO_PROPERTIES"

ruby bibfilter.rb -csv --fields"year,key" --classes"First Research Object.Research Object,First Research Object.First Evaluation.Properties.Quality in Use,First Research Object.First Evaluation.Properties.Product Quality,First Research Object.First Evaluation.Properties.Quality of Method,First Research Object.Second Evaluation.Properties.Quality in Use,First Research Object.Second Evaluation.Properties.Product Quality,First Research Object.Second Evaluation.Properties.Quality of Method" --sep"|" --noheading "$INPUT" > "$TEMP";

ruby bibfilter.rb -i"/Second Research Object/" -csv --fields"year,key" --classes"Second Research Object.Research Object,Second Research Object.First Evaluation.Properties.Quality in Use,Second Research Object.First Evaluation.Properties.Product Quality,Second Research Object.First Evaluation.Properties.Quality of Method,Second Research Object.Second Evaluation.Properties.Quality in Use,Second Research Object.Second Evaluation.Properties.Product Quality,Second Research Object.Second Evaluation.Properties.Quality of Method" --sep"|" --noheading "$INPUT" >> "$TEMP";

echo "Year|Paper ID|Research Object|Property" > "$RO_PROPERTIES";
awk -F"|" '{s[0]=$4; s[1]=$5; s[2]=$6; s[3]=$7; s[4]=$8; s[5]=$9; result=sep=""; for (i in s){ if (s[i]!="None"){ result=result sep s[i]; sep=","; } } if(result=="") a[$2"|"$3]="None"; else a[$2"|"$3]=result; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' "$TEMP" | sort -u >> "$RO_PROPERTIES";

ruby mkresearchperproperties.rb


# RQ 2.3 What is the relationship between the evaluation method and the evaluated property?

PROP_EVALUATION="$DATADIR/Evaluation_Method_to_Property.csv";

echo "$PROP_EVALUATION"

ruby bibfilter.rb -csv --fields"year,key" --classes"First Research Object.First Evaluation.Evaluation Method,First Research Object.First Evaluation.Properties.Quality in Use,First Research Object.First Evaluation.Properties.Product Quality,First Research Object.First Evaluation.Properties.Quality of Method" --sep"|" --noheading "$INPUT" > "$TEMP";
ruby bibfilter.rb -i"/First Research Object.*Second Evaluation/" -csv --fields"year,key" --classes"First Research Object.Second Evaluation.Evaluation Method,First Research Object.Second Evaluation.Properties.Quality in Use,First Research Object.Second Evaluation.Properties.Product Quality,First Research Object.Second Evaluation.Properties.Quality of Method" --sep"|" --noheading "$INPUT" >> "$TEMP";
ruby bibfilter.rb -i"/Second Research Object.*First Evaluation/" -csv --fields"year,key" --classes"Second Research Object.First Evaluation.Evaluation Method,Second Research Object.First Evaluation.Properties.Quality in Use,Second Research Object.First Evaluation.Properties.Product Quality,Second Research Object.First Evaluation.Properties.Quality of Method" --sep"|" --noheading "$INPUT" >> "$TEMP";
ruby bibfilter.rb -i"/Second Research Object.*Second Evaluation/" -csv --fields"year,key" --classes"Second Research Object.Second Evaluation.Evaluation Method,Second Research Object.Second Evaluation.Properties.Quality in Use,Second Research Object.Second Evaluation.Properties.Product Quality,Second Research Object.Second Evaluation.Properties.Quality of Method" --sep"|" --noheading "$INPUT" >> "$TEMP";

echo "Year|Paper ID|Evaluation Method|Property" > "$PROP_EVALUATION";
awk -F"|" '{s[0]=$4; s[1]=$5; s[2]=$6; result=sep=""; for (i in s){ if (s[i]!="None"){ result=result sep s[i]; sep=","; } } if(result=="") a[$2"|"$3]="None"; else a[$2"|"$3]=result; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' "$TEMP" | sort -u >> "$PROP_EVALUATION";

ruby mkpropertyperevaluation.rb

# RQ 2.4 What is the relationship between the evaluation method and the paper class?

PC_EVALUATION="$DATADIR/Evaluation_Method_to_Paper_class.csv";

echo "$PC_EVALUATION"

ruby bibfilter.rb -csv --fields"year,key" --classes"Meta Data.Paper class,First Research Object.First Evaluation.Evaluation Method,First Research Object.Second Evaluation.Evaluation Method,Second Research Object.First Evaluation.Evaluation Method,Second Research Object.Second Evaluation.Evaluation Method" --sep"|" --noheading "$INPUT" > "$TEMP";

echo "Year|Paper ID|Paper Class|Evaluation Method" > "$PC_EVALUATION";
awk -F"|" '{s[0]=$4; s[1]=$5; s[2]=$6; s[3]=$7; result=sep=""; for (i in s){ if (s[i]!="None"){ result=result sep s[i]; sep=","; } } if(result=="") a[$2"|"$3]="None"; else a[$2"|"$3]=result; b[$2"|"$3]=$1;}END{for (i in a) print b[i]"|"i"|"a[i];}' "$TEMP" | sort -u >> "$PC_EVALUATION"

ruby mkpaperclassperevaluation.rb

# RQ 2.5 What is the relationship between the evaluation method and the threats to validity?

ToV_EVALUATION="$DATADIR/Evaluation_Method_to_Threats_to_Validity.csv";

echo "$ToV_EVALUATION"

ruby bibfilter.rb -csv --fields"year,key" --classes"Validity.Threats To Validity,First Research Object.First Evaluation.Evaluation Method,First Research Object.Second Evaluation.Evaluation Method,Second Research Object.First Evaluation.Evaluation Method,Second Research Object.Second Evaluation.Evaluation Method" --sep"|" --noheading "$INPUT" > "$TEMP";

echo "Year|Paper ID|Threats To Validity|Evaluation Method" > "$ToV_EVALUATION"
awk -F"|" '{s[0]=$4; s[1]=$5; s[2]=$6; s[3]=$7; result=sep=""; for (i in s){ if (s[i]!="None"){ result=result sep s[i]; sep=","; } } if(result=="") a[$2]="None"; else a[$2]=result; b[$2]=$1; c[$2]=$3; }END{for (i in a) print b[i]"|"i"|"c[i]"|"a[i];}' "$TEMP" | sort -u >> "$ToV_EVALUATION"

ruby mkthreatsperevaluation.rb

# RQ 2.6 What is the relationship between the evaluation method and the provision of replication artifacts?

AE_EVALUATION="$DATADIR/Evaluation_Method_to_Replication_Package.csv";

echo "$AE_EVALUATION"

ruby bibfilter.rb -csv --fields"year,key" --classes"Validity.Tool Support,Validity.Input Data,Validity.Replication Package,First Research Object.First Evaluation.Evaluation Method,First Research Object.Second Evaluation.Evaluation Method,Second Research Object.First Evaluation.Evaluation Method,Second Research Object.Second Evaluation.Evaluation Method" --sep"|" --noheading "$INPUT" > "$TEMP";

echo "Year|Paper ID|Tool Support|Input Data|Replication Package|Artifacts|Evaluation Method" > "$AE_EVALUATION"
awk -F"|" -f "replicationevaluation.awk" "$TEMP" | sort -u >> "$AE_EVALUATION"

ruby mkreplicationperevaluation.rb

# evaluation guidelines pro paper

echo "Compile latex..."

# create the figures shown in the paper
latexmk -pdf paper-figures

exit 
