use strict;
use warnings;

package BaseClass;

use base qw/MooseX::MethodAttributes::Inheritable/;

sub foo : Foo {}

1;
