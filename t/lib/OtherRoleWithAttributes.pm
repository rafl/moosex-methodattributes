package OtherRoleWithAttributes;
use MooseX::MethodAttributes::Role;
use namespace::clean -except => 'meta';

sub bar : AnAttr { 'bar' }

1;

