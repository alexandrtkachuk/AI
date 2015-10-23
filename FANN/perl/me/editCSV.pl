#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: editCSV.pl
#
#        USAGE: ./editCSV.pl  
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
#      CREATED: 23.10.2015 08:34:48
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Parse::CSV;

use ($coef) = 100; #


sub createTrainFile
{
	my($in, $out) = @_;
	
	my(@rows, @arr);

	my $simple = Parse::CSV->new(
		file => '1.csv',
		sep_char   => ';',
	);
	
	my($i) = 0;

	while ( my $array_ref = $simple->fetch ) 
	{
		next if( ($array_ref->[0] * 1) < 1);
		
		for(4..9)
		{
			push @arr, $array_ref->[$_];
		}

	}
	
	print Dumper @arr;
}

createTrainFile();

die();

my $simple = Parse::CSV->new(
	file => '1.csv',
	sep_char   => ';',
);

my (@rows);

while ( my $array_ref = $simple->fetch ) 
{
	# Do something...

	next if($array_ref->[0]*1 <1);

	#print Dumper $array_ref;
	my ($str) = $array_ref->[0].' '.
	$array_ref->[4].' '.
	$array_ref->[5].' ' . 
	$array_ref->[6].' ' .
	$array_ref->[7].' ' .
	$array_ref->[8].' '.
	$array_ref->[9]."\n";


	push @rows, $str;


}

my $count = @rows; 

for(my $i=$count-1;$i>=0;$i--)
{
    print  $rows[$i];
	#print $rows[$i]->[2], "\n";
    
}


die();

my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                  or die "Cannot use CSV: ".Text::CSV->error_diag ();


open my $fh, "<:encoding(windows-1251)", "1.csv" or die "test.csv: $!";
while ( my $row = $csv->getline( $fh ) ) {
    #$row->[2] =~ m/pattern/ or next; # 3rd field should match
    push @rows, $row;
    print Dumper $row;
}
$csv->eof or $csv->error_diag();
close $fh;

$csv->eol ("\r\n");

