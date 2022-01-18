#!/bin/ruby
# encoding : utf-8

require 'csv'

Version="1.4"
Documentation=<<EOS
NAME
 bibfilter - allows to filter the entries of a given bibtex file

SYNOPSIS
 ruby bibfilter.rb -cN FILES
 ruby bibfilter.rb [-aT|-rT]+ [-eREG|-iREG] FILES
 ruby bibfilter.rb -n FILES
 ruby bibfilter.rb -h
 ruby bibfilter.rb -V

DESCRIPTION
 bibfilter is a simple commandline tool which enables the user to
 either interactively or automatically filter a given bibtex file.
 Each bibtex entry passing the filter will be printed to STDOUT,
 whereas the interactive part of the programm uses STDERR for its output.
 Please note that all the automatic filters are executed in a strict 
 order first retaining all bibitems (with -a and -i) and afterwards 
 removing the rest according to (-r and -e)


OPTIONS
 -cN   Filter the bibitems by citations and remove all entries with less
       then N citations.
       (This method assumes a citations field in each bibtex entry.)
 -d    remove duplicates from the bibtex entries based on their key.
       This option is combinable with every other option.
 --intersection
       instead of creating the union of all files, create the intersection of
       all file, i.e., only add bibtex entries present in all files.
       This option is combinable with every other option, except difference.
 --difference
       instead of creating the union of all files, creates the difference of
       the first and all files, i.e., only include bibtex entries of the first
       file not included in any subsequent files.
       This option is combinable with every other option, except intersection.       
 -aT   Filter the bibitems and retain all items belonging to a certain
       class (i.e.: article, book, incollections).
       This option can be used multiple times but not in combination 
       with other options! 
 -rT   Filter the bibitems and remove all items belonging to a certain 
       class (i.e.: article, book, incollections).
       This option can be used multiple times but not in combination 
       with other options!
 -e"/REGEX/"
       excludes all bibitems to which this ruby regular expression applies
       The expression will be evaluated for each line of a bibfile, so 
       it is impossible evaluate a howl bibitem.
       This option can be used once, but combined with other automated 
       options like -a, -r, or -i.
 -i"/REGEX/"
       includes all bibitems to which this ruby regular expression applies
       The expression will be evaluated for each line of a bibfile, so 
       it is impossible evaluate a howl bibitem.
       This option can be used once, but combined with other automated 
       options like -a, -r, or -e.
 -n    Perform an Interactive decission process showing the title, the
       link and the number of citations (default).
 -h    Show this document.
 -m    measure the entries in the bibtex file to compute the citations
       min, max, and median as well as the total number of entries.
       This works also in combination with automatic filters but not with
       interactive filter.
 --size
       only emit the number of bibitems. This option implies -m.
 --min 
       only emit the minimum of the citation count. This option implies -m.
 --max
       only emit the maximum of the citation count. This option implies -m.
 --median
       only emit the median of the citation count. This option implies -m.
 --files
       onlyemit the number of referenced files. This option implies -m.
 -l    add the total number of files referenced in the bibtex file to the
       measured entries. This option implies -m.
 -t    creates output of measures in the CSV format with count;
       citations median, min, max. This option implies -m.
 -csv  generates a CSV from the bibtex entries. The default fields to export are
       "Key, Title, Author".
 --fields"[Field]+"
       extracts the given set of fields when creating a CSV file. Field is a 
       comma separated list of bibtex fields (case insensitive). 
       This option implies -csv.
 --sepSEPARATOR
       create the CSV using the specified SEPARATOR (default is semi colon).
       This option implies -csv.
 --empty"STRING"
       shows empty fields as STRING displayed in the CSV output (default None).
       This option implies -csv.
 --yes"STRING"
       displays string if a class without children is selected in the CSV output
       (default Yes). This option implies -csv.
 --classes"[Path+]"
       extract the entries from a classification stored in the classes 
       attribute. PATH is a comma separated list of path expressions with dot,
       e.g., `Meta Data.Kind`. This option implies -csv.
 --noheading
       omit heading when generating the CSV. This option implies -csv.     
 -v    produces verbose output.
 -V    Shows the version number.

USAGE
 ruby bibfilter.rb -c100 paper2002.bib > filteredpapers2002.bib
       remove all bibtex entries from the paper2002.bib file with a
       citation count below 100 and store the remaining entries into the
       file filteredpapers2002.bib
 ruby bibfilter.rb -n paper2002.bib > filteredpapers2002.bib
       go through all the papers interactivelly and

AUTHOR
 Thomas "Eden_06" Kuehn

VERSION
 %s
EOS

#method definitions

def achievements(index,size,removed,l)
 return "[Double Kill]" if l==2
 return "\e[33m[Multi Kill]\e[0m" if l==3
 return "\e[4;31m[Mega Kill]\e[0m" if l==6
 return "\e[5;31m[Ultra Kill]\e[0m" if l==9
 return "\e[31m[M-m-m Monster Kill]\e[0m" if l==12
 return "\e[7;31m[LUDACRIS KILL!]\e[0m" if l==15
 return "\e[1;37;31m[H O L Y S H I T!]\e[0m" if l==18

 return "[removed]"
end

# Copied from https://stackoverflow.com/questions/14859120/calculating-median-in-ruby?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
def median(array)
	return nil if array.to_a.size <= 0
  sorted = array.to_a.sort
  len = sorted.length
  (sorted[(len-1)/2] + sorted[len/2]) / 2.0
end

Scanner=/([,}]|[^{},]+[{]|[^{},]+)/

def parse(classification)
  token=classification.scan(Scanner)
  result=Array.new
  stack=[result]
  token.each do|t|
    case t.first
    when ","
    when /([^},]+)[{]/
      new=[$1.strip]
      stack.last << new
      stack.push(new)
    when "}"
      stack.pop
    else
      stack.last << t.first.strip
    end
  end
  if stack.size>1
    $stderr.puts "[ERROR]: Could not completly parse classification. May missing }." 
    $stderr.puts classification.to_s
  end
  result
end

def extractByPath(classes,path,empty,yes)
  classification=parse(classes)
  ps=path.split(".").map{|p| p.strip}
  c=classification
  ps.each do |p|
    break if c[1..-1].include?(ps.last)
    c=c.assoc(p)
    break if c.nil?
  end
  if c.nil?
    return empty
  else if c[1..-1].include?(ps.last)
      return yes
    else
      return c[1..-1].flatten.join(",")
    end
  end
end

# begin of execution
key="-n" 
files=[]
verbose=false
mincount=0
retain=[]
remove=[]
rinclude=nil
rexclude=nil
summary=false
countfiles=false
table=false
onlyemit=nil
removeduplicates=false
intersection=false
difference=false
# Parameters for CSV output
csvexport=false
fields=["Key","Author","Title"]
emptyField="None"
existingField="Yes"
seperator=";"
classes=[]
noheading=false

ARGV.each do|x| 
 case x
  when /^-c([0-9]+)$/
   key,mincount="-c",$1.to_i
  when /^-d$/
   removeduplicates=true
  when /^--intersection$/
   intersection=true
  when /^--difference$/
   difference=true
  when /^--size$/
   key,summary="-a",true
   onlyemit=lambda{|c,f| c.size}
  when /^--min$/
   key,summary="-a",true
   onlyemit=lambda {|c,f| if c.size>0 then c.last else 0 end}
  when /^--max$/
   key,summary="-a",true
   onlyemit=lambda {|c,f| if c.size>0 then c.last else 0 end}
  when /^--median$/
   key,summary="-a",true
   onlyemit=lambda {|c,f| median(c)}
  when /^--files$/
   key,summary,countfiles="-a",true,true
   onlyemit=lambda {|c,f| f}
  when /^-a([a-zA-Z]+)$/
   key="-a"
   retain << $1.to_s.downcase
  when /^-r([a-zA-Z]+)$/
   key="-a"
   remove << $1.to_s.downcase
  when /^-i\/(.*)\//
   key="-a"
   rinclude=Regexp.new($1)
  when /^-e\/(.*)\//
   key="-a"
   rexclude=Regexp.new($1)
  when /^-[nhV]$/
   key=$~.to_s
  when /^-m$/
   summary=true
   key="-a"
  when /^-l$/
   summary=true
   countfiles=true
   key="-a"
  when /^-t$/
   summary=true
   table=true
   key="-a"
  when /^-csv$/
    csvexport=true;
    key="-a"
  when /^--sep(.+)$/
    seperator=$1
  when /^--empty(.*)$/
    emptyField=$1.strip 
  when /^--exists(.*)$/
    existingField=$1.strip        
  when /^--fields([a-zA-Z,]+)$/
    fields=$1.strip.split(",").map{|f| f.strip}
  when /^--classes([a-zA-Z,. ]+)$/
    classes=$1.strip.split(",").map{|f| f.strip}  
  when /^--noheading$/
    noheading=true
  when /^-v$/
   verbose=true
  else
   files << x
  end
end

if files.empty? or key=="-h"
 puts Documentation % Version
 exit(1)
end

if key=="-V"
 puts Version
 exit(1)
end

files.each do|file|
  unless File.exists?(file)
   $stderr.puts "The selected file %s did not exist." % file
   exit(2)
  end
end

if key=="-e" and regexp.nil?
  $stderr.puts "Option -e and -i require a legal regular expression i.e. \"/patents/\""
  exit(3)
end

if intersection and difference
  $stderr.puts "Options --intersection and --difference are mutual exclusive, only use one of them"
  exit(4)
end

if summary and csvexport
  $stderr.puts "Options -m measure and -csv are mutual exclusive, only use one of them"
  exit(4)
end

bibitems=[]
keysperfile=[]
files.each do|file|
	keysperfile << []
  open(file,"r") do|f|
   f.each_line do|line|
    bibitems << []  if /^@.*/ =~ line
    bibitems.last << line.strip unless bibitems.last.nil?
    keysperfile.last << $1 if /^@.*{(.+),/ =~ line.strip;
   end
  end
end

$stderr.puts "found %d bibitems in %d files"% [bibitems.size,keysperfile.size] if verbose

## compute intersection of all bibitems per file
if intersection
  $stderr.puts "Computing intersection"
  keys=keysperfile.inject(:&)
  h=bibitems.inject(Hash.new){|h,bib| h[$1]=bib if /^@.*{(.+),/ =~ bib.first  and keys.include?($1); h }
  bibitems=keys.map{|k| h[k]} #to retain previous order and duplication
end

## compute difference of all bibitems per file
if difference
	$stderr.puts "Computing difference (relative complement)"
	keys=keysperfile.inject(:-)
  h=bibitems.inject(Hash.new){|h,bib| h[$1]=bib if /^@.*{(.+),/ =~ bib.first  and keys.include?($1); h }
  bibitems=keys.map{|k| h[k]} #to retain previous order and duplication
end

## remove Duplicates
if removeduplicates
 h=bibitems.inject(Hash.new){|h,bib| h[$1]=bib if /^@.*{(.+),/ =~ bib.first; h }
 bibitems=h.values.clone
 $stderr.puts "found %d unique bibitems"%bibitems.size if verbose
end

## select an appropriate filter predicate
predicate=case key
            when "-c"
             lambda {|bib|
                     a=bib.find{|l| /citations.*=.*\{([0-9]+)\}/ =~ l }
                     if a.nil?
                       false
                     else
                       n=$1.to_i                       
                       if n >= mincount
                         true
                       else
                         false
                       end
                     end
             };
            when "-a"
             lambda {|bib|
                     keep=false 
                     #first include all items
                     unless retain.empty? or (bib.find{|l| /^\@([a-zA-Z]+)\{/ =~ l }).nil?
                       keep|=! retain.index($1.to_s.downcase).nil?
                     else unless rinclude.nil?
		                     keep|=! (bib.find{|l| rinclude =~ l }).nil?
		                   else
		                     keep=true
		                   end
                     end
                     if keep
                       unless remove.empty? or (bib.find{|l| /^\@([a-zA-Z]+)\{/ =~ l }).nil?
												 keep&=remove.index($1.to_s.downcase).nil? 
                         # keep will be false if the term is within remove					
											 end
											 unless rexclude.nil?
                         keep&=(bib.find{|l| rexclude =~ l }).nil?
                       end
                     end
                     keep                    
             };              
            when "-n"
             lambda {|bib,i,s,r|
                     $stderr.puts "entry: %d of %d (%.2f %%) removed: %d (%.2f %%)" % [i+1,s,(i*100.0)/s,r,(r*100.0)/(i+1)]
                     $stderr.puts " class  : %s"% $1.to_s unless (bib.find{|l| /^\@([a-zA-Z]+)\{/ =~ l }).nil?
                     $stderr.puts " title  : %s"% $1.to_s unless (bib.find{|l| /title.*=.*\{(.+)\}/ =~ l }).nil?
                     $stderr.puts " authors: %s"% $1.to_s unless (bib.find{|l| /author.*=[^{]*\{(.+)\}/ =~ l }).nil?
                     $stderr.puts " url    : %s"% $1.to_s unless (bib.find{|l| /howpublished.*=.*\{\\url\{(.+)\}\}/ =~ l }).nil?
                     $stderr.puts " cites  : %s"% $1.to_s unless (bib.find{|l| /citations=\{([0-9]+)\}/ =~ l }).nil?
                     $stderr.print("Remove this entry (y/n) [default no]? ")
                     key=$stdin.gets.strip
                     !(/^[yY].*/ =~ key)
                    }
            else nil
          end

filtered=bibitems
## the power of ruby
if key=="-n" and (not predicate.nil?)
 s=bibitems.size
 r=0
 l=0
 bibitems.each_with_index do|x,i|
  if predicate.call(x,i,s,r)
   puts x
   #$stdout.flush #include to immediatly flush the buffer once written
   l=0
  else
   r+=1
   l+=1
   $stderr.puts achievements(i,s,r,l)
  end
 end
else
 unless predicate.nil?
  filtered=bibitems.select(&predicate)
  filtered.each{|x| puts x} unless summary or csvexport
 end
end

if summary
  citations=filtered.map do|bib|
    if bib.find{|l| /citations.*=.*\{([0-9]+)\}/ =~ l }.nil?
      0
    else 
      $1.to_i # abused side effect
    end
  end.sort
  filecount=filtered.inject(0) do|sum,bib|
    if bib.find{|l| /file.*=.*\{.+\}/ =~ l }.nil? then sum else sum+1 end
  end
  if table
    a=[citations.size,
       median(citations),
       citations.first,
       citations.last]
    a << filecount if countfiles
    puts (a.map{|x| if x.nil? then 0 else x end}).join(", ")
  elsif not onlyemit.nil?
		puts onlyemit.call(citations,filecount)  	
  else
    puts "size:       %d"    % citations.size
    puts "median:     %0.2f" % median(citations) if citations.size > 1
    puts "min:        %d"    % citations.first   if citations.size > 1
    puts "max:        %d"    % citations.last    if citations.size > 1
    puts "file links: %d"    % filecount         if countfiles
  end
end

if csvexport
  result=CSV.generate("",col_sep: seperator) do |csv|
    csv << fields+classes unless noheading
    fieldMatcher=fields.map do|f|
      s=f.strip.downcase
      [s,Regexp.new("^\\s*"+s+"\\s*=[^{\"]*[{\"](.*)[}\"][,]?$")]
    end
    filtered.each do|bib|
      row=[]
      fieldMatcher.each do|field,fieldreg|
        if field=="key"
          if bib.find{|l| /^@.*{(.+),/ =~ l }
            row << $1.to_s.strip
          else
            $stderr.puts "[ERROR]: Could not find bibkey in:"
            $stderr.puts bib
            row << emptyField
          end
        else
          if bib.find{|l| fieldreg =~ l }
            row << $1.to_s.strip
          else 
            row << emptyField
          end
        end
      end
      if bib.find{|l| /classes.*=[^{]*\{(.*)\}[,]?$/ =~ l }
        clazz=$1.strip
        classes.each do|path|
          row << extractByPath(clazz,path,emptyField,existingField)
        end
      end
      csv << row
    end
  end
  puts result
end


