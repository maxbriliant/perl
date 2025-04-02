#!/bin/perl
use strict;
use warnings;

package church;

#I Learned - Perl is using Package to Declare a Class 
#a subroutine - naming convention x_data includes constructer as function called $self
#bless function creates reference from variables to class
#declaring subroutine new  - first element is 	my $class = shift;
#able to handle parameters - second element is 	my $self = { @_ }; 
#in returning they have to be blessed -			return bless $self, $class;

use Data::Dumper;
use feature 'say';

sub church_data
{
	my $class_name = shift;
	my $self = {
				'ChurchName' => shift,
				'ChurchLocation' => shift,
				'ChurchStyle' => shift,
				};

	bless $self, $class_name;

	return $self;
}

my $Church1 = church_data church("Cathedral du Chartres", "France", "Roman");

say "$Church1->{'ChurchName'}";
say "$Church1->{'ChurchStyle'}";
say "$Church1->{'ChurchLocation'}";
say "";

print Dumper($Church1);