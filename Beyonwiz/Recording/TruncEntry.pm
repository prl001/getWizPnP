package Beyonwiz::Recording::TruncEntry;

=head1 NAME

    use Beyonwiz::Recording::TruncEntry;

=head1 SYNOPSIS

Represents an entry in the Beyonwiz trunc file.

=head1 CONSTANTS

=over

=item C<FULLFILE>

If set in C<< $te->flags >>, then the entry represents the whole
media file or recording.
If this is set, it should be on a singleton entry in a
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>
object, and the name of the associated file
is the path to the recording (C<< $te->path >>);
C<< $te->fileName >> should be ignored.

=back



=head1 METHODS

=over

=item C<< Beyonwiz::Recording::TruncEntry->new($accessor, $path, $wizOffset, $fileNum, $flags, $offset, $size) >>

Create a new Beyonwiz recording index entry object.
C<$accessor> is a reference to a
L<C<Beyonwiz::Recording::Accessor>|Beyonwiz::Recording::Accessor>
used to carry out the media file access functions in
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>.
C<$path> is the path to the source recording folder, and can be a
file system path or a URL depending on the type of C<$accessor>.
C<$wizOffset> logical byte offset of the entry in the recording
(C<bignum>).
C<$fileNum> is the numbered recording file that the entry refers to.
The file name is this number printed in C<printf> C<%04u> format.
C<$flags> - flags for the entry - unknown purpose.
C<$offset> - offset of the recording data chunk in the file (C<bignum>).
C<$size> - size of the recording data chunk in the file.
More than one L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::TruncEntry>
can refer to a given file.

Normally constructed from the Beyonwiz trunc file by
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>.

=item C<< $t->accessor([$val]); >>

Returns (sets) the media file accessor object reference.

=item C<< $te->path([$val]); >>

Returns (sets) the source recording folder name.

=item C<< $te->wizOffset([$val]); >>

Returns (sets) the logical byte offset of the entry in the recording.

=item C<< $te->fileNum([$val]); >>

Returns (sets) the numbered recording file that the entry refers to.

=item C<< $te->flags([$val]); >>

Returns (sets) the flags for the entry - unknown purpose.

=item C<< $te->offset([$val]); >>

Returns (sets) the offset of the recording data chunk in the file (C<bignum>).

=item C<< $te->size([$val]); >>

Returns (sets) the size of the recording data chunk in the file.

=item C<< $te->accessor([$val]); >>

Returns (sets) the media file accessor object reference.

=item C<< $te->fileName; >>

Returns the name of the numbered recording file that the entry refers to.
Returns an emptr string if the entry is flagged with C<FULLFILE>
(the entry is for a single-file media file).

=item C<< $te->fileLenTime([$file]) >>

Return the tuple I<($len, $modifyTime)> for the recording data file.
The modify time is a Unix timestamp (seconds since 00:00:00) Jan 1 1970 UTC).
If the entry is flagged with C<FULLFILE>, the time returned is for
C<$te->path>, otherwise for the file named 
Returns C<undef> if the data can't be found
(access denied or file not found).

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>.

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

=cut

use warnings;
use strict;

use bignum;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(FULLFILE);

use constant FULLFILE => (1 << 16); # Impossible flag in a real trunc file

my $accessorsDone;

sub new($$$) {
    my ($class, $accessor, $path, $wizOffset, $fileNum, $flags, $offset, $size) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor  => $accessor,
	path	  => $path,
	wizOffset => $wizOffset,
	fileNum   => $fileNum,
	flags     => $flags,
	offset    => $offset,
	size      => $size,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;
}

sub fileLenTime($) {
    my ($self) = @_;
    if($self->flags & FULLFILE) {
	return $self->accessor->fileLenTime($self->path);
    }
    return $self->accessor->fileLenTime($self->path, $self->fileName);
}

sub fileName($) {
    my ($self) = @_;
    return ($self->flags & FULLFILE) ? '' : sprintf("%04u", $self->fileNum);
}

1;
