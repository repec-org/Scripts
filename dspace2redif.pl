#!/usr/bin/perl
# massage AgeconSearch OAI  XML files
# based on OAIsloan2.pl written by Kit Baum
use LWP::Simple;
use Text::Wrap;
use strict;
use warnings;
# we're expecting these to be set in a config file
use vars qw( $ArchiveDir $OutDir $OutFile $Series $URLRoot $OAIGateway $OAISeries $UTFBOM $UTFconvert $BaseURL);

print "dspace2redif v2.0.0\n";
print "Stuart Yeates, 2015/07/18\n";
print "Christian Zimmermann, 2009/01/07\n";
print "based on a script by Kit Baum\n\n";
print "If this is your first time using it, please check results to see whether they correspond to expectations. In particular, check the Creation-Date: field. Some adjustment may be necessary.\n\n\n";

# debug character encodings
my $debug=1;

# load the config file
if ($ARGV[0] eq '') {
    require("dspace2redif.conf") or die "Could not find configuration file dspace2redif.conf";
} else {
    require("$ARGV[0]") or die "Could not find configuration file $ARGV[0]";
}

my @Elements=split(/:/,$Series,3);
$OutDir="$ArchiveDir/$Elements[2]";
unless(-e $OutDir){print "creating $OutDir\n"; mkdir $OutDir or die "Could not create directory $OutDir\n"}

$OutFile="$OutDir/$Elements[2].rdf";

unless(substr($URLRoot,-1,1) eq '/'){$URLRoot.='/'}

if (!$BaseURL || $BaseURL eq "") {
    $BaseURL="$OAIGateway/request";
}

my $nrtem=0;
my $ntem=0;
my $chunkflag=0;
my $resumptionToken="";
while($chunkflag==0){
    my $nrtem=0;
    my $URL;

    if ($resumptionToken eq "") {
	$URL="$BaseURL?verb=ListRecords&metadataPrefix=oai_dc&set=$OAISeries";
    } else {
	$URL="$BaseURL?verb=ListRecords&resumptionToken=$resumptionToken";
    }
    my $str=get($URL);
    
    $str =~ s/\n/ /ig;
    $str =~ s/\r/ /ig;
    $str =~ s/&amp;/&/ig;
    $str =~ s/&quot;/"/ig;
    $str =~ s/&#8216;/'/ig;
    $str =~ s/&#8217;/'/ig;
    $str =~ s/&#8242;/'/ig;
    $str =~ s/&#8220;/"/ig; #' (emacs)
    $str =~ s/&#8221;/"/ig;
    $str =~ s/&#8211;/:/ig;
    $str =~ s/&#8212;/--/ig;
    $str =~ s/^.+?<record>//;
    
    (my @str) = split("<record>",$str);
    my $nstr=@str;
    ($resumptionToken) = ($str =~ /<resumptionToken[^>]*>\s*([^<]+)\s*</);
    print "$nstr items read... from \"$URL\"\n";

    # die without touching the output file if there are no elements
    if ($nstr == 0){ die "No elements in OAI feed \"$OAIGateway\", aborting"}

    if (!fileno(OUTA)) {
	open(OUTA,">$OutFile") or die "Could not open $OutFile for output";
	if($UTFBOM eq 'yes'){print OUTA "\xEF\xBB\xBF"}
    }
    
    foreach $str (@str) {
        if ($UTFconvert eq 'yes') {
	    $str=&utf8_to_iso8859($str);
	}
	if ($str =~ /status="deleted"/) {
	    print "Skipping deleted record. \n" 
	} else { 
	    
	    if ($str =~ /<dc:identifier\/>/){ print "Empty dc:identifier seen. Please fix.\nRecord is:\"\"$str\"\"\n" }
	    my ($url) = ($str =~ /<identifier>\s*([^<]*)\s*</ig);
	    my $uniq=(split(/\//,$url))[-1];
	    $url=$URLRoot.$uniq;
	    
	    my ($ser,$id) ;
	    ($ser,$id) = ($str =~ /<dc:relation>(.+?);(.+?)<\/dc/);
	    
	    #the docs say that YYYY-MM and YYYY-MM-DD are acceptable but they seem to be silently 
	    #dropped, so just use YYYY
	    if ($str =~ /<dc:date\/>/) { print "Empty dc:date seen. Please fix. $url\n" }
	    if ($str =~ /<dc:date>\s*</) { print "Empty dc:date seen. Please fix. $url\n" }
	    my (@credt) = ($str =~ /<dc:date>\s*[^<]*([0-9][0-9][0-9][0-9])[^<]*\s*<\/dc/g);
	    my $pubyr = $credt[-1];
	    
	    if ($str =~ /<dc:title\/>/){ print "Empty dc:title seen. Please fix. $url\n" }
	    if ($str =~ /<dc:title>\s*</){ print "Empty dc:title seen. Please fix. $url\n" }
	    my ($ti) = ($str =~ /<dc:title>\s*([^<]+)\s*<\/dc/);
	    
	    if ($str =~ /<dc:creator\/>/){ print "Empty dc:creator seen. Please fix. $url\n" }
	    if ($str =~ /<dc:creator>\s*</){ print "Empty dc:creator seen. Please fix. $url\n" }
	    my (@au) = ($str =~ /<dc:creator>\s*([^<]+)\s*<\/dc/ig);
	    my $nau = @au;
	    if ($nau == 0) {
		(@au) = ($str =~ /<dc:contributor>([^<]*)<\/dc/ig);
	    }
	    $nau = @au;
	    
	    if ($str =~ /<dc:description\/>/){ print "Empty dc:description seen. Please fix. $url\n" }
	    if ($str =~ /<dc:description>\s*</){ print "Empty dc:description seen. Please fix. $url\n" }
	    my ($ab) = ($str =~ /<dc:description>([^<]*)<\/dc/);

	    my (@kw) = ($str =~ /<dc:subject>([^<]*)<\/dc/ig);
	    my $nkw = @kw;
	    
	    #only generate the template if we have the required data
	    if ($uniq && $ti && $nau>0 ) {
		print OUTA "\nTemplate-Type: ReDIF-Paper 1.0\n";
		if ($id) { print OUTA "Series: $id\n"; };	
		print OUTA "Title: $ti\n";
		
		foreach my $i (@au) {print OUTA "Author-Name: $i \n"}
		if ($ab && length $ab > 40) {
		    print OUTA  "Abstract:\n";
		    print OUTA  wrap(" "," ",$ab);
		    print OUTA "\n";
		}
		if ($nkw > 0) {
		    print OUTA "Keywords: ";
		    foreach my $k (@kw) {
			print OUTA "$k, ";
		    }
		    print OUTA "\n";
		}
		print OUTA "Number: $uniq \n";
		print OUTA "Creation-Date: $pubyr \n";
		print OUTA "File-URL: $url \n";
		print OUTA "Handle: RePEc:$Elements[1]:$Elements[2]:$uniq \n";
		$nrtem++;
	    } else {
		print "skipping $url, couldn't find uniq id, title and an author\n";
	    }
	}
    }
    if (! $resumptionToken && $resumptionToken eq ""){
	$chunkflag=1;
    }
    $ntem+=$nrtem;
}

close OUTA;
print " \n$ntem templates processed and saved in $OutFile \n\n";

exit;
sub utf8_to_iso8859
{
# Converts UTF-8 as long as it just encodes ISO-8859-1
	my ($str) = @_;
	my $retval;
	my @chars = split(//,$str);
	while (@chars) {
		my $ch = shift(@chars);
		my $val1 = ord($ch);
		if($val1 >= 128) {
			# XXXX could add error checking to make sure there's a char available.
			my $val2 = ord(shift(@chars));
			$val1 = ($val1 & 31) << 6;
			$val2 &= 63;
			my $realch = chr($val1 + $val2);
#			print STDERR "Hello: converted upper ascii char $realch(", ord($realch), ")\n" if ($debug);
			$retval .= $realch;
		} else {
			$retval .= $ch;
		}
	}
	return $retval;
}




__END__
