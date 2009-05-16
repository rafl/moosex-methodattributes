package MooseX::MethodAttributes::Role::Meta::Role;
# ABSTRACT: metarole role for storing code attributes

use Moose::Role;

use namespace::clean -except => 'meta';

with qw/
    MooseX::MethodAttributes::Role::Meta::Map
/;

1;

