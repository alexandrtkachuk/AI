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
            'max_epochs' => 50000
        },$class);
}

sub train
{
    my($self) = @_;
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

    #print $ann->train_error_function;	

    #каждая эпоха это постоение новой цепочки
    #вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
    $ann->train_on_file($self->{'filetrain'}, 
        $self->{'max_epochs'}, 
        $self->{'epochs_between_reports'}, 
        $self->{'desired_error'}); #от последнего зависит точность данных

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
	
    #каждая эпоха это постоение новой цепочки
    #вывод статистики показывает погрешность за указаный период эпох(предпологаю что это минимальное значение в эпохе)	
    
    $ann->cascadetrain_on_file($self->{'filetrain'}, 
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

		for($num_input..$num_input+5)
		{
			my $a = ($arr[$_] * $self->{'coef'}) - 1; 
			$tempout[$a] = 1;
		}
		
		for(0..51)
		{
			unless($tempout[$_])
			{
				$tempout[$_] = 0;
			}
		}

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
	
	print $train->length , "\n"; # количество примеров для тренеровки
	
	#print Dumper $out;
	for(0..10000)
	{
		for my $i(0..$train->length-1)
		{
			my ($in, $out) = $train->data($i);
			$ann->train($in, $out);
		}
	}

	#my ($in, $out) = $train->data(2);
	#my (@rr) =  $ann->test($in, $out);
	#print Dumper @rr;
	

	$ann->train_on_data($train, 
        $max_epochs, 
        $epochs_between_reports, 
        $desired_error); #от последнего зависит точность данных

    $ann->save($self->{'filename'});


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
				return  if($count > 10);
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
