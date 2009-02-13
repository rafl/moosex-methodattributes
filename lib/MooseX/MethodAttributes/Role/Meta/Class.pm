package MooseX::MethodAttributes::Role::Meta::Class;
# ABSTRACT: metaclass role for storing code attributes

use Moose::Role;
use MooseX::Types::Moose qw/HashRef/;

use namespace::clean -except => 'meta';

has _method_attribute_map => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    default => sub { +{} },
);

=method register_method_attributes ($code, $attrs)

Register a list of attributes for a code reference.

=cut

sub register_method_attributes {
    my ($self, $code, $attrs) = @_;
    $self->_method_attribute_map->{ 0 + $code } = $attrs;
    return;
}

=method get_method_attributes ($code)

Get a list of attributes associated with a coderef.

=cut

sub get_method_attributes {
    my ($self, $code) = @_;
    return $self->_method_attribute_map->{ 0 + $code };
}

1;
