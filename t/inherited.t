use strict;
use warnings;
use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok 'SubClass'; }

my $meta = SubClass->meta;

is_deeply(
    $meta->get_method('bar')->attributes,
    ['Bar'],
);

is_deeply(
    $meta->find_method_by_name('foo')->attributes,
    ['Foo'],
);
