package Beyonwiz::Recording::Index;

=head1 NAME

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

=item C<< Beyonwiz::Recording::Index->new >>

Create a new Beyonwiz recording index object.

=item C<< $i->entries([$val]); >>

Returns (sets) the list of
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>
objects in the index as an array reference.

=item C<< $i->nentries; >>

Returns the number of index entries.

=item C<< $i->valid; >>

Returns true if the last C<< $i->load; >> succeeded.

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

sub new($) {
    my ($class) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	valid   =>  undef,
	entries => [],
    };
    bless $self, $class;

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return $self;
}

sub nentries() {
    my ($self, $val) = @_;
    return scalar(@{$self->entries});
}

sub valid() {
    my ($self) = @_;
    return defined $self->{valid};
}

sub decode($$) {
    my ($self, $index_data) = @_;

    @{$self->entries} = ();

    if(defined $index_data) {
	foreach my $rec (split /\r?\n/, $index_data) {
	    my @parts = split /\|/, $rec;
	    if(@parts == 2) {
		push @{$self->entries},
		    Beyonwiz::Recording::IndexEntry->new(
			    $parts[0], dirname $parts[1]);
	    } else {
		warn "Unrecognised index entry: $rec\n";
	    }
	}
	$self->{valid} = 1;
    } else {
	$self->{valid} = undef;
    }
    return $self->nentries;
}

1;
