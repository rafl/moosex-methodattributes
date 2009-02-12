use strict;
use warnings;
use Test::More tests => 1;

use FindBin;
use lib "$FindBin::Bin/lib";

use TestClass;

my $meta = TestClass->meta;
is_deeply(
    $meta->get_method('foo')->attributes,
    [q{SomeAttribute}, q{AnotherAttribute('with argument')}],
);
