#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: Help.pl
#
#        USAGE: ./Help.pl  
#
#  DESCRIPTION: :
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 29.10.2015 12:47:18
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Data::Dumper;
use base qw(Test::Class);
use Test::More 'no_plan';;

use lib '../';

use Tools::Help qw/:DEF/;




sub startup : Test(startup)
{
	

}

sub isNumericTest :Test
{
	can_ok( 'Tools::Help' , 'isNumeric' ); 
	ok(isNumeric(13), 'good this is numeric');
	#ok(isNumeric(13.5), 'good this is numeric');
	ok(!isNumeric('bb'), 'this is string');
}

sub arr2strTest :Test
{
	my (@arr) = (2,3,4,5,6);

	cmp_ok( arr2str(@arr) , 'eq', '2 3 4 5 6 ' );
}

sub did2bitTest :Test
{
	my (@arr) = (2,3,4,5,6,52);
	my (@out) = did2bit(1,@arr);
	my $count = @out;
	ok(
		$out[1] == 1
	   && 	$out[2] == 1
	   &&	$out[3] == 1
	   &&	$out[4] == 1
	   &&	$out[5] == 1
	   &&	$out[6] == 0
	   &&	$out[51] == 1
	   &&	$out[8] == 0
	   &&	$count == 52
		, 'good did2bit');

}

sub createInDataTest :Test
{
	#need more tests
	my (@arr) = (2,3,4,5,6,52, 1,52,51,50,49,48);

	my (@out) =	createInData(2,2*52,@arr);

	my $count  = @out;

	ok(
		$out[1] == 1
		&& 	$out[2] == 1
		&&	$out[3] == 1
		&&	$out[4] == 1
		&&	$out[5] == 1
		&&	$out[6] == 0
		&&	$out[51] == 1
		&&	$out[8] == 0
		&&	$count == 2*52
		&&   $out[103] == 1
		&&   $out[102] == 1
		&&   $out[101] == 1
		&&   $out[100] == 1
		&&   $out[99] == 1
		&&   $out[98] == 0
		, 'good did2bit');
}


sub sortmeTest :Test
{
	my (@arr) = (0.2 , 0.4, 1, 0.5, 0.3 );

	my (@out) = sortme(20,@arr);
	
	ok(
		$out[0]->[1] == 1
		&& $out[1]->[1] == 0.5
		&& $out[2]->[1] == 0.4
		&& $out[3]->[1] == 0.3
		&& $out[4]->[1] == 0.2
		,'good sortme'
	);

}

#run tests
Test::Class->runtests;
