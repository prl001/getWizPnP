package Beyonwiz::Recording::IndexEntry;

=head1 NAME

    use Beyonwiz::Recording::IndexEntry;

=head1 SYNOPSIS

Represents an entry in the Beyonwiz recordings index..

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::IndexEntry->new($name, $path) >>

Create a new Beyonwiz recording index entry object.
C<$name> is the default name of the recording.
C<$path> is the path part of the recording URL or the file system path.

Normally constructed from the Beyonwiz recording index by
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>.

=item C<< $ie->name([$val]); >>

Returns (sets) the default name of the recording.

=item C<< $ie->path([$val]); >>

Returns (sets) path part of the recording URL.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>.

=cut

use warnings;
use strict;

my $accessorsDone;

sub new($$$) {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	name => $name,
	path => $path,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;
}

1;
