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
    $ann->cascadetrain_on_file($self->{'filetrain'}, 
        $self->{'neurons_hidden'}, 
        1, 
        $self->{'desired_error'}); #от последнего зависит точность данных

    $ann->save($self->{'filename'});
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
        print Dumper $out;
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
