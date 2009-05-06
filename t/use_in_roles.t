use strict;
use warnings;
use Test::More tests => 2;
use Test::Exception;

lives_ok {
    package FooBarBaz;
    use Moose::Role;
    use MooseX::MethodAttributes;
};

lives_ok {
    package FooBarBazQuux;
    use Moose::Role;
    use MooseX::MethodAttributes;

    sub foo : Bar { }
};

