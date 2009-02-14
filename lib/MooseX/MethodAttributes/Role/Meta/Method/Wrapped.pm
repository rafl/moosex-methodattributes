package MooseX::MethodAttributes::Role::Meta::Method::Wrapped;

use Moose::Role;

use namespace::clean -except => 'meta';

sub attributes {
    my ($self) = @_;
    return $self->get_original_method->attributes;
}

1;
