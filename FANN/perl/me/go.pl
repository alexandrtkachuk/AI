#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: go.pl
#
#        USAGE: ./go.pl  
#
#  DESCRIPTION: 
#
#  
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
	my $keyNum = 10;
    my ($filetrain) = "train/train.txt";
    my ($sl) = SL->new();

    $sl->{'filetrain'} =$filetrain;
	$sl->{'filetest'} ="train/test.txt";
    $sl->{'input'} = $in;
	$sl->{'filename'} = $filename;
    $sl->{'neurons_hidden'} = 30; # 52 * 4
    $sl->{'neurons2_hidden'} = 64;
    $sl->{'desired_error'} = 0.00199;

    unless($ARGV[0])
	{
		$ARGV[0] = 'none';
	}

	if($ARGV[0] eq 'train' )
	{
		$sl->{'input'} = 52*$keyNum;
		$sl->{'filename'} = 'brains/go-tarin2me.ann';

		$sl->craeteANN();
		
		#$sl->loadFileAnn();
		
		$sl->createTrainData($keyNum); #set key = count 6 * num exaple	
		
		#my($INDATA , $OUTDATA) = $train->data(1);		
		#print Dumper @$INDATA; 
		#return ;
		
		$sl->trainANN(10,100);
		
		$sl->save2fileANN();
	
		
		$sl->trainData(50000, 100, 0.0000000015);
		$sl->{'filename'} = $filename;
		$sl->save2fileANN();

		print "total_connections= ",$sl->{'ann'}->total_connections,"\n";
		

		print " MSE = ", $sl->{'ann'}->MSE, "\n";
		

		print "bit fail = " , $sl->{'ann'}->bit_fail, "\n";	
				
		print 'end', "\n";
		 
	}
	elsif($ARGV[0] eq 'createfile')
	{
		open(my $fh, '>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
		say $fh  "0 $in 6";
		close $fh; #обнуляем файл
		
		open( $fh, '>', $sl->{'filetest'}) or die "Не могу открыть файл '$sl->{'filetest'}' $!";
		say $fh  "3 = count test";
		close $fh; #обнуляем файл


        #createTrainFile(3, '1.csv');
        #createTrainFile(3, '2.csv');
        #createTrainFile(3, '3.csv');
        $sl->createTrainFile($keyNum, 'info/new2.csv' ,100, 3);
        
	}
	elsif($ARGV[0] eq 'test')
    {
   		$sl->testANN($keyNum);
    }
    else
	{
		print "undef command ( train, test, createfile )  \n";         

	}
	
	return 1;
}


main();




