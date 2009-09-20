package RoleWithAttributes;
use MooseX::MethodAttributes::Role;
use namespace::clean -except => 'meta';

sub foo : AnAttr { 'foo' }

sub bar {}

after 'bar' => sub {}; # Just test we get the Moose::Role sugar

1;

