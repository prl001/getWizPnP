package Beyonwiz::Recording::Index;

=head1 SYNOPSIS

    use Beyonwiz::Recording::Index;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording file index.

=head1 CONSTANTS

=over

=item C<INDEX>

The index url path for the beyonwiz (C<index.txt>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Index->new($base) >>

Create a new Beyonwiz recording index object.
C<$base> is the base URL for the Beyonwiz device.

=item C<< $i->base([$val]); >>

Returns (sets) the device base URL.

=item C<< $i->url([$val]); >>

Returns (sets) the index URL.

=item C<< $i->entries([$val]); >>

Returns (sets) the list of
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
objects in the index as an array reference.

=item C<< $i->nentries; >>

Returns the number of index entries.

=item C<< $i->valid; >>

Returns true if the last C<< $i->load; >> succeeded.

=item C<< $i->load; >>

Load the index from the Beyonwiz.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>,
C<File::Basename>,
C<LWP::Simple>,
C<URI::Escape>,
C<URI>.

=head1 BUGS

Uses a fixed value for the path name of the index, rather than deriving
it from I<locationURL> in
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>.

=cut

use warnings;
use strict;

use LWP::Simple;
use URI;
use URI::Escape;
use File::Basename;
use Beyonwiz::Recording::IndexEntry;

use constant INDEX => 'index.txt';

sub new() {
    my ($class, $base) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base    => $base,
	url     => undef,
	entries => [],
    };
    bless $self, $class;

    $self->url($self->base->clone);
    $self->url->path(uri_escape(INDEX));

    return $self;
}

sub base($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{base};
    $self->{base} = $val if(@_ == 2);
    return $ret;
}

sub url($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{url};
    $self->{url} = $val if(@_ == 2);
    return $ret;
}

sub entries($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{entries};
    $self->{entries} = $val if(@_ == 2);
    return $ret;
}

sub nentries() {
    my ($self, $val) = @_;
    return scalar(@{$self->entries});
}

sub valid() {
    my ($self) = @_;
    return defined $self->url;
}

sub uri_path_escape($) {
    my ($path) = @_;
    return uri_escape($path, "^A-Za-z0-9\-_.!~*'()/");
}

sub load($) {
    my ($self) = @_;

    @{$self->entries} = ();

    my $recs = get($self->url) or die "Fetch of ", $self->url, " failed\n";

    foreach my $rec (split /\n/, $recs) {
	my @parts = split /\|/, $rec;
	if(@parts == 2) {
	    push @{$self->entries},
		Beyonwiz::Recording::IndexEntry->new(
			$parts[0], uri_path_escape(dirname $parts[1]));

	} else {
	    warn "Unrecognised index entry: $rec\n";
	}
    }
    return $self->nentries;
}

1;
