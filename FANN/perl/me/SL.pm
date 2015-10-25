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
            'filetrain' => 'train.txt'
        },$class);
}

sub train
{
    my($self) = @_;
    my $num_input = 18;
    my $num_neurons_hidden = 128; #
    my $num_neurons2_hidden = 128;
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
    $ann->train_on_file($self->{'filetrain'}, 50000, 100, 0.007); #от последнего зависит точность данных

    $ann->save($self->{'filename'});
}

sub test
{
    my($self, $data, $res) = @_;

    my $ann = AI::FANN->new_from_file($self->{'filename'});
    
    for(0..3)
    {
        #print @$_;
        print "start $_ \n";
        my $out  = $ann->run($$data[$_]);
        print Dumper $out;
        print $$res[$_];

        print "\nend\n";
    }


    die();

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
