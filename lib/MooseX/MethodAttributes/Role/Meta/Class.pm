package MooseX::MethodAttributes::Role::Meta::Class;

use Moose::Role;
use MooseX::Types::Moose qw/HashRef/;

use namespace::clean -except => 'meta';

has _attributes_for => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    default => sub { +{} },
);

1;
