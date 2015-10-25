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

my ($filetrain) = "train.txt";


sub main
{
    my $filename = 'go.ann';

	unless($ARGV[0])
	{
		$ARGV[0] = 'none';
	}

	if ($ARGV[0] eq 'train') 
    {
        my $sl = SL->new();
        $sl->{'filetrain'} =$filetrain;
        $sl->train();
    }
	elsif($ARGV[0] eq 'createfile')
	{
		open(my $fh, '>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
		say $fh  "0 18 6";
		close $fh; #обнуляем файл
        
        my $sl = SL->new();
        #createTrainFile(3, '1.csv');
        #createTrainFile(3, '2.csv');
        #createTrainFile(3, '3.csv');
        $sl->createTrainFile(3, 'new2.csv');

	}
	elsif($ARGV[0] eq 'test')
    {
    #10 44 19 29 40 33 27 23 14 24 13 28 38 28 27 26 51 29 0.36 0.01 0.24 0.3 0.19 0.33 
    #27 23 14 24 13 28 38 28 27 26 51 29 36 1 24 30 19 33 0.33 0.13 0.47 0.41 0.3 0.38 
    #38 28 27 26 51 29 36 1 24 30 19 33 33 13 47 41 30 38 0.5 0.33 0.02 0.05 0.06 0.23 
    #36 1 24 30 19 33 33 13 47 41 30 38 50 33 2 5 6 23 0.18 0.05 0.35 0.42 0.04 0.29
    #
    #my $ann = AI::FANN->new_from_file($filename);
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
        
        my $sl = SL->new();
        
        $sl->test(\@data, \@res);

        
    }
    else
	{
		print "undef command ( train, test, createfile )  \n";         

	}

}

main();
