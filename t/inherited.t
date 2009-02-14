use strict;
use warnings;
use Test::More tests => 4;
use Moose::Util qw/does_role/;

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN { use_ok 'SubClass'; }

my $meta = SubClass->meta;
my @attr_methods = grep { does_role($_, 'MooseX::MethodAttributes::Role::Meta::Method') } $meta->get_all_methods;

is_deeply(
    [sort map { $_->name } @attr_methods],
    [qw/bar foo/],
);

is_deeply(
    $meta->get_method('bar')->attributes,
    ['Bar'],
);

is_deeply(
    $meta->find_method_by_name('foo')->attributes,
    ['Foo'],
);
