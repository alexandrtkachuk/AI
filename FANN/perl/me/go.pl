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
	
	$count = @array;
	if($count <2)
	{
		return ;
	}

	for(@array)
	{
		$str .= $_." "	
	}

	return $str."\n";
}

sub toFile
{
	my(@array) = @_;
	

	open(my $fh, '>>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
	say $fh @array;
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
	
	my($i) = 0;

	while ( my $array_ref = $simple->fetch ) 
	{
		next if(!isNumeric($array_ref->[0]));
		
		$i++;

		if($i<=$in)
		{
			for(4..9)
			{
				push @arr, $array_ref->[$_];
			}
		}
		else
		{
			for(4..9)
			{
				push @arr, ($array_ref->[$_]/$coef);
			}

			$i = 0;
			

			$str  = arr2str(@arr);
			push @rows, $str;
			@arr = ();
		}
		
	}

	my $count = @rows; 

	my(@finalrows) = ();
	
	for(my $i=$count-1;$i>=0;$i--)
	{
		push @finalrows,  $rows[$i];

	}

	#print Dumper @arr;
	toFile(@finalrows);
	editHFile($count);
	return 1;
}

sub main
{
	unless($ARGV[0])
	{
		$ARGV[0] = 'none';
	}

	if ($ARGV[0] eq 'train') 
	{
	
	
	}
	elsif($ARGV[0] eq 'createfile')
	{
		open(my $fh, '>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
		say $fh  "0 18 6";
		close $fh; #обнуляем файл

		createTrainFile(3, '1.csv');
		#createTrainFile(3, '2.csv');
		#createTrainFile(3, '3.csv');
	}
	elsif($ARGV[0] eq 'test')
	{
	
	}
	else
	{
		print "undef command ( train, test, createfile )  \n";
	}

}

main();
