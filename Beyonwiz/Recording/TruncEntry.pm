package Beyonwiz::Recording::TruncEntry;

=head1 SYNOPSIS

    use Beyonwiz::Recording::TruncEntry;


=head1 SYNOPSIS

Represents an entry in the Beyonwiz trunc file.

=head1 METHODS

=over

=item C<< Beyonwiz::Recording::TruncEntry->new($wizOffset, $fileNum, $flags, $offset, $size) >>

Create a new Beyonwiz recording index entry object.
C<$wizOffset> logical byte offset of the entry in the recording
(C<bignum>).
C<$filenum> is the numbered recording file that the entry refers to.
The file name is this number printed in C<printf> C<%04d> format.
C<$flags> - flags for the entry - unknown purpose.
C<$offset> - offset of the recording data chunk in the file (C<bignum>).
C<$size> - size of the recodding data chunk in the file.
More than one L<C<Beyonwiz::Recording::Index>|Beyonwiz::Recording::TruncEntry>
can refer to a given file.

Normally constructed from the Beyonwiz trunc file by
L<C<Beyonwiz::Recording::Trunc>|Beyonwiz::Recording::Trunc>.

=item C<< $te->wizOffset([$val]); >>

Returns (sets) the logical byte offset of the entry in the recording.

=item C<< $te->filenum([$val]); >>

Returns (sets) the numbered recording file that the entry refers to.

=item C<< $te->flags([$val]); >>

Returns (sets) the flags for the entry - unknown purpose.

=item C<< $te->offset([$val]); >>

Returns (sets) the offset of the recording data chunk in the file (C<bignum>).

=item C<< $te->size([$val]); >>

Returns (sets) the size of the recodding data chunk in the file.

=back

=head1 BUGS

Uses C<bignum> for 64-bit integers, even when the underlying
Perl integers are 64 bits.

=cut

use warnings;
use strict;

sub new($$$) {
    my ($class, $wizOffset, $fileNum, $flags, $offset, $size) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	wizOffset => $wizOffset,
	fileNum   => $fileNum,
	flags     => $flags,
	offset    => $offset,
	size      => $size,
    };
    return bless $self, $class;
}

sub wizOffset($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{wizOffset};
    $self->{wizOffset} = $val if(@_ == 2);
    return $ret;
}

sub fileNum($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{fileNum};
    $self->{fileNum} = $val if(@_ == 2);
    return $ret;
}

sub flags($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{flags};
    $self->{flags} = $val if(@_ == 2);
    return $ret;
}

sub offset($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{offset};
    $self->{offset} = $val if(@_ == 2);
    return $ret;
}

sub size($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{size};
    $self->{size} = $val if(@_ == 2);
    return $ret;
}


1;
