#!/usr/bin/perl

use strict;
use warnings;

use Beyonwiz::WizPnP;

$| = 1;

die "Usage: $0 script|direct delay repeats\n"
    if(@ARGV != 3 && ($ARGV[0] ne 'script' || $ARGV[0] ne 'direct'));

my ($how, $delay, $repeats) = @ARGV;

foreach my $n (1..$repeats) {
    sleep($delay);
    print ($n % 10 == 0 ? "$n\n" : '.');
    if($how eq 'script') {
	system './doLookup.pl', $n;
    } else {
	my $pnp = Beyonwiz::WizPnP->new;
	#Beyonwiz::WizPnP::debug(1);

	$pnp->maxDevs(1);

	$pnp->search;
	print "\nSearch $n failed\n" if($pnp->ndevices == 0);
    }
}
print "\n" if($repeats % 10 != 0);
