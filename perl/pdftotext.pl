#!/usr/bin/perl
use strict;
use warnings;

use CAM::PDF::PageText;
use CAM::PDF;
use feature 'say';

my $file = "/home/max/Documents/Books/Programming/Dropbox Link ALL/Books/David_B._Copeland_Build_Awesome_Command-Line_App(z-lib.org).pdf";
my $doc = CAM::PDF->new($file);

my $pageText = $doc->getPageText(2);

say $pageText;
#print $pageone_tree;