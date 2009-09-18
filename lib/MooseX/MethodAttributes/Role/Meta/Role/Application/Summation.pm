package MooseX::MethodAttributes::Role::Meta::Role::Application::Summation;
use Moose::Role;
use Moose::Util qw/does_role/;
use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::Meta::Role::Application';

sub _copy_attributes {
    my ($self, $thing) = @_;
    for my $role (@{ $self->get_roles }) {
        $role->_copy_attributes($thing)
            if does_role($role, 'MooseX::MethodAttributes::Role::Meta::Role');
    }
}

1;
