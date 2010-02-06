package Beyonwiz::Recording::Trunc;

=head1 NAME

    use Beyonwiz::Recording::Trunc;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording trunc file.
The trunc file is used to describe exactly which parts of the
0000, 0001, etc. files are included in the viewable recording.

=head1 CONSTANTS

=over

=item C<TRUNC>

The trunc url path component for the Beyonwiz (C<trunc>).

=item C<WMMETA>

The wmmeta url path component for the Beyonwiz (C<wmmeta>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Trunc->new($name) >>

Create a new Beyonwiz recording file index object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see

=item C<< $t->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $t->fileName([$val]); >>

Returns (sets) the name of the trunc file.

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

=item C<< $t->valid; >>

Returns true if the last C<< $i->load; >> succeeded.

=item C<< $t->decode($hdr_data); >>

Load the contents of C<$t> by decoding the C<trunc> file data in
C<$hdr_data>.

=item C<< $t->truncStart($offset) >>

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

use Beyonwiz::Recording::TruncEntry;
use File::Basename;
use LWP::Simple;
use URI;
use URI::Escape;
use File::Spec::Functions qw(!path);

use constant TRUNC  => 'trunc';
use constant WMMETA => 'wmmeta';

use constant FULLFILE => (1 << 16); # Impossible flag in a real trunc file

use constant WMMAGIC => 'WzMF';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(TRUNC WMMETA FULLFILE);

my $accessorsDone;

sub new() {
    my ($class, $accessor, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor  => $accessor,
	name      => $name,
	fileName  => undef,
	path	  => $path,
	size      => 0,
	entries   => [],
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

sub valid() {
    my ($self) = @_;
    return defined $self->{valid};
}

sub truncStart($$) {
    my ($self, $offset) = @_;
    my $startFileOff = 0;
    for(my $i = 0; $i < $self->nentries; $i++) {
	my $endFileOff = $startFileOff + ${$self->entries}[$i]->size;
	return ($i, $offset - $startFileOff) if($endFileOff > $offset);
	$startFileOff = $endFileOff;
    }
    return ($self->nentries, $offset - $startFileOff);
}

sub makeFileTrunc($) {
    my ($self) = @_;

    my $fileTrunc = Beyonwiz::Recording::Trunc->new($self->name, $self->path);
    my $lastfile = -1;
    $fileTrunc->size($self->size);
    $fileTrunc->fileName($self->fileName);

    foreach my $tr (@{$self->entries}) {
	my $sz = $tr->offset+$tr->size;
	if($lastfile != $tr->fileNum) {
	    $fileTrunc->addEntry(Beyonwiz::Recording::TruncEntry->new(
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
                                $self->name, $self->path);
    my $lastfile = -1;
    $fileTrunc->size($self->size);
    $fileTrunc->fileName($self->fileName);

    foreach my $tr (@{$self->entries}) {
	if($lastfile != $tr->fileNum) {
	    my $fn = sprintf '%04d', $tr->fileNum;
	    $fn = catfile($self->path, $fn);
	    my $document_length = (stat $fn)[7];
	    if(defined $document_length) {
		$fileTrunc->addEntry(Beyonwiz::Recording::TruncEntry->new(
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

sub load() {
    my ($self) = @_;
    foreach my $t (TRUNC, WMMETA) {
	if($t eq TRUNC && $self->path =~ /\.(tv|rad)wiz$/
	|| $t eq WMMETA && $self->path =~ /\.wiz$/) {
	    my $trunc_data = $self->accessor->readFile(
					$self->path, $t
				);

	    if(defined $trunc_data) {
		if($t eq TRUNC) {
		    $self->decodeTrunc($trunc_data);
		} else {
		    $self->decodeWmmeta($trunc_data);
		}
		if($self->valid) {
		    $self->fileName($t);
		    return;
		}
	    }
	}
    }
    my ($size, $time) = $self->accessor->fileLenTime($self->path);
    if(defined($size)) {
	$self->addEntry(Beyonwiz::Recording::TruncEntry->new(
				0,
				0,
				FULLFILE,
				0,
				$size
			    )
		);
	$self->fileName('');
	$self->{valid} = 1;
	return;
    }

    $self->{valid} = undef;
    @{$self->entries} = ();
    $self->{size} = 0;

    $self->fileName(undef);
}

sub decodeTrunc($$) {
    my ($self, $hdr_data) = @_;
    
    @{$self->entries} = ();
    $self->{size} = 0;

    if(defined $hdr_data
    && length($hdr_data) % 24 == 0) {
	$self->{size} = length $hdr_data;
	my @trunc = unpack '(V2 v v V2 V)*', $hdr_data;
	while(my @t = splice(@trunc, 0, 7)) {
	    $self->addEntry(Beyonwiz::Recording::TruncEntry->new(
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
}

sub decodeWmmeta($$) {
    my ($self, $hdr_data) = @_;
    
    @{$self->entries} = ();
    $self->{size} = 0;
    $self->{valid} = undef;

    if(defined $hdr_data
    && length($hdr_data) >= 4096
    && (length($hdr_data) - 4096) % 16 == 0) {
	$self->{size} = length $hdr_data;
	my ($magic, $unknown, $len, @wmmeta) = unpack 'Z4 V2 @4096 (V4)*',
						$hdr_data;
	if($magic eq WMMAGIC) {
	    for(my $n = 0; my @t = splice(@wmmeta, 0, 4) and $n < $len; $n++) {
		$self->addEntry(Beyonwiz::Recording::TruncEntry->new(
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

1;

