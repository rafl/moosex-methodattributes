use strict;
use warnings;

package BaseClass::Meta::Role;
use Moose::Role;

package BaseClass;

use Moose;
BEGIN { extends qw/MooseX::MethodAttributes::Inheritable/; }

use Moose::Util::MetaRole;
Moose::Util::MetaRole::apply_metaclass_roles(
    for_class => __PACKAGE__,
    metaclass_roles => [qw/ BaseClass::Meta::Role /],
);

sub moo : Moo {}

sub affe : Birne {}

sub foo : Foo {}

sub bar : Baz {}

{
    no warnings 'redefine';
    sub moo : Moo {}
}

1;
