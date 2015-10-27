#
#===============================================================================
#
#         FILE: SL.pm
#
#  DESCRIPTION: 
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
    
    return bless({ 
            'coef' => 100,
            'filename' => 'go.ann',
            'filetrain' => 'train.txt',
            'input' => 18,
            'neurons_hidden' => 64,
            'neurons2_hidden' => 64,
            'desired_error' => 0.05,
            'epochs_between_reports' =>100,
            'max_epochs' => 50000,
            'ann' = undef
        },$class);
}

sub train
{
    my($self ,$max_epochs, $epochs_between_reports, $desired_error) = @_;
    my $num_input = $self->{'input'}; #18;
    my $num_neurons_hidden = $self->{'neurons_hidden'}; #
    my $num_neurons2_hidden = $self->{'neurons2_hidden'};
    my $num_output = 6;
    my $ann = AI::FANN->new_standard( 
        $num_input, 
        $num_neurons_hidden, 
        $num_neurons2_hidden,
        $num_output );

    $ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
    $ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);
	
    my ($train) = $self->file2data($num_input, $num_output, 'out6');
     $ann = train_to_file(5, 500, $train,$ann);
    #каждая эпоха это постоение новой цепочки
    #вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
    $ann->train_on_data($train, 
        $max_epochs, 
        $epochs_between_reports, 
        $desired_error); #от последнего зависит точность данных

    $ann->save($self->{'filename'});
}

sub trainCascad
{
    my($self, $max_neurons) = @_;
    my $num_input = $self->{'input'}; #18;
    my $num_output = 6;
    my $ann = AI::FANN->new_standard( 
        $num_input, 
        $num_output );

    $ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
    $ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);


    my ($train) = $self->file2data($num_input, $num_output, 'out6');
    
    #$ann = train_to_file(5, 500, $train,$ann);
    #каждая эпоха это постоение новой цепочки
    #вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
    
    $ann->cascadetrain_on_data($train, 
        $max_neurons, 
        1, #step  report
        $self->{'desired_error'}); #от последнего зависит точность данных

    $ann->save($self->{'filename'});
}

sub trainOut52
{
    #тренеровка в выходом в 52 и с входом 18
    #просто брать файл парсить и делатьтренеровку по  дате 
	
	my($self,$max_epochs, $epochs_between_reports, $desired_error ) = @_;
    my $num_input = $self->{'input'}; #18;
    my $num_neurons_hidden = $self->{'neurons_hidden'}; #
    my $num_neurons2_hidden = $self->{'neurons2_hidden'};
    my $num_output = 52;
    my $ann = AI::FANN->new_standard( 
        $num_input, 
        $num_neurons_hidden, 
		$num_neurons2_hidden,
        $num_output );

    $ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
    $ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);

    #print $ann->train_error_function;	

    #каждая эпоха это постоение новой цепочки
    #вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
	
    my ($train) = $self->file2data($num_input, $num_output, 'out52');
    
    $ann = train_to_file(6, 1000, $train,$ann);    
 	
	$ann->train_on_data($train, 
        $max_epochs, 
        $epochs_between_reports, 
        $desired_error); #от последнего зависит точность данных

    $ann->save($self->{'filename'});
}

sub craeteANN
{
    my($self) = @_;
    my $num_input = $self->{'input'}; #18;
    my $num_neurons_hidden = $self->{'neurons_hidden'}; #
    my $num_neurons2_hidden = $self->{'neurons2_hidden'};
    my $num_output = 52;
    my $ann = AI::FANN->new_standard( 
        $num_input, 
        $num_neurons_hidden, 
		$num_neurons2_hidden,
        $num_output );

    $ann->hidden_activation_function(FANN_SIGMOID_SYMMETRIC);
    $ann->output_activation_function(FANN_SIGMOID_SYMMETRIC);
        
    $self->{'ann'} = $ann;

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

sub file2data
{
    my($self, $num_input, $num_output, $key) = @_;
    
    open(my $fh, '<:encoding(UTF-8)', $self->{'filetrain'}) or die "Could not open file ".$self->{'filetrain'}." $!";
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

		for(0..$num_input-1)
		{
			push @tempin ,$arr[$_];
		}

	    (@tempout) = $self->createOutData($key,$num_input, @arr);	
		push @filalarr , [[@tempin], [@tempout]];

		#print Dumper $filalarr[0]->[1]; 
	}

	close $fh;
	

	my $train = AI::FANN::TrainData->new_empty($count, $num_input, $num_output);

	my $i =0;
	for(@filalarr) 
	{
		$train->data($i,$_->[0], $_->[1]);
		$i++;
	}

    return ($train);
}


sub createOutData
{
    my ($self, $key,$num_input , @arr) = @_;
    
    my(@out) = ();

    if($key eq 'out52')
    {
        for($num_input..$num_input+5)
        {
            my $a = ($arr[$_] * $self->{'coef'}) - 1; 
            $out[$a] = 1;
        }

        for(0..51)
        {
            unless($out[$_])
            {
                $out[$_] = 0;
            }
        }
    }
    elsif($key eq 'out6' )
    {
        for($num_input..$num_input+5)
        {
            push @out, $arr[$_] ;
        }
    }

    return (@out);
}


sub train_to_file
{
    my($count, $step, $train, $ann) = @_;
    
    for my $s (1..$count)
    {
        for(0..$step)
        {
            for my $i(0..$train->length-1)
            {
                my ($in, $out) = $train->data($i);
                $ann->train($in, $out);
            }
        }

        #sleep(5);
        print "end $s - step \n";
    }
    
    return $ann;
}


sub sortme
{
	my(@arr) = @_;
	my ($count, $per) = (0,0.9);

	while($per > 0)
	{
		my($i) = (0);
		for(@arr)
		{
			$i++;
			if($per < $_)
			{
				print $i," - " ,$_, "\n";
				$count++;
				$arr[$i-1] = 0;
				return  if($count > 15);
			}
		}

		$per = $per - 0.1;
	}
}

sub test
{
    my($self, $data, $res) = @_;

    my $ann = AI::FANN->new_from_file($self->{'filename'});
    
    my $count = @$data;

    for(0..$count-1)
    {
        #print @$_;
        print "start $_ \n";
        my $out  = $ann->run($$data[$_]);
		#print Dumper @$out;
		sortme(@$out);
        print $$res[$_];

        print "\nend\n";
    }
}

sub createTrainFile
{
    my($self, $in, $filename) = @_;

    my (@rows) = parseCSV($filename);    

    my ($i, @arr) =(0);

    my(@finalrows) = ();
    
    my $CR = @rows;
    
    $CR = $CR - $in*6 - 6;

    for($i = 0; $i<$CR; $i = $i+6)
    {
        (@arr) = getInArr($i, $in*6,@rows);

        my (@temp) = getInArr($i+$in*6, 6,@rows);

        for(@temp)
        {	
            push @arr, ($_/$self->{'coef'});
        }

        push @finalrows, arr2str(@arr);
    }

    my $count  =  @finalrows;
   
    toFile( $self->{'filetrain'}, @finalrows);
    editHFile($count, $self->{'filetrain'});

    return 1;
}

1;
