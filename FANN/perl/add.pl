#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: add.pl
#
#        USAGE: ./add.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 22.10.2015 12:54:41
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;



use AI::FANN qw(:all);
use Data::Dumper;

my($did) = 100; #делитель чем больше тем болше он научиться прибавлять чисел 
sub toInt 
{
	#округление к большему если больше 0.5 то 1
	my($float, $rInt) = @_;
	
	$rInt = int($float);

	if(($float - $rInt)>=0.5)
	{
		$rInt++;
	}

	
	return $rInt;
}


if ($ARGV[0] eq 'train') {
	
	my $num_input = 2;
	my $num_neurons_hidden = 3; #
	my $num_neurons2_hidden = 3;
	my $num_output = 1;
	my $ann = AI::FANN->new_standard( 
		$num_input, 
		$num_neurons_hidden, 
		#$num_neurons2_hidden,
		$num_output );
	$ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
	$ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);
	
	# create the training data for a XOR operator:	
	
	my $train = AI::FANN::TrainData->new_empty(106, 2, 1);

	my $i =0;
	for my $a (0..9) {
		for my $b (0..9) {

			my $c = ($a+$b)/$did;
			$i++;
			$train->data($i,[$a, $b], [$c]);	

		}
	}
	
	print "i  =$i \n";

	$ann->train_on_data($train, 500000, 100000, 0.00000001); #от последнего зависит точность данных

	$ann->save("add.ann");
}
elsif ($ARGV[0] eq 'test') 
{
	my $ann = AI::FANN->new_from_file("add.ann");

	my($i, $good) = (0,0);

		for(0..9)
	{	
		$i++;
		my($a,$b) = ( toInt(rand(10)), toInt(rand(20)) );
		my 	$out = $ann->run([$a,$b]);
		

		my $res = toInt($out->[0]*$did);
		printf "%d + %d = %d (real: %d )\n", $a, $b, $res, ($a+$b);
		if($res ==($a+$b) )
		{
			$good++;
		}

		my $c = ($a+$b)/$did;
	
	}
	
	print "Result: $good is $i \n";

}
else {
	die "bad action\n"
}

