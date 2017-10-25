package pretty_print;

use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( &pretty_print );

$level = -1; # Level of indentation

sub pretty_print {
    my $var;
    foreach $var (@_) {
        if (ref ($var)) {
            print_ref($var);
        } else {
            print_scalar($var);
        }
    }
    $number = undef;
}

sub print_scalar {
    ++$level;
    if (not defined $_[0]) { $_[0] = "(undef)"; }
    print_indented ($_[0]);
    --$level;
}

sub print_ref {
    my $r = $_[0];
    if (exists ($already_seen{$r})) {
	++$level;
        print_indented ("$r (Seen earlier)");
	--$level;
        return;
    } else {
        $already_seen{$r}=1;
    }
    my $ref_type = ref($r);
    if ($ref_type eq "ARRAY") {
        print_array($r);
    } elsif ($ref_type eq "SCALAR") {
        print "Ref -> $r";
        print_scalar($$r);
    } elsif ($ref_type eq "HASH") {
        print_hash($r);
    } elsif ($ref_type eq "REF") {
        ++$level;
        print_indented("Ref -> ($r)");
        print_ref($$r);
        --$level;
    } else {
        ++$level;
        print_indented ("$ref_type class object:");
	my $val = sprintf ( "%s", $r );
	if ( $val =~ /^[^=]+=([A-Z]+)/ ) {
	    my $ref_type = $1;
	    if ($ref_type eq "ARRAY") {
		print_array( $r );
	    } elsif ($ref_type eq "SCALAR") {
		print "Ref -> $r";
		print_scalar( $$r );
	    } elsif ($ref_type eq "HASH") {
		print_hash( $r );
	    } else {
#		print "sorry, can't display that";
	    }
	} else {
	    ++$level;
	    print_indented ( " { sorry, can't display that }" );
	    --$level;
	}
        --$level;
    }
}

sub print_array {
    my ($r_array) = @_;
    ++$level;
    print_indented ("[   # $r_array");
	my $c = 0;
    foreach $var (@$r_array) {
	$number = $c;
	if (not defined ($var) ) {
	    print_scalar("(undef)");
	} elsif (ref ($var)) {
            print_ref($var);
        } else {
            print_scalar("'$var'");
        }
	$c++;
    }
    $number = undef;
    print_indented ("]");
    --$level;
}

sub print_hash {
    my($r_hash) = @_;
    my($key, $val);
    ++$level; 
    $number = undef;
    print_indented ("{   # $r_hash");
    while (($key, $val) = each %$r_hash) {
#        $val = ($val ? $val : '""');
        ++$level;
	$number = undef;
	if (not defined $val) {
            print_indented ("$key => (undef)");
	} elsif (ref ($val)) {
            print_indented ("$key => ");
            print_ref($val);
        } else {
            print_indented ("$key => '$val'");
        }
        --$level;
	$number = undef;
    }
    print_indented ("}");
    --$level;
}

sub print_indented {
    $spaces = "   " x $level ;
    if (defined $number) { $spaces .= "$number "; }
    print "${spaces}$_[0]\n";
}



1;








