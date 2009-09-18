package MooseX::MethodAttributes::Role::Meta::Map;
# ABSTRACT: generic role for storing code attributes used by classes and roles with attributes

use Moose::Role;
use MooseX::Types::Moose qw/HashRef ArrayRef Str Int/;

use namespace::clean -except => 'meta';

has _method_attribute_map => (
    is        => 'ro',
    isa       => HashRef[ArrayRef[Str]],
    lazy      => 1,
    default   => sub { +{} },
);

has _method_attribute_list => (
    is      => 'ro',
    isa     => ArrayRef[Int],
    lazy    => 1,
    default => sub { [] },
);

=method register_method_attributes ($code, $attrs)

Register a list of attributes for a code reference.

=cut

sub register_method_attributes {
    my ($self, $code, $attrs) = @_;
    push @{ $self->_method_attribute_list }, 0 + $code;
    $self->_method_attribute_map->{ 0 + $code } = $attrs;
    return;
}

=method get_method_attributes ($code)

Get a list of attributes associated with a coderef.

=cut

sub get_method_attributes {
    my ($self, $code) = @_;
    return $self->_method_attribute_map->{ 0 + $code } || [];
}

1;

