package Beyonwiz::Utils;

=head1 NAME

    use Beyonwiz::Utils;

=head1 SYNOPSIS

Some utilities that don't belong anywhere else.

=head1 FUNCTIONS

=over

=item C<< makeAccessors($package, @fields) >>

Make accessor methods in a class in C<$package> for the fields listed
in C<@fields>.

If a method of the same name as the field already exists, don't make an
automatic accessor for it.
Because of this, calling I<makeAccessors> multiple times for the same class
and fields is save, but inefficient.

=back

=cut

use strict;
use warnings;
use Carp;

sub makeAccessors($@) {
    my ($package, @fields) = @_;
    my $defs = "\t\t{\n\t\t    package ${package};\n\t\t    use bignum;";
    my $doDefs;
    foreach my $field (@fields) {
	if(!eval("defined(&${package}::${field})")) {
	    $defs .= "
		sub ${field}(\$;\$) {
		    my (\$self, \$val) = \@_;
		    my \$ret = \$self->{$field};
		    \$self->{$field} = \$val if(\@_ == 2);
		    return \$ret;
		}
	    ";
	    $doDefs = 1;
	}
    }
    $defs .= "}";
    if($doDefs) {
	eval $defs;
	carp "$@" if($@);
    }
}

sub isAbstract {
    my ($package, $filename, $line, $subroutine) = caller 1;
    die $package, "::", $subroutine, " is abstract and must be derived from\n";
}

sub tryUse(*@) {
    my ($package, @args) = @_;
    eval "require $package";
    if($@) {
	return 0;
    } else {
	$package->import(@args);
    }
    return 1;
}

1;
