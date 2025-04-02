#!/usr/bin/perl
use strict;
use warnings;

my @martialArts = ( "Karate", "Age 7", 
					"Wing-Chun", "Age 19", 
					"Aikido", "Age 24", 
					"Sistema", "Age 27",);

my %martialArts = @martialArts;

print "Mastery will be gained at ".(substr($martialArts{"Wing-Chun"}, -3) +
									substr($martialArts{"Aikido"},    -3))."\n";

