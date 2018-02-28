package Beyonwiz::Recording::Index;

my $Copyright = 'Copyright 2008-2018 Peter Lamb.
See accompanying LICENSE file for redistribution conditions.';

=head1 NAME

    use Beyonwiz::Recording::Index;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording file index.

=head1 CONSTANTS

=over

=item C<INDEX>

The name of the recording index file on the Beyonwiz (C<index.txt>).

=back

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::Index->new([$makeSortTitle]); >>

Create a new Beyonwiz recording index object.

C<$makeSortTitle> is a function reference passed as the same paramter into
C<< Beyonwiz::Recording::IndexEntry->new($name, $path, [$makeSortTitle]); >>
for any instances of
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
created by instances of this object,
by C<< $i->decode($index_data); >>
for example.
C<$makeSortTitle> takes a single string argument, and
its return value is used to construct 
C<< Beyonwiz::Recording::IndexEntry::sortTitle; >>.
It should transform its input string to the form used
for comparisons when sorting
(for example in C<< $i->entries([$val]); >>)

=item C<< $i->entries([$val]); >>

Returns (sets) the list of
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
objects in the index as an array reference.

=item C<< $i->nentries; >>

Returns the number of index entries.

=item C<< $i->valid; >>

Returns true if the last C<< $i->load; >> succeeded.

=item C<< $i->sort($makeSortTitle); >>

Sorts the values returned by C<< $i->entries([$val]); >>
I<n situ> and returns them as a list
(not a list reference as in C<< $i->entries([$val]); >>).
C<$makeSortTitle> is a function reference that will be called
directly by Perl's C<sort> function, with two
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
references as its arguments.

=item C<< $i->newEntry($name, $path, $makeSortTitle); >>

Create a new
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
of the appropriate derived type for the index.

This method is abstract and must be overridden in
derived classes.

=item C<< $i->decode($index_data); >>

Decode the binary index data.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<File::Basename>.

=head1 BUGS

Uses a fixed value for the path name of the index, rather than deriving
it from I<locationURL> in
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>.

=cut

use warnings;
use strict;

use Beyonwiz::Recording::IndexEntry;
use LWP::Simple;
use URI;
use URI::Escape;
use File::Basename;

use constant INDEX => 'index.txt';

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(INDEX);

my $accessorsDone;

sub new($;$) {
    my ($class, $accessor, $makeSortTitle) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor	=> $accessor,
	valid		=>  undef,
	makeSortTitle	=> $makeSortTitle,
	entries		=> [],
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return $self;
}

sub nentries($$) {
    my ($self, $val) = @_;
    return scalar(@{$self->entries});
}

sub valid($) {
    my ($self) = @_;
    return defined $self->{valid};
}

sub sort($$) {
    my ($self, $makeSortTitle) = @_;
    return @{$self->entries} = sort $makeSortTitle @{$self->entries};
}

sub load($) {
    my ($self) = @_;

    @{$self->entries} = ();


    $self->decode($self->accessor->loadIndex());

    $self->valid or die "Fetch of index for ",
			    $self->accessor->base, " failed\n";

    return $self->nentries;
}

sub decode($$) {
    my ($self, $index_data) = @_;

    @{$self->entries} = ();

    if(defined $index_data) {
	foreach my $rec (@$index_data) {
	    push @{$self->entries},
		Beyonwiz::Recording::IndexEntry->new(
			$self->accessor,
			$rec->[0], $rec->[1],
			$self->makeSortTitle);
	}
	$self->{valid} = 1;
    } else {
	$self->{valid} = undef;
    }
    return $self->nentries;
}

1;
