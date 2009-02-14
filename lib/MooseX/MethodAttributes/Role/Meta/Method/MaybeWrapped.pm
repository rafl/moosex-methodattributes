package MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped;

use Moose::Role;
use Moose::Util qw/does_role/;
use MooseX::MethodAttributes::Role::Meta::Method::Wrapped;

use namespace::clean -except => 'meta';

override wrap => sub {
    my $self = super;
    if (does_role($self->get_original_method, 'MooseX::MethodAttributes::Role::Meta::Method')) {
        MooseX::MethodAttributes::Role::Meta::Method::Wrapped->meta->apply($self);
    }
    return $self;
};

1;
