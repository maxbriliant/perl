#!/bin/perl
use feature 'switch';
use feature 'say';
use strict;
use diagnostics;

say "EXP 1 is ", exp 1;
say "HEX 10 is ", hex 10;
say "OCT 12 is ", oct 12;
say "INT 4.24 is", int(4.24);
say "LOG 2 is", log 2;
say "Random between 1-10 is ", int(rand 10) +1 ;
say "SQRT 9 is ", sqrt 9;

