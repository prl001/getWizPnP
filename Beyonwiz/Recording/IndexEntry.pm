package Beyonwiz::Recording::IndexEntry;

use strict;

sub new($$$) {
    my ($class, $name, $path) = @_;
    $class = ref($class) if(ref($class));
    my $self = {
	name => $name,
	path => $path,
    };
    return bless $self, $class;
}

sub name($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{name};
    $self->{name} = $val if(@_ == 2);
    return $ret;
}

sub path($;$) {
    my ($self, $val) = @_;
    my $ret = $self->{path};
    $self->{path} = $val if(@_ == 2);
    return $ret;
}

1;
