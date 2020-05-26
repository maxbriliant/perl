#!/usr/bin/perl
#wifiCollect.pl
#MxBit2020

#use strict;
use feature 'say';

my $wifi = `iw dev | awk '\$1=="Interface"{print \$2}'`;
chop($wifi);

my @essid;
my @scan = `iwlist '$wifi' scan`;
my @essidDirty = grep(/ESSID/, @scan);


foreach (@essidDirty) {
	$_=~ s/^[\s\n\t]+//;
	push(@essid,$_); 
}

chomp @essid;
for (0..$#essid) {@essid[$_] = split '\n', $	essid[$_]}
say for @essid;
