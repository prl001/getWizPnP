package Beyonwiz::Recording::IndexEntry;

=head1 NAME

    use Beyonwiz::Recording::IndexEntry;

=head1 SYNOPSIS

Represents an entry in the Beyonwiz recordings index..

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::IndexEntry->new($name, $path, [$makeSortTitle]) >>

Create a new Beyonwiz recording index entry object.
C<$name> is the default name of the recording.
C<$path> is the path of the recording.
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

=item C<< $ie->extractDetails; >>

Extracts the remaining information fields for the index
entry from C<< $ie->name([$val]); >>.
Called automatically from the constructor.

=item C<< $ie->path([$val]); >>

Returns (sets) path part of the recording URL.

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
C<URI::Escape>.

=cut

use warnings;
use strict;

use URI::Escape;

my $accessorsDone;

sub new($$$) {
    my ($class, $accessor, $name, $path, $makeSortTitle) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	accessor	=> $accessor,
	name		=> $name,
	path		=> $path,
	title		=> undef,
	folder		=> undef,
	sortTitle	=> undef,
	sortFolder	=> undef,
	time		=> undef,
	makeSortTitle	=> $makeSortTitle
    };

    unless($accessorsDone) {
	Beyonwiz::Utils::makeAccessors(__PACKAGE__, keys %$self);
	$accessorsDone = 1;
    }

    bless $self, $class;

    $self->extractDetails;

    return $self;
}

my %monthNum = (
    Jan =>  1,
    Feb =>  2,
    Mar =>  3,
    Apr =>  4,
    May =>  5,
    Jun =>  6,
    Jul =>  7,
    Aug =>  8,
    Sep =>  9,
    Oct => 10,
    Nov => 11,
    Dec => 12,
);

sub extractDetails() {
    my ($self) = @_;
    my $title;
    my $folder;
    my $time;
    my $val = $self->name;
    if(defined($val) && $val ne '') {
	# Beyonwiz index name entry
	$val =~ m{
		    ^
		    (.*\/)?		# folder part of path ($1)
		    (.*)		# title part of path ($2)
		    (?:\s+|_)		# White space or an '_'
		    ([[:alpha:]]{3})	# Month name ($3)
		    \.(\d+)		# .day ($4)
		    \.(\d+)		# .year ($5)
		    _(\d+)\.(\d+)	# _hh.mm ($6, $7)
		    $
		}x;
	if(defined($2) && defined($3) && defined($4)
	&& defined($5) && defined($6) && defined($7)
	&& defined($monthNum{$3})) {
	    $folder = $1;
	    $title = $2;
	    $time = sprintf '%04d%02d%02dT%02d%02d',
					$5, $monthNum{$3}, $4, $6, $7;
	    $self->time($time);
	} else {
	    $val =~ /^(.*\/)?(.*)$/;
	    $folder = $1;
	    $title = $2;
	    $time = '19700101T0000';
	    $self->time($time)
		if(!defined($self->time));
	}
	$self->title(defined($title) ? $title : $val)
	    if(!defined($self->title) || defined($title));
	$self->folder(defined($folder) ? substr($folder, 0, -1) : '')
	    if(!defined($self->folder) || defined($folder));
    }
}

sub folder($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{folder};
    if(@_ == 2) {
	$self->{folder} = $val;
	$self->sortFolder(lc $val);
    }
    return $ret;
}

sub title($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{title};
    if(@_ == 2) {
	$self->{title} = $val;
	$self->sortTitle($self->makeSortTitle
				? &{$self->makeSortTitle}($val)
				: $val);
    }
    return $ret;
}

1;
