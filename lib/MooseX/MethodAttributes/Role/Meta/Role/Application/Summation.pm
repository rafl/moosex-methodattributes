package MooseX::MethodAttributes::Role::Meta::Role::Application::Summation;
use Moose::Role;
use Moose::Util qw/does_role/;
use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::Meta::Role::Application';

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;
    $thing = $self->MooseX::MethodAttributes::Role::Meta::Role::_apply_metaclasses($thing);
    my $ret = $self->$orig($thing);

    for my $role (@{ $self->get_roles }) {
        $role->_copy_attributes($thing)
            if does_role($role, 'MooseX::MethodAttributes::Role::Meta::Role');
    }

    return $ret;
     
};

1;
