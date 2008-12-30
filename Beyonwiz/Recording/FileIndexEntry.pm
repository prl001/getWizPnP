package Beyonwiz::Recording::FileIndexEntry;

=head1 NAME

    use Beyonwiz::Recording::FileIndexEntry;

=head1 SYNOPSIS

Represents an entry in the Beyonwiz recordings index..

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::FileIndexEntry->new($name, $fullPath, [$makeSortTitle]) >>

Create a new Beyonwiz recording index entry object.
C<$name> is the default name of the recording.
C<$fullPath> is the full path of the recording.
This is the right-hand part of a C<index.txt> entry
for a recording. The last segment of this path
is not used when constructing a URL or a file path (for local recordings).
C<$makeSortTitle> is a function reference that
takes a single string argument, and
its return value is used to construct 
C<< $ie->sortTitle([$val]); >>.
It should transform its input string to the form used
for comparisons when sorting.

Normally constructed from the Beyonwiz recording index by
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>.

=item C<< $ie->name([$val]); >>

Returns (sets) the default name of the recording.
This is the left-hand part of a C<index.txt> entry
for a recording.

=item C<< $ie->fullPath([$val]); >>

Returns (sets) the full path of the recording.
This is the right-hand part of a C<index.txt> entry
for a recording. The last segment of this path
is not used when constructing a file path.

=item C<< $ie->extractDetails; >>

Extracts the remaining information fields for the index
entry from C<< $ie->name([$val]); >>.
Called automatically from the constructor.

=item C<< $ie->path([$val]); >>

Returns (sets) path part of the recording file path.

=item C<< $ie->title([$val]); >>

Returns (sets) the program title.
Constructed automatically from C<$val> when
C<< $ie->name([$val]); >>
sets the recording name.
This title is similar to, but not identical with,
the title saved in the recording header file.

=item C<< $ie->sortTitle([$val]); >>

Returns (sets) a sorting value for C<< $ie->title([$val]); >>.
Constructed automatically as
C<< $ie->makeSortTitle($ie->title); >>
when
C<< $ie->name([$val]); >>
sets the recording name.

=item C<< $ie->folder([$val]); >>

Returns (sets) the name of the recording folder on the Beyonwiz.
Constructed automatically from C<$val> when
C<< $ie->name([$val]); >>
sets the recording name.

=item C<< $ie->sortFolder([$val]); >>

Returns (sets) a sorting value for C<< $ie->folder([$val]); >>.
Constructed automatically
as C<< lc $ie->folder([$val]); >>
when
C<< $ie->name([$val]); >>
sets the recording name
or
C<< $ie->path([$val]); >>
sets the recording path.

=item C<< $ie->time([$val]); >>

Returns (sets) the recording start time as a Unix
I<time(2)> value.
Constructed automatically from C<$val> when
C<< $ie->name([$val]); >>
sets the recording name.

=item C<< $ie->makeSortTitle([$val]); >>

Returns (sets) the function used to construct
C<< $ie->sortTitle([$val]); >>
when
C<< $ie->name([$val]); >>
sets the recording name.

=back

=head1 PREREQUISITES

Uses packages:
C<URI::Escape>,
C<FileIndexEntry>.

=cut

use warnings;
use strict;

use URI::Escape;
use File::Basename;

our @ISA = qw( Beyonwiz::Recording::IndexEntry );

my $accessorsDone;

sub new() {
    my ($class, $name, $path, $makeSortTitle) = @_;
    $class = ref($class) if(ref($class));

    my %fields = (
    );

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %fields);
	$accessorsDone = 1;
    }

    my $self = Beyonwiz::Recording::IndexEntry->new($name, $path);

    $self = {
	%$self,
	%fields,
    };

    bless $self, $class;

    $self->fullPath($path);

    return $self;
}

sub fullPath($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{fullPath};
    if(@_ == 2) {
	$self->{fullPath} = $val;
	my $path = dirname($val);
	$path = '' if($path eq '.');
	$self->path($path);
    }
    return $ret;
}

1;
