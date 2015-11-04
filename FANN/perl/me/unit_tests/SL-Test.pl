#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: SL-Test.pl
#
#        USAGE: ./SL-Test.pl  
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
#      CREATED: 03.11.2015 17:10:31
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use base qw(Test::Class);
use Test::More 'no_plan';;

use lib '../';


Test::Class->runtests;
