use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 1;

use BaseClass;

BaseClass->affe;
is(BaseClass::no_calls_to_affe(), 1);

