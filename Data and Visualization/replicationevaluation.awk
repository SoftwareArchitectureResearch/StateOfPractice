# Script to create the following fields
# input:
#  year|key|Tool Support|Input Data|Replication Package|First Evaluation Method|Second Evaluation Method|Third Evaluation Method|Fourth Evaluation Method
# output:
#  Year|Paper ID|Tool Support|Input Data|Replication Package|Artifacts|Evaluation Method
{
  s[0]=$6; 
  s[1]=$7; 
  s[2]=$8; 
  s[3]=$9; 
  result=sep=""; 
  for (i in s){ 
    if (s[i]!="None"){ 
      result=result sep s[i]; sep=","; 
    }
  } 
  if(result=="") 
    a[$2]="None"; 
  else 
    a[$2]=result; 
  b[$2]=$1; 
  c[$2]=$3; 
  d[$2]=$4; 
  e[$2]=$5; 
  
  artifacts=""; 
  if($5=="Yes"){ 
    artifacts="packaged"; 
  }else{ 
    if ($3=="available" || $4=="available"){ 
      artifacts="available" 
    }else{ 
      if ($3=="used" || $4=="used") 
        artifacts="used"; 
      else 
        artifacts="none";
    }
  }
  f[$2]=artifacts;
}END{
  for (i in a) 
    print b[i]"|"i"|"c[i]"|"d[i]"|"e[i]"|"f[i]"|"a[i];
}
