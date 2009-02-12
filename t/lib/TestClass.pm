package TestClass;

use Moose;
use MooseX::MethodAttributes;

sub foo : SomeAttribute AnotherAttribute('with argument') {}

package SubClass;

use Moose;
use MooseX::MethodAttributes;

extends qw/TestClass/;

sub foo : Attributes Attributes Attributes {}

1;
