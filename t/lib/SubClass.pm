use strict;
use warnings;

package SubClass;

use base qw/BaseClass/;

sub bar : Bar {}

use Moose;
before affe => sub {};
no Moose;

1;
