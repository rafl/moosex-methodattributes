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
        );
    }
    elsif ($thing->isa('Moose::Meta::Role')) {
        # No need to interfear with normal composition
    }
    else {
        croak("Composing " . __PACKAGE__ . " onto instances is unsupported");
    }
    my $meta = find_meta($thing->name);
    push @{ $meta->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $meta->_method_attribute_map }{ keys(%{ $self->_method_attribute_map }) }
        = values %{ $self->_method_attribute_map };
};

1;

