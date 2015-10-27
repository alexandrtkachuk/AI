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
use SL;


sub main
{
    my $filename = 'brains/go-out52.ann';
    my $in = 18;
    my ($filetrain) = "train/train.txt";
    my ($sl) = SL->new();

    $sl->{'filetrain'} =$filetrain;
    $sl->{'input'} = $in;
	$sl->{'filename'} = $filename;
    $sl->{'neurons_hidden'} = 64;
    $sl->{'neurons2_hidden'} = 64;
    $sl->{'desired_error'} = 0.00199;

    unless($ARGV[0])
	{
		$ARGV[0] = 'none';
	}

	if ($ARGV[0] eq 'train') 
    {
        #$sl->train(50000,1000,0.0000009);
		#$sl->trainCascad(600);
	
        $sl->trainOut52(50000, 1000, 0.000059999);
    }
	elsif($ARGV[0] eq 'createfile')
	{
		open(my $fh, '>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
		say $fh  "0 $in 6";
		close $fh; #обнуляем файл
        
        #createTrainFile(3, '1.csv');
        #createTrainFile(3, '2.csv');
        #createTrainFile(3, '3.csv');
        $sl->createTrainFile(3, 'info/new2.csv');
        
	}
	elsif($ARGV[0] eq 'test')
    {
    
        my (@data) = 
        (
            [qw(10 44 19 29 40 33 27 23 14 24 13 28 38 28 27 26 51 29)],
            [qw(27 23 14 24 13 28 38 28 27 26 51 29 36 1 24 30 19 33)],
            [qw(38 28 27 26 51 29 36 1 24 30 19 33 33 13 47 41 30 38)],
            [qw(36 1 24 30 19 33 33 13 47 41 30 38 50 33 2 5 6 23)]
        );

        my (@res) = 
        ( 
            '36 1 24 30 19 33', 
            '33 13 47 41 30 38', 
            '50 33 2 5 6 23',
            '0.18 0.05 0.35 0.42 0.04 0.29'  
        ); 
        
        
        $sl->test(\@data, \@res);
    }
    else
	{
		print "undef command ( train, test, createfile )  \n";         

	}

}

main();
