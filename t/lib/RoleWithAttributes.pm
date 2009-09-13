package RoleWithAttributes;
use Moose::Role;
use MooseX::MethodAttributes::Role;
use namespace::clean -except => 'meta';

sub foo : AnAttr { 'foo' }

1;

