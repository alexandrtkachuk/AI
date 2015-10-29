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
use Data::Dumper;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(isNumeric arr2str  getInArr parseCSV editHFile toFile did2bit createInData sortme);
%EXPORT_TAGS = ( DEF => [qw(&isNumeric  &arr2str  &getInArr &parseCSV &editHFile &toFile &did2bit &createInData &sortme)] );

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

sub did2bit
{
	my ($coef, @arr) = @_;
	#array count = 6
	my(@out) = ();

	for(0..51)
	{
		$out[$_] = 0;
	}
	
	for(@arr)
	{
		my $a = ($_ * $coef) - 1; 
		$out[$a] = 1;
	}
		
	return (@out);
}

sub createInData
{
	my ($key,$num_input , @arr) = @_;

	my(@in) = ();
	
	if($key eq 'norm')
	{
		for(0..$num_input-1)
		{
			push @in ,$arr[$_];
		}
	}
	elsif($key eq 'in3x52')
	{
		push @in, did2bit(1, @arr[0..5]);
		push @in, did2bit(1, @arr[5..11]);
		push @in, did2bit(1, @arr[12..17]);
	}	
	elsif($key eq 'in4x52')
	{
		push @in, did2bit(1, @arr[0..5]);
		push @in, did2bit(1, @arr[5..11]);
		push @in, did2bit(1, @arr[12..17]);
		push @in, did2bit(1, @arr[18..23]);
	}	
	elsif(isNumeric($key))
	{
		my ( $count ) = $key*6;

		for(my ($i) = 0; $i < $count; $i = $i+6)
		{
			push @in, did2bit(1, @arr[$i..$i+5]);	 
		}
	}

	return (@in);
}

sub sortme
{
	my($min,@arr) = @_;
	my ($count, $per, @out) = (0,1);

 
	
	while($per > 0)
	{
		my($i) = (0);
		for(@arr)
		{
			$i++;
			if($per <= $_)
			{	
				push @out ,( [$i, $_]);
				$count++;
				$arr[$i-1] = 0;
				return  (@out) if($count >= $min);
			}
		}

		$per = $per - 0.0001;
	}

	return (@out);
}

1;
