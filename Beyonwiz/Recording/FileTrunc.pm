package Beyonwiz::Recording::FileTrunc;

=head1 NAME

    use Beyonwiz::Recording::FileTrunc;

=head1 SYNOPSIS

Provides access to the Beyonwiz recording trunc file.
The trunc file is used to describe exactly which parts of the
0000, 0001, etc. files are included in the viewable recording.

=head1 CONSTANTS

=over

=item C<TRUNC>

The trunc url path component for the beyonwiz (C<trunc>).

=back

=head1 SUPERCLASS

Inherits from
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::FileTrunc->new($name, $path) >>

Create a new Beyonwiz recording file index object.
C<$name> is the default name of the recording (usually
the name in the Beyonwiz recording index, see
L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::Index>).
C<$path> is the path part of the recording URL (usually
the path in the recording index).

=item C<< $t->path([$val]); >>

Returns (sets) the recording path.

=item C<< $t->load; >>

Load the trunc file from the Beyonwiz.

=item C<< $t->fileTruncFromDir; >>

Return a new
L<C<Beyonwiz::Recording::FileTrunc>|Beyonwiz::Recording::FileTrunc>
that reflect the files in the the directory pointed to by
C<< $t->path([$val]) >>.

=back

=head1 PREREQUISITES

Uses packages:
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>,
L<C<Beyonwiz::Recording::Recording>|Beyonwiz::Recording::Recording>,
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

use Beyonwiz::Recording::Trunc qw(TRUNC);
use Beyonwiz::Recording::Recording qw(addDir);
use File::Basename;
use LWP::Simple;
use URI;
use URI::Escape;
use File::Spec::Functions qw(!path);

our @ISA = qw( Beyonwiz::Recording::Trunc );

my $accessorsDone;

sub new() {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my %fields = (
	path      => $path,
    );

   my $self = Beyonwiz::Recording::Trunc->new($name);

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

sub fileTruncFromDir($) {
    my ($self) = @_;

    my $hFileTrunc = Beyonwiz::Recording::FileTrunc->new(
				$self->name, $self->path);

    foreach my $tr (@{$self->entries}) {
	my $fn = sprintf '%04d', $tr->fileNum;
	$fn = catfile($self->path, $fn);
	my $document_length = (stat $fn)[7];
	if(defined $document_length) {
	    $hFileTrunc->addEntry(Beyonwiz::Recording::TruncEntry->new(
				    $tr->wizOffset,
				    $tr->fileNum,
				    $tr->flags,
				    0,
				    $document_length
				)
			    );
	}
    }
    return $hFileTrunc;
}

sub load() {
    my ($self) = @_;
    my $hdr_data;
    
    @{$self->entries} = ();
    $self->{size} = 0;

    my $fn = addDir($self->path, TRUNC);
    if(open TR, '<', $fn) {
	my $tr_data;
	my $nread;
	my $totread = 0;
	my $status = RC_OK;
	while($nread = sysread TR, $tr_data, 4096, $totread) {
	    $totread += $nread;
	}
	if(defined $nread) {
	    $self->decode($tr_data);
	} else {
	    $self->decode('');
	    warn "Trunc read error on ", $self->path, ": $!\n";
	    $status = RC_BAD_REQUEST;
	}
	close TR;
    } else {
	$self->decode('');
	warn "Can't get file index forXX ", $self->name, ", $fn\n";
    }
}

1;

