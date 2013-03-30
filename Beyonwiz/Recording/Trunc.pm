package Beyonwiz::Recording::Trunc;

=head1 NAME

    use Beyonwiz::Recording::Trunc;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording I<trunc> file.
The trunc file is used to describe exactly which parts of the
0000, 0001, etc. files are included in the viewable recording.

=head1 CONSTANTS

=over

=item C<TRUNC>

The I<trunc> file name for the Beyonwiz (C<trunc>).

=item C<TRUNC_SIZE_MULT>

The I<trunc> file size should be a multiple of C<TRUNC_SIZE_MULT>.

=item C<WMMETA>

The I<wmmeta> file name for the Beyonwiz (C<wmmeta>).

=item C<WMMETA_SIZE>

The size of  I<wmmeta> file.

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Trunc->new($accessor, $name, $path) >>

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

=item C<< $t->accessor([$val]); >>

Returns (sets) the media file accessor object reference.

=item C<< $t->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $t->path([$val]); >>

Returns (sets) the source recording folder name.

=item C<< $t->fileName([$val]); >>

Returns (sets) the name of the trunc file.

=item C<< $s->beyonwizFileName([$val]); >>

Returns (sets) the name of the trunc file in the source.

=item C<< $t->entries([$val]); >>

Returns (sets) the array reference containing the
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
objects in for the recording.

=item C<< $t->nentries; >>

Returns the number of entries in C<< $t->entries >>.

=item C<< $t->size; >>

Returns the size of the last decoded trunc file.

=item C<< $t->recordingSize([$nents]); >>

Returns the sum of all the I<size> entries in the
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
objects in for the recording.

If C<$nents> is set, returns the size of the first C<$nents> entries
in the table.

=item C<< $t->load; >>

Loads the trunc data from the C<trunc> or C<wmmeta> file, depending on which
is present in the recording or media file.

=item C<< $t->valid; >>

Returns true if the last C<< $i->load; >>
or C<< $t->reconstruct($minScan, $maxScan, $targetLen); >> succeeded.

=item C<< $t->fileLenTime([$file]) >>

Return the tuple I<($len, $modifyTime)> for the trunc file.
The modify time is a Unix timestamp (seconds since 00:00:00) Jan 1 1970 UTC).
If C<$file> is specified, use that as the name of the trunc file,
otherwise use C<$t->beyonwizFileName> for the name of the file.
Returns C<undef> if the data can't be found
(access denied or file not found).

=item C<< $t->reconstruct($minScan, $maxScan, $targetLen); >>

Attempts to reconstruct the I<trunc> data from the recording data file
names and sizes. C<$minScan> and C<$maxScan> are the minimum and maximum
data file names (as integers) for the scan to find the first recording
file name.

C<$targetLen> is a guess at the maximum size of the recording data,
including an allowance for parts of the files that were edited out in the
original trunc file.

Sets C<< $t->valid; >> and
C<< $t->reconstructed; >> to true if the reconsruction succeeded
(even partially), otherwise sets it to C<undef>.

=item C<< $s->reconstructed([$val]); >>

Returns (sets) a flag marking that the object represents a reconstructed
file, and the file should be encoded from the object rather than being
copied from the source.

Reset whenever C<< $s->valid; >> is reset.
Set when C<< $t->reconstruct($targetLen); >> succeeds.

=item C<< $t->decode($hdr_data); >>

Load the contents of C<$t> by decoding the C<trunc> file data in
C<$hdr_data>.

=item C<< $t->encodeTrunc; >>

Returns I<trunc> file data for
C<$t>, ready for writing to a file.
Should only be called if C<$t> represents
a I<trunc> file.

=item C<< $t->encodeWmmeta; >>

Returns I<wmmeta> file data for
C<$t>, ready for writing to a file.
Should only be called if C<$t> represents
a I<wmmeta> file.

=item C<< $t->truncStart($recOffset) >>

Return the location of the logical C<offset> (counting from 0
at the start of the recording) as a (I<truncIndex>, I<fileOffset>)
pair indicating which 
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
contains the position and the corresponding offset into the file.

=item C<< $t->makeFileTrunc; >>

Return a new
L<C<Beyonwiz::Recording::HTTPTrunc>|Beyonwiz::Recording::HTTPTrunc>
with a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
for each file to be downloaded.
The chunk file sizes and offsets are adjusted to have a single trunc
representing the whole file. The C<wizOffset> values are not particularly
meaningful.

=item C<< $t->fileTruncFromDir; >>

Return a new
L<C<Beyonwiz::Recording::FileTrunc>|Beyonwiz::Recording::FileTrunc>
that reflect the files in the the directory pointed to by
C<< $t->path([$val]) >>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>,
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

use Beyonwiz::Recording::TruncEntry qw(FULLFILE);
use File::Basename;
use LWP::Simple;
use URI;
use URI::Escape;
use File::Spec::Functions qw(!path);

use constant TRUNC  => 'trunc';
use constant WMMETA => 'wmmeta';

use constant WMMAGIC => 'WzMF';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(TRUNC WMMETA WMMETA_SIZE TRUNC_SIZE_MULT);

use constant TRUNC_FMT          => 'V2 v v V2 V';
use constant WMMETA_HDR_FMT     => 'Z4 V2';
use constant WMMETA_FMT         => 'V4';
use constant WMMETA_TBL_OFF     => 4096;
use constant WMMETA_TBL_ENT_SZ  => 16;
use constant WMMETA_TBL_SZ      => 512;

use constant TRUNC_SIZE_MULT	=> 24;
use constant WMMETA_SIZE	=> WMMETA_TBL_OFF
					+ WMMETA_TBL_SZ * WMMETA_TBL_ENT_SZ;

my @truncNames = (
    TRUNC,
    WMMETA,
    'Trunc',
    'TRUNC',
);

my %truncLookup = (
    TRUNC,    TRUNC, # Use ',' instead of '=>' to get const interpolation
    'Trunc',  TRUNC,
    'TRUNC',  TRUNC,
    WMMETA,    WMMETA, # Use ',' instead of '=>' to get const interpolation
);

my $accessorsDone;

sub new() {
    my ($class, $accessor, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor          => $accessor,
	name              => $name,
	fileName          => undef,
	beyonwizFileName  => undef,
	path	          => $path,
	valid             => undef,
	reconstructed     => undef,
	size              => 0,
	entries           => [],
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return $self;
}

sub addEntry($$) {
    my ($self, $entry) = @_;
    push @{$self->entries}, $entry;
}

sub nentries() {
    my ($self) = @_;
    return scalar @{$self->entries};
}

sub size() {
    my ($self) = @_;
    return $self->{size};
}

sub recordingSize($;$) {
    my ($self, $nents) = @_;
    my $size = 0;
    $nents = $self->nentries if(@_ <= 1);
    foreach my $tr (@{$self->entries}[0..$nents-1]) {
	$size += $tr->size;
    }
    return $size;
}

sub fileLenTime($$) {
    my ($self, $file) = @_;
    if(@_ >= 2) {
	return $self->accessor->fileLenTime($self->path, $file);
    }
    return $self->accessor->fileLenTime($self->path, $self->beyonwizFileName);
}

sub valid() {
    my ($self) = @_;
    return defined $self->{valid};
}

sub truncStart($$) {
    my ($self, $recOffset) = @_;
    my $startFileOff = 0;
    foreach my $i (0..$self->nentries-1) {
	my $endFileOff = $startFileOff + ${$self->entries}[$i]->size;
	return ($i, $recOffset - $startFileOff)
	    if($endFileOff > $recOffset);
	$startFileOff = $endFileOff;
    }
    return ($self->nentries, $recOffset - $startFileOff);
}

sub makeFileTrunc($) {
    my ($self) = @_;

    my $fileTrunc = Beyonwiz::Recording::Trunc->new(
				$self->accessor, $self->name, $self->path
			    );
    my $lastfile = -1;
    $fileTrunc->size($self->size);
    $fileTrunc->fileName($self->fileName);
    $fileTrunc->beyonwizFileName($self->beyonwizFileName);
    $fileTrunc->reconstructed($self->reconstructed);

    foreach my $tr (@{$self->entries}) {
	my $sz = $tr->offset+$tr->size;
	if($lastfile != $tr->fileNum) {
	    $fileTrunc->addEntry(Beyonwiz::Recording::TruncEntry->new(
				    $tr->accessor,
				    $tr->path,
				    $tr->wizOffset,
				    $tr->fileNum,
				    $tr->flags,
				    0,
				    $sz
				)
			    );
	} else {
	    my $ent = $fileTrunc->entries->[$fileTrunc->nentries-1];
	    $ent->size($sz)
		if($sz > $ent->size);
	}
	$lastfile = $tr->fileNum;
    }
    return $fileTrunc;
}

sub fileTruncFromDir($) {
    my ($self) = @_;

    my $fileTrunc = Beyonwiz::Recording::Trunc->new(
                                $self->accessor, $self->name, $self->path
			    );
    my $lastfile = -1;
    $fileTrunc->size($self->size);
    $fileTrunc->fileName($self->fileName);
    $fileTrunc->beyonwizFileName($self->beyonwizFileName);

    foreach my $tr (@{$self->entries}) {
	if($lastfile != $tr->fileNum) {
	    my $fn = $tr->fileName;
	    $fn = catfile($self->path, $fn);
	    my $document_length = (stat $fn)[7];
	    if(defined $document_length) {
		$fileTrunc->addEntry(Beyonwiz::Recording::TruncEntry->new(
				        $tr->accessor,
				        $tr->path,
					$tr->wizOffset,
					$tr->fileNum,
					$tr->flags,
					0,
					$document_length
				    )
				);
	    }
	}
    }
    return $fileTrunc;
}

sub load($) {
    my ($self) = @_;
    $self->{reconstructed} = undef;

    $self->fileName($truncNames[0]);
    $self->beyonwizFileName($truncNames[0]);

    foreach my $t (@truncNames) {
	my $tfn = $truncLookup{$t};
	if($tfn eq TRUNC && $self->path =~ /\.(tv|rad)wiz$/
	|| $tfn eq WMMETA && $self->path =~ /\.wiz$/) {
	    my $trunc_data = $self->accessor->readFile(
					$self->path, $t
				);
	    if(defined $trunc_data) {
		if($tfn eq TRUNC) {
		    $self->decodeTrunc($trunc_data);
		} else {
		    $self->decodeWmmeta($trunc_data);
		}
		$self->fileName($tfn);
		$self->beyonwizFileName($t);
		return;
	    }
	}
    }
    my ($size, $time) = $self->accessor->fileLenTime($self->path);
    if(defined($size)) {
	$self->addEntry(Beyonwiz::Recording::TruncEntry->new(
				$self->accessor,
				$self->path,
				0,
				0,
				FULLFILE,
				0,
				$size
			    )
		);
	$self->fileName('');
	$self->beyonwizFileName('');
	$self->{valid} = 1;
	$self->{size} = TRUNC_SIZE_MULT;
	return;
    }

    $self->{valid} = undef;
    @{$self->entries} = ();
    $self->{size} = undef;
}

sub reconstruct($$$$) {
    my ($self, $minScan, $maxScan, $targetLen) = @_;
    $self->{valid} = undef;
    $self->{reconstructed} = undef;
    @{$self->entries} = ();
    $self->{size} = 0;
    my ($f, $len, $t);
    my ($recLen, $recOff) = (0, 256*1024);
    my $scannedSize = 0;
    for($f = $minScan; $f <= $maxScan; $f++) {
	my $fn = sprintf '%04u', $f;
	print "Scan for start: $fn\r";
	($len, $t) = $self->accessor->fileLenTime(
				    $self->accessor->joinPaths(
				    		$self->path, $fn
					)
			    );
	last if(defined $len);
    }
    if(defined $len) {
	my $fn = sprintf '%04u', $f;
	print "\nFound start at $fn\n";
	do {
	    if(defined $len) {
		$self->{valid} = 1;
		$self->{reconstructed} = 1;

		$self->addEntry(Beyonwiz::Recording::TruncEntry->new(
				$self->accessor,
				$self->path,
				$recOff,
				$f,
				0,
				0,
				$len
			    )
			);
		$self->{size} += 24;
		$recOff += $len;
		$recLen += $len;
	    }
	    $f++;
	    $fn = sprintf '%04u', $f;
	    print "Check $fn\r";
	    ($len, $t) = $self->accessor->fileLenTime(
					$self->accessor->joinPaths(
							$self->path, $fn
						)
				);
	    $scannedSize += defined($len) ? $len : 32 * 1024 * 1024;
	} until($f > $maxScan || $scannedSize >= $targetLen);
	print "\n";
	$self->fileName(TRUNC); $self->beyonwizFileName(TRUNC);
    }
}

sub decodeTrunc($$) {
    my ($self, $hdr_data) = @_;
    
    @{$self->entries} = ();
    $self->{size} = defined($hdr_data) ? length($hdr_data) : undef;

    if(defined $hdr_data
    && length($hdr_data) % TRUNC_SIZE_MULT == 0) {
	my @trunc = unpack '(V2 v v V2 V)*', $hdr_data;
	for(my $o = 0; $o < $self->{size}; $o += TRUNC_SIZE_MULT) {
	    my @t = unpack TRUNC_FMT, substr $hdr_data, $o, TRUNC_SIZE_MULT;
	    $self->addEntry(Beyonwiz::Recording::TruncEntry->new(
			    $self->accessor,
			    $self->path,
			    ($t[1] << 32) | $t[0],
			    $t[2],
			    $t[3],
			    ($t[5] << 32) | $t[4],
			    $t[6]
			)
		    );
	}
	$self->{valid} = 1;
    } else {
	$self->{valid} = undef;
    }
    $self->{reconstructed} = undef;
}

sub encodeTrunc($) {
    my ($self) = @_;
    my $hdrData;
    foreach my $te (@{$self->entries}) {
	$hdrData .= pack TRUNC_FMT, (
			    $te->wizOffset & 0xffffffff,
			    ($te->wizOffset >> 32) & 0xffffffff,
			    $te->fileNum,
			    $te->flags,
			    $te->offset & 0xffffffff,
			    ($te->offset >> 32) & 0xffffffff,
			    $te->size
			);
    }
    $self->size(length $hdrData);
    return $hdrData;
}

sub decodeWmmeta($$) {
    my ($self, $hdr_data) = @_;
    
    @{$self->entries} = ();
    $self->{size} = defined($hdr_data) ? length $hdr_data : undef;
    $self->{valid} = undef;
    $self->{reconstructed} = undef;

    if(defined $hdr_data
    && length($hdr_data) >= WMMETA_TBL_OFF
    && (length($hdr_data) - WMMETA_TBL_OFF) % WMMETA_TBL_ENT_SZ == 0) {
	$self->{size} = length $hdr_data;
	my ($magic, $unknown, $len) = unpack WMMETA_HDR_FMT, $hdr_data;
	if($magic eq WMMAGIC) {
	    for(my $n = 0; $n < $len; $n++) {
		my @t = unpack WMMETA_FMT,
			substr $hdr_data, WMMETA_TBL_OFF
						+ $n * WMMETA_TBL_ENT_SZ;
		$self->addEntry(Beyonwiz::Recording::TruncEntry->new(
				$self->accessor,
				$self->path,
				($t[1] << 32) | $t[0],
				$t[2],
				0,
				0,
				$t[3]
			    )
			);
	    }
	    $self->{valid} = 1;
	}
    }
}

sub encodeWmmeta($) {
    my ($self) = @_;
    my $hdrData	= pack WMMETA_HDR_FMT, WMMAGIC, 1, $self->nentries;

    foreach my $te (@{$self->entries}) {
	$hdrData .= pack WMMETA_FMT, (
			    $te->wizOffset & 0xffffffff,
			    ($te->wizOffset >> 32) & 0xffffffff,
			    $te->fileNum,
			    $te->size
			);
    }
    $hdrData .= "\0" x ((WMMETA_TBL_SZ - $self->nentries)
				* WMMETA_TBL_ENT_SZ);
    $self->size(length $hdrData);
    return $hdrData;
}

1;
