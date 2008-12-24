package Beyonwiz::Recording::Trunc;

=head1 SYNOPSIS

    use Beyonwiz::Recording::Trunc;


=head1 SYNOPSIS

Provides access to the Beyonwiz recording trunc file.
The trunc file is used to describe exactly which parts of the
0000, 0001, etc. files are included in the viewable recording.

=head1 CONSTANTS

=over

=item C<TRUNC>

The trunc url path component for the beyonwiz (C<trunc>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Trunc->new($name, $base, $path) >>

Create a new Beyonwiz recording index object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>).
C<$base> is the base URL for the Beyonwiz device.
C<$path> is the path part of the recording URL (usually
the path in the recording index).

=item C<< $t->base([$val]); >>

Returns (sets) the device base URL.

=item C<< $t->path([$val]); >>

Returns (sets) the recording URL.

=item C<< $t->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $t->entries([$val]); >>

Returns (sets) the array reference containing the
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
objects in for the recording.

=item C<< $t->size; >>

Returns the size of the last loaded trunc file.

=item C<< $t->recording_size; >>

Returns the sum of all the I<size> entries in the
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
objects in for the recording.

=item C<< $i->valid; >>

Returns true if the last C<< $i->load; >> succeeded.

=item C<< $i->load; >>

Load the trunc file from the Beyonwiz.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>,
C<File::Basename>,
C<LWP::Simple>,
C<URI::Escape>,
C<URI>.

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
use Beyonwiz::Recording::TruncEntry;

use constant TRUNC => 'trunc';

sub new() {
    my ($class, $name, $base, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	base      => $base,
	path      => $path,
	url       => undef,
	name      => $name,
	size      => 0,
	entries   => [],
    };
    bless $self, $class;

    return $self;
}

sub base($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{base};
    $self->{base} = $val if(@_ == 2);
    return $ret;
}

sub path($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{path};
    $self->{path} = $val if(@_ == 2);
    return $ret;
}

sub url($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{url};
    $self->{url} = $val if(@_ == 2);
    return $ret;
}

sub name($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{name};
    $self->{name} = $val if(@_ == 2);
    return $ret;
}

sub entries($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{entries};
    $self->{entries} = $val if(@_ == 2);
    return $ret;
}

sub nentries() {
    my ($self) = @_;
    return scalar @{$self->entries};
}

sub size() {
    my ($self) = @_;
    return $self->{size};
}

sub recording_size($) {
    my ($self) = @_;
    my $size;
    foreach my $tr (@{$self->entries}) {
	$size += $tr->size;
    }
    return $size;
}

sub valid() {
    my ($self) = @_;
    return defined $self->url;
}

sub load() {
    my ($self) = @_;
    my $hdr_data;
    
    @{$self->entries} = ();
    $self->{size} = 0;

    my $url = $self->base->clone;

    $url->path($self->path . '/' . uri_escape(TRUNC));

    $hdr_data = get($url);

    if(defined $hdr_data) {
	$self->url($url);
	$self->{size} = length $hdr_data;
	my @trunc = unpack '(V2 v v V2 V)*', $hdr_data;
	while(my @t = splice(@trunc,0,7)) {
	    push @{$self->entries}, Beyonwiz::Recording::TruncEntry->new(
		    ($t[1] << 32) | $t[0],
		    $t[2],
		    $t[3],
		    ($t[5] << 32) | $t[4],
		    $t[6]);
	}
	return;
    }

    $self->url(undef);

    warn "Can't get file index for ", $self->name, "\n";
}

1;

