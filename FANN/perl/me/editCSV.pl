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
use Text::CSV;


my ($filenew) = 'new.csv';

sub toFile
{
	my(@array) = @_;
	

	open(my $fh, '>>', $filenew) or die "Не могу открыть файл '$filenew' $!";
    
    for(@array)
    {
        say $fh $_->[0];
    }
	
	close $fh;
}
sub openCSV
{
    my ($filename) = @_;
    my (@rows);
    my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
        or die "Cannot use CSV: ".Text::CSV->error_diag ();


    open my $fh, "<:encoding(windows-1251)", $filename or die "$filename: $!";

    while ( my $row = $csv->getline( $fh ) ) 
    {
        #$row->[2] =~ m/pattern/ or next; # 3rd field should match
        push @rows, $row;
        #print Dumper $row;
    }

    $csv->eof or $csv->error_diag();
    close $fh;
    
    #print Dumper @rows;
    $csv->eol ("\r\n");

    return @rows;
}


open(my $fh, '>', $filenew) or die "Не могу открыть файл '$filenew' $!";

close $fh; #обнуляем файл

for(1..4)
{
    my @arr = openCSV("$_.csv");

    toFile(reverse(@arr));
}
