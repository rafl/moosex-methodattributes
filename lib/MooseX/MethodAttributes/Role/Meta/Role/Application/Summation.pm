package MooseX::MethodAttributes::Role::Meta::Role::Application::Summation;
use Moose::Role;
use Moose::Util qw/does_role/;
use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::Meta::Role::Application';

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;
    $thing = $self->_apply_metaclasses($thing);

    my $ret = $self->$orig($thing);

    $self->_copy_attributes($thing);

    return $ret;
     
};

sub _copy_attributes {
    my ($self, $thing) = @_;
    for my $role (@{ $self->get_roles }) {
        $role->_copy_attributes($thing)
            if does_role($role, 'MooseX::MethodAttributes::Role::Meta::Role');
    }
}

1;
