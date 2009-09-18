use strict;
use warnings;

{
    package Catalyst::Controller;
    use Moose;
    use namespace::clean -except => 'meta';
    use MooseX::MethodAttributes;
    BEGIN { extends 'MooseX::MethodAttributes::Inheritable'; }
}

{
    package ControllerRole;
    use Moose::Role -traits => 'MethodAttributes';
    use namespace::clean -except => 'meta';

    sub excluded : Local {}
}
{
    package roles::Controller::Foo;
    use Moose;
    BEGIN { extends 'Catalyst::Controller'; }

    use Test::Exception;
    with 'ControllerRole' => { -excludes => 'not_attributed' };
}

use Test::More tests => 1;

my $meta = roles::Controller::Foo->meta;
TODO: {
    local $TODO = 'Aliasing and exclusion does not work';
    ok !$meta->get_method('excluded');
}
