# package to display in HTML templates hashes...

package s_tpl;

require Exporter;

@ISA = qw( Exporter );
@EXPORT = qw( shortTemplate fullTemplate );

$AbstrLength = 150;


sub shortTemplate {
    (%te) = (@_);

    $type = $te{'TYPE'};
    $handle = $te{'handle'};
    $id = $te{'ID'};

    print "<ul><li>";

    if ( $type eq 'paper'  ) {

       $serid = $te{'serid'};
       print "<b>$te{'title'}</b> - by <i>$te{'authors'}</i>.\n";
       print "<br>Series: <a href=\"/adnetec-cgi-bin/s-0?type=s&id=$serid\">" .
         "<b>$serid</b></a>";
       print "<br>Handle: <b>$handle</b>";

    } elsif ( $type eq 'series' ) {

       $arcid = $te{'arcid'};
       print "<b>$te{'name'}</b> - by <i>$te{'editor'}</i>.\n";
       print "<br>Archive: <a href=\"/adnetec-cgi-bin/s-0?type=a&id=$arcid\">" .
        "<b>$arcid</b></a>";
       print "<br>Handle: <b>$handle</b>";

    } elsif ( $type eq 'archive' ) {

       print "<b>$te{'name'}</b> - by <i>$te{'publisher'}</i>.\n";
       print "<br>Handle: <b>$handle</b>";

    } else {

      print "unrecognized:";
      foreach $k (keys %te) {
        print "<li> $k: <b>$te{$k}</B>\n";
      }

    }
    print "</ul>";

}



sub fullTemplate {
    %te = shift;

    $type = $te{'template-type'};
    $handle = $te{'handle'};
    $id = $te{'_rowid'};

    print "<CENTER>\n";

    if ( $type =~ /paper/i  ) {
       print "<b>$te{title}</b> - by <i>$te{author}</i> (p: $id).\n";

    } elsif ( $type =~ /series/i ) {
       print "<b>$te{name}</b> - by <i>$te{publisher}</i> (s: $id).\n";

    } elsif ( $type =~ /archive/i ) {
       print "<b>$te{name}</b> - by <i>$te{publisher}</i> (a: $id).\n";
    }

    print "</CENTER>\n";

}

