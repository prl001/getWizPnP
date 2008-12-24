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

The trunc url path component for the beyonwiz (C<trunc>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Trunc->new($name) >>

Create a new Beyonwiz recording file index object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see

=item C<< $t->name([$val]); >>

Returns (sets) the default recording name.

=item C<< $t->entries([$val]); >>

Returns (sets) the array reference containing the
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
objects in for the recording.

=item C<< $t->nentries; >>

Returns the number of entries in C<< $t->entries >>.

=item C<< $t->size; >>

Returns the size of the last decoded trunc file.

=item C<< $t->recordingSize; >>

Returns the sum of all the I<size> entries in the
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
objects in for the recording.

=item C<< $t->valid; >>

Returns true if the last C<< $i->load; >> succeeded.

=item C<< $t->decode($hdr_data); >>

Load the contents of C<$t> by decoding the C<trunc> file data in
C<$hdr_data>.

=item C<< $t->completeTruncs( $offset) >>

Return the number of complete
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>s
up to the given C<$offset> in the recording.

=item C<< $t->makeFileTrunc; >>

Return a new
L<C<Beyonwiz::Recording::HTTPTrunc>|Beyonwiz::Recording::HTTPTrunc>
with a single
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>
for each file to be downloaded.
The sizes and offsets are not particularly meaningful.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::TruncEntry>|Beyonwiz::Recording::TruncEntry>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<File::Basename>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>.

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

use constant TRUNC => 'trunc';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(TRUNC);

my $accessorsDone;

sub new() {
    my ($class, $name) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	name      => $name,
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
    my $size;
    $nents = $self->nentries if(!defined $nents);
    foreach my $tr (@{$self->entries}[0..$nents-1]) {
	$size += $tr->size;
    }
    return $size;
}

sub valid() {
    my ($self) = @_;
    return defined $self->{valid};
}

sub completeTruncs($$) {
    my ($self, $offset) = @_;
    my $fileOff = 0;
    for(my $i = 0; $i < $self->nentries; $i++) {
	$fileOff += ${$self->entries}[$i]->size;
	return $i if($fileOff >= $offset);
    }
    return $self->nentries;
}

sub makeFileTrunc($) {
    my ($self) = @_;

    my $fileTrunc = Beyonwiz::Recording::Trunc->new($self->name);
    my $lastfile = -1;

    foreach my $tr (@{$self->entries}) {
	if($lastfile != $tr->fileNum) {
	    $fileTrunc->addEntry(Beyonwiz::Recording::TruncEntry->new(
				    $tr->wizOffset,
				    $tr->fileNum,
				    $tr->flags,
				    $tr->offset,
				    $tr->size
				)
			    );
	} else {
	    my $ent = $fileTrunc->entries->[$fileTrunc->nentries-1];
	    $ent->size($ent->size+$tr->size);
	}
	$lastfile = $tr->fileNum;
    }
    return $fileTrunc;
}

sub decode($$) {
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

1;

