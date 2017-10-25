# package to display in HTML templates hashes...

package s2htm;

require Exporter;


@ISA = qw( Exporter );

@EXPORT = qw(
      HTMLstart HTMLend
      DBList DBListPager );

BEGIN {
}


sub DBUniShow {
    my $t = shift;
    $res = "\n<li>";
    foreach $k ( keys %$t) {
       $res .= "<b>$k</b>: $t->{$k}<br>";
    }
    return $res;
}

sub DBList {

 use sql;
 use repsql;

  my ( $SQLH, $fromhit, $maxhits, $how, $type ) = @_;
#  my ( $type );

  $hits = 0 ;

  print '<ul>';
  %doc = getnexthash ($SQLH, $fromhit-1) ;
  while (%doc) {
#      print "..";
      if ($type eq 'paper' ) {
         print &DBPaperShow ( \%doc, $how );
      } elsif ($type eq 'series' ) {
         print &DBListSeries ( \%doc, $how );
      } elsif ($type eq 'archive' ) {
         print &DBListArchive ( \%doc, $how );
      } else {
 # to insert here corresponding routines for other templates-types
         print &DBUniShow( \%doc);
      }
      $hits ++;

      if ($hits == $maxhits) {
         $nexthit = $fromhit+$maxhits;
         print '</ul>';
         return $nexthit;
      }
  } continue {
      %doc = getnexthash ($SQLH) ;
  }
  print '</ul>';
  return $hits;
}

sub DBListPager {
  my ( $SQLH, $SQLRecs, $in, $max,  $type ) = @_;

  $fromhit = $in->{'fromhit'} || 1;
  $maxhits = $max;
  $how = $in->{'how'};

  $nhit = DBList ( $SQLH, $fromhit, $maxhits, $how, $type ) ;

  if ( $SQLRecs <= ($fromhit + $maxhits-1) ) {
     return 0;
  } else {
     print '<hr>';
     return $nhit;
     ;
  }
}


sub HTMLstart {
   my ( $title, $bodyset ) = @_;
   # Print a title
   $res =
  "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">\n<HTML><HEAD><TITLE>\n\t$title\n</TITLE></HEAD>".
  "<BODY $bodyset BGCOLOR=\"#FFFFFF\">\n";

}

sub HTMLend {
   my $res =
 "\n<hr><ADDRESS>".
 "<a href=\"http://gretel.econ.surrey.ac.uk/~ivan/\">Ivan Kurmanov</a>,\n ".
 "<a href=\"mailto:I.Kurmanov\@surrey.ac.uk\">I.Kurmanov\@surrey.ac.uk</a>\n".
 "</ADDRESS></BODY></HTML>\n";
}




1;


