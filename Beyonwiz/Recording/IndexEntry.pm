package Beyonwiz::Recording::IndexEntry;

=head1 SYNOPSIS

    use Beyonwiz::Recording::IndexEntry;


=head1 SYNOPSIS

Represents an entry in the Beyonwiz recordings index..

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::IndexEntry->new($name, $path) >>

Create a new Beyonwiz recording index entry object.
C<$name> is the default name of the recording.
C<$path> is the path part of the recording URL.

Normally constructed from the Beyonwiz recording index by
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>.

=item C<< $ie->name([$val]); >>

Returns (sets) the default name of the recording.

=item C<< $ie->path([$val]); >>

Returns (sets) path part of the recording URL.

=cut

use warnings;
use strict;

sub new($$$) {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	name => $name,
	path => $path,
    };
    return bless $self, $class;
}

sub name($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{name};
    $self->{name} = $val if(@_ == 2);
    return $ret;
}

sub path($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{path};
    $self->{path} = $val if(@_ == 2);
    return $ret;
}

1;
