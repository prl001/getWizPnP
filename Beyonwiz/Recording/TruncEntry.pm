package Beyonwiz::Recording::TruncEntry;

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
