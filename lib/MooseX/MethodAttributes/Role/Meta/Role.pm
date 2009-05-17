package MooseX::MethodAttributes::Role::Meta::Role;
# ABSTRACT: metarole role for storing code attributes

use Moose::Util::MetaRole;
use Moose::Util qw/find_meta/;
use Carp qw/croak/;

use Moose::Role;

use namespace::clean -except => 'meta';

with qw/
    MooseX::MethodAttributes::Role::Meta::Map
/;

around method_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig(@_) if scalar @_;
    Moose::Meta::Class->create_anon_class(
        superclasses => [ $self->$orig ],
        roles        => [qw/
            MooseX::MethodAttributes::Role::Meta::Method
        /],
        cache        => 1,
    )->name();
};

before 'apply' => sub {
    my ($self, $thing) = @_;
    if ($thing->isa('Moose::Meta::Class')) {
        Moose::Util::MetaRole::apply_metaclass_roles(
            for_class => $thing->name,
            metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Class'],
            method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method'],
            wrapped_method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped'],
        );
    }
    elsif ($thing->isa('Moose::Meta::Role')) {
        # No need to interfere with normal composition
    }
    else {
        croak("Composing " . __PACKAGE__ . " onto instances is unsupported");
    }
};

after 'apply' => sub {
    my ($self, $thing) = @_;
    # Note that the metaclass instance we started out with may have been turned
    # into lies by the role application process, so we explicitly re-fetch it
    # here.
    my $meta = find_meta($thing->name);
    push @{ $meta->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $meta->_method_attribute_map }{ keys(%{ $self->_method_attribute_map }) }
        = values %{ $self->_method_attribute_map };
};

1;

