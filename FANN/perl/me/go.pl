#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: go.pl
#
#        USAGE: ./go.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: A.Tkachuk (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 23.10.2015 08:34:48
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Parse::CSV;
use AI::FANN qw(:all);

my ($coef) = 100; #
my ($filetrain) = "train.txt";

sub isNumeric
{
	my($temp) = @_;

	unless($temp =~/^[+-]?\d+$/)
	{
		return 0;
	}

	return 1;

}

sub arr2str
{
	my(@array) = @_;

	my($str);

	for(@array)
	{
		$str .= $_." "	
	}

	return $str;
}

sub toFile
{
	my(@array) = @_;
	

	open(my $fh, '>>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
    
    for(@array)
    {
        say $fh $_;
    }
	
	close $fh;
}

sub editHFile
{
	my($number) = @_;
	open(my $fh,  $filetrain) or die "Не могу открыть файл '$filetrain' $!";
	my $firstLine = <$fh>;	
	close $fh;
	my ($count) = split(' ',$firstLine );

	#return undef  unless(isnumeric($count));

	$count +=$number;
	my $oldLine = $firstLine;

	if($firstLine =~ s/\d+/$count/)
	{
		#print $_, "\n";
	}

	`perl -pi -w -e 's/$oldLine/$firstLine/;' $filetrain  `;	
	
	return;
}

sub createTrainFile
{
	my($in, $filename) = @_;
	
	my(@rows, @arr);
	
	my $simple = Parse::CSV->new(
		file => $filename,
		sep_char   => ';',
	);
	
	

	while ( my $array_ref = $simple->fetch ) 
	{
		next if(!isNumeric($array_ref->[0]));
	    
        for(4..9)
        {
            push @arr, $array_ref->[$_];
        }
         		
	}
    
    #(@rows) = reverse(@arr); #перевернули массив
    (@rows ) = (@arr);
    (@arr) = ();

	my($i) = 0; 

	my(@finalrows) = ();
    
    for(@rows)
    {
        $i++;
        
        if($i<=$in*6)
        {

            push @arr, $_;
        }
		elsif( $in*6 < $i and $i <= ($in+1) * 6 )
		{	
            push @arr, ($_/$coef);
        }
        else
        {    

			$i = 1;
			
            push @finalrows, arr2str(@arr);
            
			@arr = ();
            push @arr, $_;

		}
        
    }
	
    my $count  =  @finalrows;
	#print Dumper @arr;
	toFile(@finalrows);
	editHFile($count);
	return 1;
}

sub main
{
    my $filename = 'go.ann';

	unless($ARGV[0])
	{
		$ARGV[0] = 'none';
	}

	if ($ARGV[0] eq 'train') 
    {
        my $num_input = 18;
        my $num_neurons_hidden = 128; #
        my $num_neurons2_hidden = 128;
        my $num_output = 6;
        my $ann = AI::FANN->new_standard( 
            $num_input, 
            $num_neurons_hidden, 
            $num_neurons2_hidden,
            $num_output );

        $ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
        $ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);

        #print $ann->train_error_function;	

        #каждая эпоха это постоение новой цепочки
        #вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
        $ann->train_on_file($filetrain, 50000, 100, 0.009); #от последнего зависит точность данных

        $ann->save($filename);

    }
	elsif($ARGV[0] eq 'createfile')
	{
		open(my $fh, '>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
		say $fh  "0 18 6";
		close $fh; #обнуляем файл

        #createTrainFile(3, '1.csv');
        #createTrainFile(3, '2.csv');
        #createTrainFile(3, '3.csv');
        createTrainFile(3, 'new.csv');

	}
	elsif($ARGV[0] eq 'test')
	{
        my $ann = AI::FANN->new_from_file($filename);
        my (@data) = (40,37,31,3,25,23,6,44,26,10,27,40,33,43,20,14,9,3 );
        my  $out = $ann->run([@data]);
        
        print Dumper $out;        
        print "36  44  23  3   21  22 \n";

        
	}
	else
	{
		print "undef command ( train, test, createfile )  \n";
	}

}

main();
