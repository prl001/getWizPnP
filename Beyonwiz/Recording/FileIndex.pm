package Beyonwiz::Recording::FileIndex;

=head1 NAME

    use Beyonwiz::Recording::FileIndex;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording file index via HTTP.

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::FileIndex->new($base [, $makeSortTitle]) >>

Create a new Beyonwiz recording index object.
C<$base> is the base URL for the Beyonwiz device.
C<$makeSortTitle> takes a single string argument, and
its return value is used to construct 
C<< Beyonwiz::Recording::IndexEntry::sortTitle; >>.
It should transform its input string to the form used
for comparisons when sorting
(for example in C<< $i->entries([$val]); >>)

=item C<< $i->path([$val]); >>

Returns (sets) the recording path.

=item C<< $i->load; >>

Load the index from the Beyonwiz.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Header>|Beyonwiz::Recording::Header>,
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>,
L<C<Beyonwiz::Recording::IndexEntry>|Beyonwiz::Recording::IndexEntry>,
L<C<Beyonwiz::Utils>|Beyonwiz::Utils>,
C<LWP::Simple>,
C<URI>,
C<URI::Escape>,
C<File::Spec::Functions>.

=head1 BUGS

Uses a fixed value for the path name of the index, rather than deriving
it from I<locationURL> in
L<C<Beyonwiz::WizPnP>|Beyonwiz::WizPnP>.

=cut

use warnings;
use strict;

use Beyonwiz::Recording::Header qw(TVHDR RADHDR);
use Beyonwiz::Recording::Trunc qw(TRUNC);
use Beyonwiz::Recording::Index;
use Beyonwiz::Recording::IndexEntry;
use LWP::Simple;
use URI;
use URI::Escape;
use File::Spec::Functions qw(!path);

our @ISA = qw( Beyonwiz::Recording::Index );

my $accessorsDone;

sub new($$;$) {
    my ($class, $path, $makeSortTitle) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
	path    => $path,
    );

    my $self = Beyonwiz::Recording::Index->new($makeSortTitle);

    $self = {
	%$self,
	%fields,
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    return bless $self, $class;
}

my @monNames = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

sub load($) {
    my ($self) = @_;

    @{$self->entries} = ();

    my $index_data = '';

    opendir DIR, $self->path or die "Can't find ", $self->path, ": $!\n";
    foreach my $ent (grep { -d catfile($self->path, $_)
			       && (    -f catfile($self->path, $_, TVHDR)
			            || -f catfile($self->path, $_, RADHDR)
				  )
			       && -f catfile($self->path, $_, TRUNC)
			} readdir(DIR)) {
	# Fake up index.txt lines;
	my $name = $ent;
	$name =~ s/\.tvwiz$//;
	my $mtime = (stat catfile($self->path, $ent))[9];
	my ($min,$hour,$mday,$mon,$year) = (localtime)[1..5];
	$name .= sprintf ' %s.%d.%d_%2d.%2d',
			    $monNames[$mon], $mday, $year+1900, $hour, $min;
	$index_data .= $name . '|'
	            . catfile($self->path, $ent, $ent . '.tvwizts') . "\n";
    }
    closedir DIR;

    $self->decode($index_data);

    $self->valid or die "Fetch of ", $self->path, " failed\n";

    return $self->nentries;
}

1;
