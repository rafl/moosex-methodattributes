package MooseX::MethodAttributes::Role::Meta::Method;
# ABSTRACT: metamethod role allowing code attribute introspection

use Moose::Role;

use namespace::clean -except => 'meta';

=attr attributes

Gets the list of code attributes of the method represented by this meta method.

=cut

has attributes => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_attributes',
);

=method _build_attributes

Builds the value of the C<attributes> attribute based on the attributes
captured in the associated meta class.

=cut

sub _build_attributes {
    my ($self) = @_;
    return delete $self->associated_metaclass->_method_attribute_map->{ 0 + $self->body };
}

1;
