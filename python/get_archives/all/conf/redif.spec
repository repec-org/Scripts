###
### Redif data format specification file
###
#
# version revised by Thomas Krichel in July 2000
#
# Format of this file is
#
# statement : <type> = <name> <block> '\n' (space and
#                       tabulation characters insensitive)
#             'type' = <typename> <typeblock>
#             'cluster' = <clustername> <attrblock>
#             'template' = <templatename> <attrblock>
#
# <type> : 'type' | 'cluster' | 'template' (case insensitive)
# <name> : /[
#
# attribute_name[:[type][:[subtype][:[required flag][:[repeatable flag]]]]]
#

###
### User-defined types (checking procedures)
###

##
## Handles checking regular expression 
##

# all handles types follow in alphabetic order
type = archivehandle / check-regex {
   ^(?:RePEc|ReLIS|mapin):[a-zA-Z]{3}$
}

# documenthandle to be used for paper, article and software
type = documenthandle / check-regex {
   ^(?:RePEc|ReLIS|mapin):[a-zA-Z]{3}:[a-zA-Z\d]{6}:[^\s\n]+$
}

type = institutionhandle / check-regex {
   ^(?:RePEc|ReLIS|mapin):[a-zA-Z]{3}:[a-zA-Z\d]{7}$
}

type = personhandle / check-regex {
   ^(?:RePEc|ReLIS|mapin):[a-zA-Z]{3}:\d{4}-[01]\d-[0-3]\d:[^\s\n]+$
}

type = serieshandle / check-regex {
   ^(?:RePEc|ReLIS|mapin):[a-zA-Z]{3}:[a-zA-Z\d]{6}$
}


##
## all non-handle types, ordered alphabetically 
##

type = date / preproc {
     return if $value eq '';
     if ($value !~ /-/ ) {
        $value =~ s/^(\d{4})(\d{2})$/$1-$2/;
        $value =~ s/^(\d{4})(\d{2})(\d{2})/$1-$2-$3/; }
     if ($value !~ /^\d{4}(-\d\d){0,2}$/ ) {

        if ($rr::Options{'MessageOut'}) {
              &include_attrline;
              msg "($file, $line): A bad date value format: \"$value\"", 2;
        } else {
              $value = '' ;
        } return 1; }
}

type = email / check-eval {
 $value =~ /^[\#\+A-Za-z0-9\-\.\=\_]+\@[A-Za-z0-9\-\.\=\_]+\.[A-Za-z0-9\.\-\=]+$/;
}

type = fileformat / preproc {
     return if $value eq '';
     if ($value !~ (\w+)/(\w*) ) {
        if ($rr::Options{'MessageOut'}) {
              &include_attrline;
              msg "($file, $line): A bad file format value: \"$value\"", 2;
        } else {
              $value = '' ;
        } return 1; }
}

type = JEL / preproc {
     return 1 if $value eq '';

     if ($value !~ /^[A-Za-z][0-9]{0,2}([,;:\.\s]+[A-Za-z][0-9]{0,2})*[,;:\.\s]*$/ ) {
           if ($rr::Options{'MessageOut'}) {
              &include_attrline;
              msg "($file, $line): An invalid JEL value \"$value\"", 2;
           } else {
              $value = '' ;
           } return 1; }
     my $v = uc $value ;
     my @J = split ( /[,;:\s\.]+/, $v );

    if ( not require ReDIF::JELcodes )   {
        msg( "can't load JELcodes.pm file", 3 );     }
     $value = '';
     my $J;
     foreach $J (@J) {
          if (exists $JELcodes::JEL{$J}) {
             $value .= $J;
             $value .= ' ';
          } else {
             msg "($file, $line): An invalid JEL code used \"$J\"", 2;
     } }
     chop $value; return 1;
}

# publication status type implements Sune's requirement that the
# first word in the publication status should be either "published" or
# "forthcoming"
type = pubstat / check-eval     {
  if (($value !~ /^Forthcoming/i) && ($value !~ /^Published/i)) {
    return 0;
  } else { return 1; }
}

### url preprocessing
type = url / preproc {
     if ($value =~ /\-\ [^\ \n]/ ) {
          &include_attrline;
          msg ("($file, $line): Do not split URL after dash!", 3) ;
          return 1; }
     $value =~ s/\s+|\n+//g;
}


### url type---almost according to RFC URI specification
type = URL / check-eval {
 if ( ($value =~ /^(ftp|http):\/\//i) && ($value !~ /^(ftp|http):\/\//) ) {
#        msg "($file, $line): URL capitalization is bad \"$value\"", 2;
        $value =~ s/^Ftp/ftp/i;
        $value =~ s/^Http/http/i;
        ;}
 $value =~ /^(URL:)?
 (ftp|http|gopher)\:
 \/\/[^\=\;\/\#\?\:\ \{\}\|\[\]\\\^\~\<\>]+
 (\:[0-9]+)?
 ([^\=\;\#\?\:\ \{\}\|\[\]\^\<\>]+)?
 (\?[^\\;\#\?\:\ \{\}\|\[\]\^\~\<\>]*)?
 (\#[^\\;\#\?\:\ \{\}\|\[\]\^\~\<\>]*)?$/x;
}

#
# valid until 2000-09-01
# 
## url type---almost according to RFC URI specification
#type = URL / check-eval {
# if ( ($value =~ /^(ftp|http):\/\//i) && ($value !~ /^(ftp|http):\/\//) ) {
##        msg "($file, $line): URL capitalization is bad \"$value\"", 2;
#        $value =~ s/^Ftp/ftp/i;
#        $value =~ s/^Http/http/i;
#        ;}
# $value =~ /^(URL:)?
# (ftp|http|gopher)\:
# \/\/[^\=\;\/\#\?\:\ \{\}\|\[\]\\\^\~\<\>]+
# (\:[0-9]+)?
# ([^\=\;\#\?\:\ \{\}\|\[\]\\\^\<\>]+)?
# (\?[^\\;\#\?\:\ \{\}\|\[\]\\\^\~\<\>]*)?
# (\#[^\\;\#\?\:\ \{\}\|\[\]\\\^\~\<\>]*)?$/x;
#}




###
### Cluster definitions
###

cluster=File {
        URL:URL::*
        Format
        Restriction
        Function::::1
        Size
}

Cluster=Organization {
        Name:::*
        Name-English
        Location
        Postal
        Email
        Phone
        Fax
        Homepage:URL
	Institution:institutionhandle:::1
}

Cluster=Person {
        Name:::*
        WorkPlace:cluster:Organization
        Email
        Fax
        Postal
        Phone
        Homepage:URL
	Person:personhandle:::1
}

###
### Template definition 
###
# reminder of structure of elment definition
#
#       1       2         3             4                  5
# attribute[:[type][:[subtype][:[required (min) num][:[repeat (max) num ]]]]]
#

##
## Collection templates
##

template=ReDIF-Archive 1.0 {
        Template-Type:::*
        Name:::1
        URL:URL::1
        Homepage:URL
        Description
        Maintainer-Email:email::1
        Maintainer-Name
        Maintainer-Fax
        Maintainer-Phone
        Access-policy
        Restriction
        Classification-Jel:JEL
        Handle:archivehandle::1:1
}

template=ReDIF-Series 1.0 {
        Template-Type:::*
        Name:::1
        Description
        Classification-Jel:JEL
        Classification-ILA
        Keywords
        type:doctype
        Editor:cluster:Person
        Publisher:cluster:organization
        Order-Postal
        Order-Homepage:URL
        Order-Email:email
        Provider:cluster:organization
        Maintainer-Email:email::1
        Maintainer-Name
        Maintainer-Fax
        Maintainer-Phone
        Restriction
        ISSN
        Notification
        Price
        Handle:serieshandle::1:1
}

template=ReDIF-Mirror 1.0 {
        Template-Type:::*
        Archive-Handle:archivehandle:1
        user
        group
        directory:::1
        Description
        Maintainer-Email:email::1
        Maintainer-Name
        Maintainer-Fax
        Maintainer-Phone
        Machine
        Archives-Included
        Archives-Excluded
        Series-Included
        Series-Excluded
        Location
        ReDIF-only
}


##
## Resource templates
##

template=ReDIF-Article 1.0 {
        Template-Type:::*
        Author:cluster:Person:1
        Title:::1:1
        Abstract
        File:cluster:file
        Classification-Jel:JEL
        Keywords
        Keywords-Attent
        Creation-Date:date:::1
        Journal
        Issue
        Year
        Pages
        Volume
        Month
        Number
        Note
	Price
        Publication-Status:pubstat
        Publication-Date:date
        Order-URL:URL
        Paper-Handle:documenthandle
        Book-Handle:documenthandle
        Chapter-Handle:documenthandle
        Handle:documenthandle::1:1
}

template=ReDIF-Paper 1.0 {
        Template-Type:::*
        Author:cluster:Person:1
        Title:::1:1
        Abstract
        File:cluster:file
        Classification-Jel:jel
	Classification-arxiv
	Classification-acm-1998
	Classification-msc-1991
        Keywords
        Keywords-Attent
	Keywords-cogprints
	comments-paper
        Note
        Length
        Series
        Number
        Contact-Email:email:::1
        Availability
        Creation-Date:date:::1
        Revision-Date:date
        Restriction
        Price
        Publication-Status
        Issue
        Order-URL:URL
        Article-Handle:documenthandle
        Book-Handle:documenthandle
        Chapter-Handle:documenthandle
        Handle:documenthandle::1:1
}

template=ReDIF-Software 1.0 {
        Template-Type:::*
        Author:cluster:Person:1
        Title:::1:1
        Abstract
        File:cluster:file
        Keywords
        Size
        Requires
        Note
        Length
        Series
        Number
        Creation-Date:date:::1
        Revision-Date:date
        Price
        Programming-Language
        Handle:documenthandle::1:1
}

##
## Tangibles templates
##

template=ReDIF-Institution 1.0 {
        Template-Type:::*
        Primary:cluster:organization
        Primary-Area
        Primary-Defunct
        Secondary:cluster:organization
        Secondary-Area
        Secondary-Defunct
        Tertiary:cluster:organization
        Tertiary-Area
        Tertiary-Defunct
        Handle:institutionhandle::1:1
}

template=ReDIF-Person 1.0 {
        Template-Type:::*
        Name-Full:::1
        Name-First
        Name-Last
        Email
        Fax
        Postal
        Phone
        Homepage:URL
        Classification-Jel
	Workplace:cluster:organization
	Workplace-institution:institutionhandle
	Author-Paper
	Author-Article
	Author-Software
	Editor-Series
        Handle:personhandle::1:1
}

