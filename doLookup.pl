#!/usr/bin/perl

use strict;
use warnings;

use Beyonwiz::WizPnP;

die "Usage: $0 testnum\n" if(@ARGV != 1);

my ($n) = @ARGV;

my $pnp = Beyonwiz::WizPnP->new;
#Beyonwiz::WizPnP::debug(1);

$pnp->maxDevs(1);

$pnp->search;
print "\nSearch $n failed\n" if($pnp->ndevices == 0);
