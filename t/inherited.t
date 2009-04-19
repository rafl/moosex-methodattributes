use strict;
use warnings;
use Test::More tests => 6;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok 'SubClass'; }
BEGIN { use_ok 'SubClassMoosed'; }

my $meta = SubClass->meta;

my $meta2 = SubClassMoosed->meta;

is_deeply(
    $meta2->get_method('bar')->attributes,
    ['Bar'],
);

is_deeply(
    $meta->get_method('bar')->attributes,
    ['Bar'],
);

is_deeply(
    $meta->find_method_by_name('foo')->attributes,
    ['Foo'],
);

is_deeply(
    [map { [$_->name => $_->attributes] } SubClass->meta->get_all_methods_with_attributes],
    [['affe', ['Birne']],
     ['foo', ['Foo']],
     ['moo', ['Moo']],
     ['bar', ['Bar']]],
);
