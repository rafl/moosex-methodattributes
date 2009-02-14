use strict;
use warnings;

package BaseClass;

use Moose;
BEGIN { extends qw/MooseX::MethodAttributes::Inheritable/; }

sub foo : Foo {}

1;
