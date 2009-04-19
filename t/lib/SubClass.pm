use strict;
use warnings;

package SubClass;

use Moose;
BEGIN { extends 'BaseClass'; }

sub bar : Bar {}

before affe => sub {};
no Moose;

1;
