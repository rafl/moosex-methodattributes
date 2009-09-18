package MooseX::MethodAttributes::Role::Meta::Role::Application::Summation;
use Moose::Role;
use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::Meta::Role::Application';

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;
    $thing = $self->MooseX::MethodAttributes::Role::Meta::Role::_apply_metaclasses($thing);
    my $ret = $self->$orig($thing);

    for my $role (@{ $self->get_roles }) {
        $role->MooseX::MethodAttributes::Role::Meta::Role::_copy_attributes($thing)
            if $role->can('_method_attribute_list');
    }

    return $ret;
     
};

1;
