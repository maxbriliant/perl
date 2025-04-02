#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);

my $password = "123Polizei";
my $length = length($password);
my $hidden = "*" x $length;

say "Password: $hidden";

if ($password =~ m/[a-z]/) {

	say "x \t Lowercase Included!";
}
if ($password =~ m/[A-Z]/) {

	say "x \t Uppercase Included!";
}
if ($password =~ m/^.{8,}$/) {
	say "x \t Min. Length of 8 Characters!"; 
}
if ($password =~ m/d*/ ) {
		say "x \t Number Included!\n";	
}

