package MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped;
# ABSTRACT: proxy attributes of wrapped methods if their metaclass supports it

use Moose::Role;
use Moose::Util qw/does_role/;
use MooseX::MethodAttributes::Role::Meta::Method::Wrapped;

use namespace::clean -except => 'meta';

override wrap => sub {
    my $self = super;
    my $original_method = $self->get_original_method;
    if (
        does_role($original_method, 'MooseX::MethodAttributes::Role::Meta::Method')
        || does_role($original_method, 'MooseX::MethodAttributes::Role::Meta::Method::Wrapped')
    ) {
        MooseX::MethodAttributes::Role::Meta::Method::Wrapped->meta->apply($self);
    }
    return $self;
};

1;
