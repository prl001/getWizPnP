package Beyonwiz::Recording::HTTPTrunc;

=head1 NAME

    use Beyonwiz::Recording::HTTPTrunc;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording trunc file.
The trunc file is used to describe exactly which parts of the
0000, 0001, etc. files are included in the viewable recording.

=head1 CONSTANTS

=over

=item C<TRUNC>

The trunc url path component for the beyonwiz (C<trunc>).

=back

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::HTTPTrunc->new($name, $base, $path) >>

Create a new Beyonwiz recording file index object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>).
C<$base> is the base URL for the Beyonwiz device.
C<$path> is the path part of the recording URL (usually
the path in the recording index).

=item C<< $t->base([$val]); >>

Returns (sets) the device base URL.

=item C<< $t->path([$val]); >>

Returns (sets) the path part of the recording URL.

=item C<< $t->url([$val]); >>

Returns (sets) the recording URL.

=item C<< $t->load; >>

Load the trunc file from the Beyonwiz.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<File::Basename>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

Uses a fixed value for the path name of the index, rather than deriving
it from I<locationURL> in L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>.

=cut

use warnings;
use strict;
use bignum;

use File::Basename;
use LWP::Simple;
use URI;
use URI::Escape;
use Beyonwiz::Recording::Trunc qw(TRUNC);

our @ISA = qw( Beyonwiz::Recording::Trunc );

my $accessorsDone;

sub new() {
    my ($class, $name, $base, $path) = @_;
    $class = ref($class) if(ref($class));
    my %fields = (
	base      => $base,
	path      => $path,
	url       => undef,
    );

   my $self = Beyonwiz::Recording::Trunc->new($name);

    $self = {
	%$self,
	%fields,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;
}

sub load() {
    my ($self) = @_;
    my $hdr_data;
    
    @{$self->entries} = ();
    $self->{size} = 0;

    my $url = $self->base->clone;

    $url->path($self->path . '/' . uri_escape(TRUNC));

    my $trunc_data = get($url);
    $self->decode($trunc_data);

    if($self->valid) {
	$self->url($url);
    } else {
	$self->url(undef);
	warn "Can't get file index for ", $self->name, "\n";
    }
}

1;

