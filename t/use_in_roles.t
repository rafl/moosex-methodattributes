use strict;
use warnings;
use Test::More tests => 2;

eval q{
    package FooBarBaz;
    use Moose::Role;
    use MooseX::MethodAttributes;
};
ok !$@;

eval q{
    package FooBarBazQuux;
    use Moose::Role;
    use MooseX::MethodAttributes;

    sub foo : Bar { }
};
ok !$@;

