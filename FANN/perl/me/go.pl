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
use SL;

my ($sl, @globalCash);
sub auto_test
{
	my($keyNum, $countTrain) =@_;

	$sl->{'auto'} = 1;

	$sl->craeteANN();

	$sl->createTrainData($keyNum); #set key = count 6 * num exaple	

	$sl->trainANN($countTrain,1000);

	my($ann) =  $sl->{'ann'};

	for(0..4)
	{
		undef $sl->{'ann'};
		$sl->{'ann'} = $ann;
		$sl->trainData(10000, 0, 0.000000035);		
		my ($bitfail) = $sl->{'ann'}->bit_fail;

		#$sl->save2fileANN();


		my (@res) = $sl->autoTestANN($keyNum);
		my ($neurons) = $sl->{'neurons_hidden'};
		my ($trainigs) = $countTrain * 1000;

		print "key = $keyNum \tneurons = $neurons \ttrainings = $trainigs \t1)$res[0] \t2)$res[1] \t3)$res[2] \tbit fail = $bitfail \n"; 
		push @globalCash , $sl->autoTestNext($keyNum);
	}

	undef $ann;
	undef $sl->{'ann'};
}





sub main
{
    my $filename = 'brains/go-out52.ann';
    my $in = 18;
	my $keyNum = 15;
    my ($filetrain) = "train/train.txt";

    $sl = SL->new();

    $sl->{'filetrain'} =$filetrain;
	$sl->{'filetest'} ="train/test.txt";
	#$sl->{'input'} = $in; # for old version
	$sl->{'input'} = 52*$keyNum;
	$sl->{'filename'} = $filename;
    $sl->{'neurons_hidden'} = 24; # 52 * 4
    $sl->{'neurons2_hidden'} = 0;
    $sl->{'desired_error'} = 0.00199;

    unless($ARGV[0])
	{
		$ARGV[0] = 'none';
	}

	if($ARGV[0] eq 'train' )
	{
		$sl->{'filename'} = 'brains/go-tarin2me.ann';

		$sl->craeteANN();
		
		#$sl->loadFileAnn();
		
		$sl->createTrainData($keyNum); #set key = count 6 * num exaple	
		
		#my($INDATA , $OUTDATA) = $train->data(1);		
		#print Dumper @$INDATA; 
		#return ;
		
		$sl->trainANN(30,1000);
		
		$sl->save2fileANN();
	
		
		$sl->trainData(50000, 100, 0.000000035);
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
	elsif($ARGV[0] eq 'autotest')
    {	
		$sl->{'neurons_hidden'} = 32; # 52 * 4	
		$sl->{'neurons2_hidden'} = 0;	
		

		for(1..3)
		{
            print "$_ \n"; 
				#$sl->{'neurons_hidden'} = $_;
				#auto_test($keyNum, 5);
				auto_test($keyNum, 5);
		}

		for my $i (1..52)
		{
			my ($count) = 0;

			for(@globalCash)
			{
                
				$count++ if($_->[0] == $i);
			}

			print "$i = $count \n";
		}
        
        print "0.33 0.13 0.47 0.41 0.3 0.38 \n";
        #print Dumper @globalCash;
	}
    else
	{
		print "undef command ( train, test, createfile, autotest )  \n";
	}
	
	return 1;
}


main();




