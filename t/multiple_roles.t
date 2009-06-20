#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 5;

use MooseX::MethodAttributes ();

use UsesMultipleRoles;

my $meta = UsesMultipleRoles->meta;

my $foo = $meta->get_method('foo');
ok $foo, 'Got foo method';

my $bar = $meta->get_method('bar');
ok $bar, 'Got bar method';

SKIP: {
    ok $meta->can('get_method_attributes')
        or skip 'Cannot call get_method_attributes method on class', 2;

    my @foo_attrs = $meta->get_method_attributes($foo->body);
    ok @foo_attrs;

    my @bar_attrs = $meta->get_method_attributes($bar->body);
    ok @bar_attrs;
}

