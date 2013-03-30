#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use File::Spec::Functions qw(splitpath catdir canonpath splitdir);

sub editStream($$$$&) {
    my ($in, $inmode, $out, $outmode, $editor) = @_;
    my $to_stdout = !defined($out) || !defined($outmode);

    open IN, $inmode, $in or die "$0: Can't open $in - $!\n";
    open OUT, $outmode, $out or die "$0: Can't open $out - $!\n"
	if(!$to_stdout);
    while(<IN>) {
	my $do_print = 1;
	if(defined($editor)) {
	    $do_print = &$editor();
	}
	if($do_print) {
	    if($to_stdout) {
		print $_;
	    } else {
		print OUT $_;
	    }
	}
    }
    close IN;
    close OUT if(!$to_stdout);
}

foreach my $d (qw/doc html/) {
    mkdir $d or die "$0: make directory $d - $!\n" unless(-d $d);
}

my $index = catdir(qw(html index.html));

open INDEX, '>', $index or die "$0: Can't create $index - $!\n";;

my $podpath='--podpath='
	   . join ':', '.', 'Beyonwiz', catdir(qw(Beyonwiz Recording));

# Header for index.html

print INDEX << '_EOF'
<html>
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <title>getWizPnP documentation</title>
<link rev="made" href="mailto:Peter.Lamb@dit.csiro.au">
</head>
<body>
  <h1>getWizPnP documentation</h1>
  <dir>
_EOF
;

close INDEX;

foreach my $i (@ARGV) {

    if($i !~ /\.p[lm]$/) {
	warn "$0: $i not recognised as Perl source, skipped\n";
	next;
    }

    my ($v, $d, $j) = splitpath($i);

    $d = '.' if($d eq '');
    $d = catdir($d); # trim any trailing '/' or '\' portably
    $j =~ s/\.p[ml]$//;

    my @dirs = splitdir(canonpath($d));
    my @dots;
    if(@dirs == 1 && $dirs[0] eq '.') {
        @dots = @dirs;
    } else {
        @dots = ('..') x @dirs;
    }
    my $dots = catdir(@dots);

    my $title;
    if(@dirs == 1 && $dots[0] eq '.') {
	$title = $j;
    } else {
	$title = join '::', @dirs, $j;
    }

    print $title, "\n";

    my $h = catdir('html', $d);
    mkdir $h or die "$0: make directory $h - $!\n" unless(-d $h);

    # Extract the synopsis line for index.html

    editStream(
	$i, '<', $index, '>>',
	sub {
	    if(/=head1 NAME/../=head1 SYNOPSIS/) {
		s/use //;
		s/^[ 	]*//;
		s/[ 	]*\$//;
		s/;$//;
		my $href = join '/', splitdir($d), "$j.html";
		if(/^[^=[:space:]]/) {
		    s,(.*),    <li><a href="$href">$1</li>,;
		    return 1;
		}
	    }
	    return 0;
	});

    my $htmlroot = catdir('..', $dots, 'html');
    my $outfile = catdir('html', @dirs, "$j.html");

    editStream(
	"pod2html --htmlroot=$htmlroot --podroot=. $podpath --htmldir=."
	. " --header --title=$title"
	. " --infile=$i --outfile=$outfile",
	'-|', undef, undef, undef);

    # Add a line to index.html

    # Convert the Perl POD markup to plain text with DOS line separators

    editStream("pod2text --loose $i", '-|', catdir('doc', "$j.txt"), '>',
		sub { s/\n/\r\n/ if(!/\r\n$/); return 1; } );

}

# Header for index.html

open INDEX, '>>', $index or die "$0: Can't append to $index - $!\n";;

print INDEX << '_EOF'
  </dir>
</body>
</html>
_EOF
;

close INDEX;

# Tidy up

unlink qw/pod2htmd.tmp pod2htmi.tmp/;
