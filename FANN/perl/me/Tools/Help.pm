#
#===============================================================================
#
#         FILE: Help.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: A.Tkachuk (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 25.10.2015 13:24:07
#     REVISION: ---
#===============================================================================

package Tools::Help;

use strict;
use warnings;
use Exporter;
use Parse::CSV;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(isNumeric arr2str  getInArr parseCSV editHFile toFile);
%EXPORT_TAGS = ( DEF => [qw(&isNumeric  &arr2str  &getInArr &parseCSV &editHFile &toFile)] );

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

sub getInArr
{
    my ($start, $count, @arr) = @_;

    my (@newarr);

    for($start..$start+$count-1)
    {
        push @newarr, $arr[$_];
    }
    
    return @newarr;
}

sub parseCSV
{
    my($filename) = @_;

    my(@arr);

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
    
    return @arr;
}

sub editHFile
{
	my($number, $filetrain) = @_;
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

sub toFile
{
	my($filetrain , @array) = @_;
	
	open(my $fh, '>>', $filetrain) or die "Не могу открыть файл '$filetrain' $!";
    
    for(@array)
    {
        say $fh $_;
    }
	
	close $fh;
}

1;
