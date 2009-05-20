package MooseX::MethodAttributes::Role::Meta::Role;
# ABSTRACT: metarole role for storing code attributes

use Moose::Util::MetaRole;
use Moose::Util qw/find_meta ensure_all_roles/;
use Carp qw/croak/;

use Moose::Role;

use namespace::clean -except => 'meta';

=head1 SYNOPSIS

    package MyRole;
    use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

    sub foo : Bar Baz('corge') { ... }

    package MyClass
    use Moose;

    with 'MyRole';

    my $attrs = MyClass->meta->get_method('foo')->attributes; # ["Bar", "Baz('corge')"]

=head1 DESCRIPTION

This module allows you to add code attributes to methods in Moose roles.

These attributes can then be found later once the methods are composed
into a class.

=cut

with qw/
    MooseX::MethodAttributes::Role::Meta::Map
/;

after 'initialize' => sub {
    my ($self, $class, %args) = @_;
    ensure_all_roles($class, 'MooseX::MethodAttributes::Role::AttrContainer');
};

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

around 'apply' => sub {
    my ($orig, $self, $thing) = @_;
    if ($thing->isa('Moose::Meta::Class')) {
        Moose::Util::MetaRole::apply_metaclass_roles(
            for_class => $thing->name,
            metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Class'],
            method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method'],
            wrapped_method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped'],
        );
    }
    elsif ($thing->isa('Moose::Meta::Role')) {
        Moose::Util::MetaRole::apply_metaclass_roles(
            for_class       => $thing->name,
            metaclass_roles => [ __PACKAGE__ ],
        );
        ensure_all_roles($thing->name, 
            'MooseX::MethodAttributes::Role::AttrContainer',
        );
    }
    else {
        croak("Composing " . __PACKAGE__ . " onto instances is unsupported");
    }
    
    # Note that the metaclass instance we started out with may have been turned
    # into lies by the role application process, so we explicitly re-fetch it
    # here.
    my $meta = find_meta($thing->name);

    my $ret = $self->$orig($meta);

    push @{ $meta->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $meta->_method_attribute_map }{ keys(%{ $self->_method_attribute_map }) }
        = values %{ $self->_method_attribute_map };

    return $ret;
};

1;

