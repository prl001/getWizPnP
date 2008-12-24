package Beyonwiz::Recording::FileHeader;

=head1 NAME

    use Beyonwiz::Recording::FileHeader;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording file header via
HTTP.

=head1 SUPERCLASS

Inherits from L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::FileHeader->new($name, $base, $path) >>

Create a new Beyonwiz recording header object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>).
C<$path> is the path part of the recording filename (usually
the path in the recording index).

=item C<< $h->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $h->path([$val]); >>

Returns (sets) the recording file path part.

=item C<< $h->headerName([$val]); >>

Returns (sets) the name of the header document (path part only).

=item C<< $h->isTV; $h->isRadio; >>

Returns true if C<< $h->valid; >> is true and the recording
is digital TV (resp digital radio).

=item C<< $h->load([$full]) >>

Load the header object from the header file.
The I<offsets> data is only loaded if C<$full> is present and true.
If C<$full> is not set, only 2kB is downloaded,
otherwise 256kB is downloaded.

=item C<< $h->readHdrChunk($offset, $size) >>

Read a chunk of the header file length C<$size> at offset C<$offset>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<File::Spec::Functions>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<POSIX>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

The bugs to do with time are in the Beyonwiz.

=cut


use warnings;
use strict;
use bignum;

use Beyonwiz::Recording::Header qw(TVHDR RADHDR HDR_SIZE);
use Beyonwiz::Utils;
use File::Spec::Functions qw(!path);
use LWP::Simple qw(get $ua);
use URI;
use URI::Escape;
use POSIX;

our @ISA = qw( Beyonwiz::Recording::Header );

my $accessorsDone;

sub new() {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	path       => $path,
	name       => $name,
    );

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %fields);
	$accessorsDone = 1;
    }

    my $self = Beyonwiz::Recording::Header->new;

    $self = {
	%$self,
	%fields,
    };

    return bless $self, $class;
}

sub readHdrChunk($$$) {
    my ($self, $offset, $size) = @_;

    foreach my $h ($self->headerName ? ($self->headerName) : (TVHDR, RADHDR)) {

        my $fn = catfile($self->path, $h);

	if(open HDR, '<', $fn) {
	    my $hdr_data = '';
	    if(sysseek HDR, $offset, SEEK_SET) {
		my $nread = sysread HDR, $hdr_data, $size;
		if(defined($nread) && $nread == $size) {
		    $self->headerName($h);
		    return $hdr_data;
		}
	    }
	    close HDR;
        }
    }
    return '';
}


1;
