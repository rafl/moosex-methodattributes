use strict;
use warnings;
use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/lib";

use TestClass;

is_deeply( TestClass->meta->get_method('bar')->attributes,
    [q{SomeAttribute}], );

is_deeply( SubClass->meta->get_method('bar')->attributes, [], );
