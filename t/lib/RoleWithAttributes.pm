package RoleWithAttributes;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use namespace::clean -except => 'meta';

BEGIN { with 'MooseX::MethodAttributes::Role::AttrContainer' };

sub foo : AnAttr { 'foo' }

1;

