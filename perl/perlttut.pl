#!/bin/perl
use feature "say";

my $guess = 0;
my $randNumber = rand(10).Int;
do {
	say "Guess a Number 1-100";
	
	$guess = <STDIN>;
} while $guess != $randNumber;

say "You Guesed $randNumber"