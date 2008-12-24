package Beyonwiz::Recording::HTTPIndex;

=head1 NAME

    use Beyonwiz::Recording::HTTPIndex;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording file index via HTTP.

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::HTTPIndex->new($base) >>

Create a new Beyonwiz recording index object.
C<$base> is the base URL for the Beyonwiz device.

=item C<< $i->base([$val]); >>

Returns (sets) the device base URL.

=item C<< $i->url([$val]); >>

Returns (sets) the index URL.

=item C<< $i->load; >>

Load the index from the Beyonwiz.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>,
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
L<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<File::Basename>.

=head1 BUGS

Uses a fixed value for the path name of the index, rather than deriving
it from I<locationURL> in
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>.

=cut

use warnings;
use strict;

use Beyonwiz::Recording::Index qw(INDEX);
use Beyonwiz::Recording::IndexEntry;
use LWP::Simple;
use URI;
use URI::Escape;
use File::Basename;

our @ISA = qw( Beyonwiz::Recording::Index );

my $accessorsDone;

sub new() {
    my ($class, $base) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	base    => $base,
	url     => undef,
    );

    my $self = Beyonwiz::Recording::Index->new;

    $self = {
	%$self,
	%fields,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    bless $self, $class;

    $self->url($self->base->clone);
    $self->url->path(uri_escape(INDEX));

    return $self;
}

sub uriPathEscape($) {
    my ($path) = @_;
    return uri_escape($path, "^A-Za-z0-9\-_.!~*'()/");
}

sub load($) {
    my ($self) = @_;

    @{$self->entries} = ();


    $self->decode(get($self->url));

    $self->valid or die "Fetch of ", $self->url, " failed\n";

    foreach my $ent (@{$self->entries}) {
	$ent->path(uriPathEscape $ent->path);
    }
    return $self->nentries;
}

1;
