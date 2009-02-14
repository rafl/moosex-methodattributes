package MooseX::MethodAttributes::Inheritable;

use Moose;

use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::AttrContainer::Inheritable';

__PACKAGE__->meta->make_immutable;

1;
