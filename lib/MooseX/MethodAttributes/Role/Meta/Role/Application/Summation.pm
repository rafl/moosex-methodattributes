package MooseX::MethodAttributes::Role::Meta::Role::Application::Summation;
use Moose::Role;
use namespace::clean -except => 'meta';

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;
    warn("Am being applied to " . $thing->name);
    $self->MooseX::MethodAttributes::Role::Meta::Role::_around_apply($orig, $thing, %opts);
};

sub _method_attribute_list { [] }

sub _method_attribute_map { {} }

1;
