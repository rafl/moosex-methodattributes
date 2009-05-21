package RoleWithAttributes;
use Moose::Role -traits => 'MethodAttributes';
use namespace::clean -except => 'meta';

sub foo : AnAttr { 'foo' }

1;

