#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Moose::Util qw/does_role/;

use Test::More tests => 4;

use ClassUsingRoleWithAttributes;

my $meta = ClassUsingRoleWithAttributes->meta;
isa_ok($meta, 'Moose::Meta::Class');
ok does_role($meta, 'MooseX::MethodAttributes::Role::Meta::Class'),
    'metaclass does the role for metaclasses with attribute decorated methods';

my $foo = $meta->get_method('foo');
ok $foo, 'Got foo method';
ok does_role($foo, 'MooseX::MethodAttributes::Role::Meta::Method'),
    'foo method meta instance does the attribute decorated method role';

