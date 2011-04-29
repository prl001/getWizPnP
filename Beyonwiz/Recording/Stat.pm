package Beyonwiz::Recording::Stat;

=head1 NAME

    use Beyonwiz::Recording::Stat;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording stat file.
The purpose of the stat file isn't really known.

=head1 CONSTANTS

=over

=item C<STAT>

The stat url path component for the Beyonwiz (C<stat>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Stat->new($accessor, $name, $path) >>

Create a new Beyonwiz recording file index object.
C<$accessor> is a reference to a
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>
used to carry out the media file access functions in
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>.
C<$path> is the path to the source recording folder in C<$name>, and can be a
file system path or a URL depending on the type of C<$accessor>.

=item C<< $s->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $s->fileName([$val]); >>

Returns (sets) the name of the stat file.

=item C<< $s->beyonwizFileName([$val]); >>

Returns (sets) the name of the stat file in the source.

=item C<< $s->recordingEndOffset([$val]); >>

Returns (sets) the logical file offset of the end of the recording
as stred in the stat file.

=item C<< $s->size; >>

Returns the size of the last decoded stat file.

=item C<< $s->load; >>

Loads the stat data from the C<stat> file, depending on which
id present in the recording.

=item C<< $s->valid; >>

Returns true if the last C<< $i->load; >>
or C<< $t->reconstruct($targetLen); >> succeeded.

=item C<< $t->reconstruct($targetLen); >>

Attempts to reconstruct the I<stat>.

C<$targetLen> is the size of the recorded data (or the best estimate if not
known exactly).

Sets C<< $t->valid; >> and
C<< $t->reconstructed; >> to true if the reconsruction succeeded
(even partially), otherwise sets it to C<undef>.

=item C<< $s->reconstructed([$val]); >>

Returns (sets) a flag marking that the object represents a reconstructed
file, and the file should be encoded from the object rather than being
copied from the source.

Reset whenever C<< $s->valid; >> is reset.
Set when C<< $t->reconstruct($targetLen); >> succeeds.

=item C<< $s->decode($hdr_data); >>

Load the contents of C<$s> by decoding the C<stat> file data in
C<$hdr_data>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::StatEntry>|Beyonwiz::Recording::StatEntry>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<File::Basename>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<File::Spec::Functions>.

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
use File::Spec::Functions qw(!path);

use constant STAT  => 'stat';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(STAT STAT_SIZE );

use constant STAT_FMT       => '@44 V V';
use constant STAT_SIZE      => 96;

my @statNames = (STAT, 'STAT', 'ST', 'st', 'St', 'AT', 'At', 'at',
		'fsck0000.ren', 'FSCK0000.REN');

my %statLookup = (
    map { $_  => STAT } @statNames
);

my $accessorsDone;

sub new() {
    my ($class, $accessor, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor           => $accessor,
	name               => $name,
	path	           => $path,
	fileName           => undef,
	beyonwizFileName   => undef,
	recordingEndOffset => undef,
	unknown            => undef,
	valid              => undef,
	reconstructed      => undef,
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return $self;
}

sub size() {
    my ($self) = @_;
    return $self->{size};
}

sub valid() {
    my ($self) = @_;
    return defined $self->{valid};
}

sub load($) {
    my ($self) = @_;
    foreach my $t (@statNames) {
	if($self->path =~ /\.(tv|rad)wiz$/) {
	    my $stat_data = $self->accessor->readFile(
					$self->path, $t
				);

	    if(defined $stat_data) {
		$self->decodeStat($stat_data);
		if($self->valid) {
		    $self->fileName($statLookup{$t});
		    $self->beyonwizFileName($t);
		    return;
		}
	    }
	}
    }
}

sub reconstruct($$) {
    my ($self, $targetLen) = @_;
    $self->{size} = 0;
    $self->recordingEndOffset($targetLen);
    $self->unknown(0);
    $self->{valid} = 1;
    $self->{reconstructed} = 1;
}

sub decodeStat($$) {
    my ($self, $hdr_data) = @_;
    
    $self->{reconstructed} = undef;
    $self->{size} = 0;

    if(defined $hdr_data
    && length($hdr_data) == STAT_SIZE) {
	$self->{size} = length $hdr_data;
	my ($sz0, $sz1) = unpack STAT_FMT, $hdr_data;
	$self->recordingEndOffset(($sz1 << 32) | $sz0);
	$self->{valid} = 1;
    } else {
	$self->{valid} = undef;
    }
}

sub encodeStat($) {
    my ($self) = @_;
    my $sz = $self->recordingEndOffset;
    my $hdrData = pack STAT_FMT, (
			$self->recordingEndOffset & 0xffffffff,
			($self->recordingEndOffset >> 32) & 0xffffffff
		    );
    $hdrData = "\0" x (STAT_SIZE - length $hdrData);
    $self->size(length $hdrData);
    return $hdrData;
}

1;

