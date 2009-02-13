package MooseX::MethodAttributes::Role::Meta::Class;
# ABSTRACT: metaclass role for storing code attributes

use Moose::Role;
use MooseX::Types::Moose qw/HashRef/;

use namespace::clean -except => 'meta';

=attr _method_attribute_map

Stores a HashRef holding the attributes for methods that already have been
parsed. Keyed by the reference address of the methods coderefs.

Entries in that hash get removed by
C<MooseX::MethodAttributes::Role::Meta::Method> when constructing the
C<attributes> attribute.

=cut

has _method_attribute_map => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    default => sub { +{} },
);

1;
