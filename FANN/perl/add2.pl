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
my ($filename) =  "add2.ann";
my ($filetrain) = "add2.train";
my ($test) = 1; # if undef = no put file 

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

sub editHFile
{
	my($errors) = @_;
	open(my $fh,  $filetrain) or die "Не могу открыть файл '$filetrain' $!";
	my $firstLine = <$fh>;	
	close $fh;
	my ($count) = split(' ',$firstLine );
	$count +=$errors;
	my $oldLine = $firstLine;
	if($firstLine =~ s/\d+/$count/)
	{
		#print $_, "\n";
	}

	`perl -pi -w -e 's/$oldLine/$firstLine/;' $filetrain  `;	
	
	return;
}


sub createNTF
{

	open(my $fh, '>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
	
	say $fh "100 2 1";

	for my $a (0..9) {
		for my $b (0..9) {

			my $c = ($a+$b)/$did;

			say $fh "$a $b $c";
		}
	}

	close $fh;

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
	
	#print $ann->train_error_function;	
	
	#каждая эпоха это постоение новой цепочки
	#вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
	$ann->train_on_file($filetrain, 5000000, 10000, 0.0000009810); #от последнего зависит точность данных
		
	$ann->save($filename);
}
elsif ($ARGV[0] eq 'test') 
{
	my $ann = AI::FANN->new_from_file($filename);



	my($i, $good, $errors) = (0,0,0);

	for(0..999)
	{	
		$i++;
		my($a,$b) = ( toInt(rand(25)), toInt(rand(25)) );
		my 	$out = $ann->run([$a,$b]);


		my $res = toInt($out->[0]*$did);
		#printf "%d + %d = %d (real: %d )\n", $a, $b, $res, ($a+$b);

		if($res ==($a+$b) )
		{
			$good++;
		}
		else
		{
			printf "%d + %d = %d (real: %d )\n", $a, $b, $res, ($a+$b);
			open(my $fh, '>>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
			my $c = ($a+$b)/$did;
			say $fh "$a $b $c" if (!$test) ;
			close $fh;
			$errors++;
		}
	}
	
	editHFile($errors) if (!$test);

	print "Result: $good is $i \n";

}
elsif ($ARGV[0] eq 'file')
{

	#editHFile(5);	
	createNTF();
}
else {
	die "bad action\n"
}

