<?php

print "start\n";


$json_array = "{
    'Lisa Rose': {'Lady in the Water': 2.5, 'Snakes on a Plane': 3.5,
    'Just My Luck': 3.0, 'Superman Returns': 3.5, 'You, Me and Dupree': 2.5, 
    'The Night Listener': 3.0},

    'Gene Seymour': {'Lady in the Water': 3.0, 'Snakes on a Plane': 3.5, 
    'Just My Luck': 1.5, 'Superman Returns': 5.0, 'The Night Listener': 3.0, 
    'You, Me and Dupree': 3.5}, 

    'Michael Phillips': {'Lady in the Water': 2.5, 'Snakes on a Plane': 3.0,
    'Superman Returns': 3.5, 'The Night Listener': 4.0},

    'Claudia Puig': {'Snakes on a Plane': 3.5, 'Just My Luck': 3.0,
    'The Night Listener': 4.5, 'Superman Returns': 4.0, 
    'You, Me and Dupree': 2.5},

    'Mick LaSalle': {'Lady in the Water': 3.0, 'Snakes on a Plane': 4.0, 
    'Just My Luck': 2.0, 'Superman Returns': 3.0, 'The Night Listener': 3.0,
    'You, Me and Dupree': 2.0}, 

    'Jack Matthews': {'Lady in the Water': 3.0, 'Snakes on a Plane': 4.0,
    'The Night Listener': 3.0, 'Superman Returns': 5.0, 'You, Me and Dupree': 3.5},

    'Toby': {'Snakes on a Plane':4.5,'You, Me and Dupree':1.0,'Superman Returns':4.0}
   } ";


$t = json_decode($json_array);

#print $json_array;

#$film = 'Snakes on a Plane';
#print_r($t->Toby->$film);

function evclid($name1, $name2, $film1, $film2, $t)
{
    $res =  sqrt( 
	pow($t->$name1->$film1 - $t->$name2->$film1,2 )
	+ pow ($t->$name1->$film2 - $t->$name2->$film2,2)
    );

    #return 1/(1+$res);
    return $res;
}



print evclid('Toby','Mick LaSalle', 'Snakes on a Plane','You, Me and Dupree', $t);
print "\n";
print evclid('Lisa Rose','Claudia Puig', 'Snakes on a Plane','You, Me and Dupree', $t);


print "\nend \n";
