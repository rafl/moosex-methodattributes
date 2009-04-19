use strict;
use warnings;

package SubClassMoosed;

use base qw/BaseClass/;

use Moose;

sub bar : Bar {}

before affe => sub {};
no Moose;

1;
