use strict;
use warnings;
use Test::More;

{
    package Foo;
    use Moose::Role;
    sub role_method {}
}

{
    package BaseClass;
    use Moose;
    BEGIN { extends 'MooseX::MethodAttributes::Inheritable' }
}

TODO: {
    package Bar;
    use Test::More;
    BEGIN { $TODO = "Known broken" }
    use Moose;
    BEGIN { ::ok(!Bar->meta->has_method('role_method')) }
    BEGIN { ::ok(!Bar->can('role_method')) }
    BEGIN { extends 'BaseClass'; with 'Foo' }
    BEGIN { ::ok( Bar->meta->has_method('role_method')) }
    BEGIN { ::ok( Bar->can('role_method')) }
    use namespace::autoclean;
    BEGIN { ::ok( Bar->meta->has_method('role_method')) }
    BEGIN { ::ok( Bar->can('role_method')) }
    sub foo : Bar {}
    BEGIN { ::ok( Bar->meta->has_method('role_method')) }
    BEGIN { ::ok( Bar->can('role_method')) }
    ::ok( Bar->meta->has_method('role_method'));
    ::ok( Bar->can('role_method'));
}

done_testing;
