package MooseX::MethodAttributes::Role::Meta::Role::Application;
# ABSTRACT: generic role for applying a role with method attributes to something

use Moose::Role;
use namespace::clean -except => 'meta';

sub _copy_attributes {
    my ($self, $thing) = @_;

    push @{ $thing->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $thing->_method_attribute_map }{ (keys(%{ $self->_method_attribute_map }), keys(%{ $thing->_method_attribute_map })) }
        = (values(%{ $self->_method_attribute_map }), values(%{ $thing->_method_attribute_map }));
};

1;
