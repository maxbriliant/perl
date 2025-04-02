#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize::Chrome;
use Log::Log4perl ':easy';

Log::Log4perl->easy_init($TRACE);

my $mech = WWW::Mechanize::Chrome->new(
        autodie => 1,
);

# I don't expect to get here...
print "Program completed OK\n";