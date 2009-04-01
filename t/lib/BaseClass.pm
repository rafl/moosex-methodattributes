use strict;
use warnings;

package BaseClass::Meta::Role;
use Moose::Role;

package BaseClass;

use Moose;
use Moose::Util::MetaRole;
BEGIN { 
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class => __PACKAGE__,
        metaclass_roles => [qw/ BaseClass::Meta::Role /],
    );

    extends qw/MooseX::MethodAttributes::Inheritable/;
}

sub moo : Moo {}

sub affe : Birne {}

sub foo : Foo {}

sub bar : Baz {}

{
    no warnings 'redefine';
    sub moo : Moo {}
}

1;
