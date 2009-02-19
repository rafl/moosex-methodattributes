use strict;
use warnings;

package BaseClass;

use Moose;
BEGIN { extends qw/MooseX::MethodAttributes::Inheritable/; }

sub moo : Moo {}

sub foo : Foo {}

sub bar : Baz {}

{
    no warnings 'redefine';
    sub moo : Moo {}
}

1;
