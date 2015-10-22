#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 21.10.2015 17:19:41
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use AI::FANN qw(:all);
use Data::Dumper;
print 'good' ,"\n";

my $n =500;

if ($ARGV[0] eq 'train') {

	# create an ANN with 2 inputs, a hidden layer with 3 neurons and an
	# output layer with 1 neuron:
	#my $num_layers = 3;
	my $num_input = 2;
	my $num_neurons_hidden = 3; #
	#my $num_neurons2_hidden = 30;
	my $num_output = 1;
	my $ann = AI::FANN->new_standard( $num_input, $num_neurons_hidden, $num_output );
	
	$ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
	$ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);
	
	# create the training data for a XOR operator:	
	
	my $train = AI::FANN::TrainData->new_empty(100, 2, 1);

	my $i =0;
	for my $a (1..9) {
		for my $b (1..9) {

			my $c = ($a+$b)/100;
			$i++;
			$train->data($i,[$a, $b], [$c]);	

		}
	}

	
		
	my $xor_train = AI::FANN::TrainData->new( 
		[5, 1], [6],
		[5, 2], [7],
		[2, 3], [5],
		[1, 1], [2]
		,[4, 5], [9]
	    
	);
	
	
	print 'next', "\n";	

	$ann->train_on_data($train, 250000, 1000, 0.0001);

	$ann->save("xor.ann");
}
elsif ($ARGV[0] eq 'test') {

	my $ann = AI::FANN->new_from_file("xor.ann");

	for my $a (-1, 1) {
		for my $b (-1, 1) {
			my $out = $ann->run([$a, $b]);
			printf "xor(%f, %f) = %f\n", $a, $b, $out->[0];
		}
	}
	my($a,$b) = (2,-1);
	my $out = $ann->run([$a, $b]);
			printf "xor(%f, %f) = %f\n", $a, $b, $out->[0];

}
elsif ($ARGV[0] eq 'testsq') {
		my $ann = AI::FANN->new_from_file("xor.ann");
		
		my($a,$b) = (3,4);
		my 	$out = $ann->run([$a,$b]);
		printf "%d + %d = %f (real: %f )\n", $a, $b, $out->[0], ($a+$b)/100;
		
	
}
else {
	die "bad action\n"
}
		
#print "\n", xor(2,1), "\n";
