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
use Text::CSV;
use Data::Dumper;

 my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                  or die "Cannot use CSV: ".Text::CSV->error_diag ();

my (@rows);
open my $fh, "<:encoding(windows-1251)", "1.csv" or die "test.csv: $!";
while ( my $row = $csv->getline( $fh ) ) {
    #$row->[2] =~ m/pattern/ or next; # 3rd field should match
    push @rows, $row;
    print Dumper $row;
}
$csv->eof or $csv->error_diag();
close $fh;

$csv->eol ("\r\n");

my $count = @rows; 

for(my $i=$count-1;$i>0;$i--)
{
    print Dumper $rows[$i];
    print $rows[$i]->[2], "\n";
    die();
}


