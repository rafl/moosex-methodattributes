package MooseX::MethodAttributes::Role::Meta::Method;

use Moose::Role;

use namespace::clean -except => 'meta';

has attributes => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_attributes',
);

sub _build_attributes {
    my ($self) = @_;
    return delete $self->associated_metaclass->attributes_for->{ 0 + $self->body };
}

1;
