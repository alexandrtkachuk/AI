#
#===============================================================================
#
#         FILE: SL.pm
#
#  DESCRIPTION: 
#	
#	MUST DO:
#	1) Create ANN 
#	2)set desired errors
#	3)set count epoh 
#	4)set count reporst step epoh 
#	5)set count train 
#	6)set count neurons
#	7)set enum fann_activationfunc_enum 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: A. Tkachuk, 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 25.10.2015 09:46:06
#     REVISION: ---
#===============================================================================
package SL;


use strict;
use warnings;
 
use Parse::CSV;
use AI::FANN qw(:all);
use Tools::Help qw/:DEF/;
use Data::Dumper;

sub new
{
    my ($class) = ref($_[0])||$_[0];
    
    return   bless({ 
            'coef' => 100,
            'filename' => 'go.ann',
            'filetrain' => 'train.txt',
			'filetest' => 'test.txt',
            'input' => 18,
            'neurons_hidden' => 64,
            'neurons2_hidden' => 64,
            'desired_error' => 0.05,
            'epochs_between_reports' =>100,
            'max_epochs' => 50000,
            'ann' => undef,
			'train' => undef,
			'datatrain' =>undef,
			'auto' => undef #for auto train
        },$class);
}

sub craeteANN
{
    my($self) = @_;
    my $num_input = $self->{'input'}; #18;
    my $num_neurons_hidden = $self->{'neurons_hidden'}; #
    my $num_neurons2_hidden = $self->{'neurons2_hidden'};
    my $num_output = 52;
    

	my(@inArr) =();

	push @inArr, $num_input;

	push @inArr, $self->{'neurons_hidden'};
	
	push @inArr, $self->{'neurons2_hidden'} if($num_neurons2_hidden);

	push @inArr, $num_output;

	my $ann = AI::FANN->new_standard(@inArr );
	

    $ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
    $ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);
        
    $self->{'ann'} = $ann;
	
	undef $ann;
    return 1;
}

sub save2fileANN
{
    my($self) = @_;

    if($self->{'ann'})
    {
        $self->{'ann'}->save($self->{'filename'});
        return 1;
    }

    return undef;
}

sub createTrainData
{
	my($self,$key) = @_;
	
	 $self->file2data($self->{'ann'}->num_inputs, $self->{'ann'}->num_outputs
		    ,'out52'
			, $key
	);
}

sub trainANN
{
	my($self, $count, $epoh) = @_;

	$self->train_to_file($count, $epoh);    
	
	return 1;
}

sub trainData
{
	my($self, $max_epochs, $epochs_between_reports, $desired_error) = @_;
	
	$self->{'ann'}->train_on_data($self->{'train'},
        $max_epochs, 
        $epochs_between_reports, 
        $desired_error); #от последнего зависит точность данных
	
	return 1;
}

sub loadFileAnn
{
	my($self) = @_;

	$self->{'ann'} = AI::FANN->new_from_file($self->{'filename'});
	
	return 1;
}

sub file2array
{

	my($self, $num_input, $num_output, $key,$keyin, $filename) = @_;
    
	unless($keyin)
	{
		$keyin = 'norm';
	}

    open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file ".$filename." $!";
	my $row = <$fh>;

	chomp $row;
	my ($count) = split(' ',$row);
	
	my (@arr, @filalarr) =();

	while ( $row = <$fh>) 
	{
		chomp $row;
		#print "$row\n";
		(@arr) = split(' ',$row);

        my (@tempin, @tempout) = ();

		(@tempin) = createInData($keyin,$num_input, @arr);
	    (@tempout) = $self->createOutData($key,$num_input, @arr);	
		
		push @filalarr , [[@tempin], [@tempout]]; 
	}

	close $fh;	
	undef @arr;

	return ($count ,@filalarr);
}

sub file2data
{
    my($self, $num_input, $num_output, $key,$keyin) = @_;
    
	my ($count ,@filalarr) =$self->file2array($num_input, 
		$num_output, $key,$keyin, $self->{'filetrain'});	

	$self->{'train'} = AI::FANN::TrainData->new_empty($count, $num_input, $num_output);

	my $i =0;
	for(@filalarr) 
	{
		$self->{'train'}->data($i,$_->[0], $_->[1]);
		$i++;
	}
	
	($self->{'datatrain'}) = (\@filalarr);
	
	#@filalarr = (undef);
    return ;
}

sub createOutData
{
    my ($self, $key,$num_input , @arr) = @_;
    
    my(@out) = ();

    if($key eq 'out52')
    {
        
		@out = did2bit($self->{'coef'}, @arr[-6..-1]);
    }
    elsif($key eq 'out6' )
    {
        for(@arr[-6..-1])
        {
            push @out, $_;
        }
    }

    return (@out);
}

sub train_to_file
{
    my($self , $count, $step) = @_;
    
    for my $s (1..$count)
    {
        for(0..$step)
        {
			#this is fix use more memory
			my ($arr) = $self->{'datatrain'};
            
			for my $i(@$arr)
            {	
				$self->{'ann'}->train($i->[0], $i->[1]);	
            }

			undef $arr;
        }
        
        print "end $s - step \n" unless($self->{'auto'});
    }

    return ;
}

sub testANN
{
    my($self, $key) = @_;	
	$self->loadFileAnn();
	
	my ($count ,@data) = $self->file2array($self->{'ann'}->num_inputs, 
		$self->{'ann'}->num_outputs, 
		'out6'
		,$key, 
		$self->{'filetest'});
	
    for my $i(0..$count-1)
    {
        #print @$_;	
		
        print "start $i \n";
		my ($dN) =  $data[$i]->[0];
			
        my $out  = $self->{'ann'}->run([@$dN]);
		#print Dumper @$out;
		my (@assum) = sortme(20, @$out);
		
		my ($amount) = 0;	
		my $res = $data[$i]->[1];

		for(@assum)
		{
			print $_->[0], ' -> ' ,$_->[1],  "\n";
			$amount++ if(in_array($_->[0],@$res));
		}
		
		
		
		print Dumper $res;

		print 	"\n amount  = $amount  \nend\n";
    }

}



sub in_array
{
	my ($item, @arr) = @_;
		
	for(@arr)
	{
		my ($el) = $_ * 100; 
		return 1 if($item eq "$el");
	}

	return undef;
}

sub autoTestANN
{	
	my($self, $key) = @_;	
	
	#altogether process tarin and test 
	#$self->loadFileAnn();  

	my ($count ,@data) = $self->file2array($self->{'ann'}->num_inputs, 
		$self->{'ann'}->num_outputs, 
		'out6'
		,$key, 
		$self->{'filetest'});

	my (@resOut) = ();

	for my $i(0..$count-1)
	{
		my ($dN) =  $data[$i]->[0];
		
		my $out  = $self->{'ann'}->run([@$dN]);

		my (@assum) = sortme(10, @$out);

		my $res = $data[$i]->[1];
		
		my ($amount) = 0; 

		for(@assum)
		{
			#print $_->[0], ' -> ' ,$_->[1],  "\n";

			if(in_array($_->[0],@$res))
			{
				#print $_->[0], ' -> ' ,$_->[1],  "\n";
				$amount++;
			}
		}

		push @resOut, $amount;
	}
	
	return @resOut;
}

sub autoTestNext
{	
	my($self, $key) = @_;	
	
	#altogether process tarin and test 
	#$self->loadFileAnn();  

	my ($count ,@data) = $self->file2array($self->{'ann'}->num_inputs, 
		$self->{'ann'}->num_outputs, 
		'out6'
		,$key, 
		$self->{'filetest'});

	my (@resOut) = ();
	
	my ($dN) =  $data[0]->[0];

	my $out  = $self->{'ann'}->run([@$dN]);
	my (@assum) = sortme(10, @$out);
	
	undef $out;
	
	return (@assum);
}



sub createTrainFile
{
    my($self, $in, $filename,$count_data_train, $count_data_test  ) = @_;
	#$count_data_train

    my (@rows) = parseCSV($filename);    

    my ($i, @arr) =(0);

    my(@finalrows) = ();
    
    my $CR = @rows;
    
    $CR = $CR - $in*6 - 6;

    for($i = 0; $i<$CR; $i = $i+6)
    {
		#необходимо избавиться от этой функции getInArr
	 	(@arr) = @rows[$i..$i+$in*6-1];  
		
	    my (@temp) =@rows[$i+$in*6..$i+$in*6+5];  

        for(@temp)
        {	
            push @arr, ($_/$self->{'coef'});
        }

        push @finalrows, arr2str(@arr);
    }
	


    my $count  =  @finalrows;

	if($count > $count_data_train+$count_data_test)
	{
		$count = $count_data_train+$count_data_test;

		(@finalrows) = @finalrows[-1*$count..-1];
	}
	
	toFile( $self->{'filetest'}, @finalrows[-1*$count_data_test..-1]); #create test file

	for(0..$count_data_test-1)
	{
		pop @finalrows;
		$count--;
	}

    toFile( $self->{'filetrain'}, @finalrows);

    editHFile($count, $self->{'filetrain'});

    return 1;
}

sub DelANN
{
	my $self = shift;
	
	undef $self->{'ann'};
	$self->{'datatrain'} = undef;
    $self->{'train'} = undef;
}

sub DESTROY 
{
	my $self = shift;
	undef $self->{'ann'};
	$self->{'datatrain'} = undef;
    $self->{'train'} = undef;   
}

1;
