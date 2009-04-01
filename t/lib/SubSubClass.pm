use strict;
use warnings;

package SubSubClass;

use base qw/OtherSubClass/;

sub bar : Quux {}

1;
