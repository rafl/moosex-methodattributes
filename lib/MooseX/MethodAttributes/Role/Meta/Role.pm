package MooseX::MethodAttributes::Role::Meta::Role;
# ABSTRACT: metarole role for storing code attributes

use Moose::Util::MetaRole;
use Moose::Util qw/find_meta does_role ensure_all_roles/;
use Carp qw/croak/;

use Moose::Role;

use MooseX::MethodAttributes ();
use MooseX::MethodAttributes::Role ();

use namespace::clean -except => 'meta';

=head1 SYNOPSIS

    package MyRole;
    use MooseX::MethodAttributes::Role;
    
    sub foo : Bar Baz('corge') { ... }

    package MyClass
    use Moose;

    with 'MyRole';

    my $attrs = MyClass->meta->get_method('foo')->attributes; # ["Bar", "Baz('corge')"]

=head1 DESCRIPTION

This module is a metaclass role which is applied by L<MooseX::MethodAttributes::Role>, allowing
you to add code attributes to methods in Moose roles.

These attributes can then be found by introspecting the role metaclass, and are automatically copied
into any classes or roles that the role is composed onto.

=head1 CAVEATS

=over

=item *

Currently roles with attributes cannot have methods excluded
or aliased, and will in turn confer this property onto any roles they
are composed onto.

=back

=cut

with qw/
    MooseX::MethodAttributes::Role::Meta::Map
    MooseX::MethodAttributes::Role::Meta::Role::Application
/;

has '+composition_class_roles' => (
    default => sub { [ 'MooseX::MethodAttributes::Role::Meta::Role::Application::Summation' ] },
);

=method initialize

Ensures that the package containing the role methods does the
L<MooseX::MethodAttributes::Role::AttrContainer> role during initialisation,
which in turn is responsible for capturing the method attributes on the class
and registering them with the metaclass.

=cut

after 'initialize' => sub {
    my ($self, $class, %args) = @_;
    ensure_all_roles($class, 'MooseX::MethodAttributes::Role::AttrContainer');
};

=method method_metaclass

Wraps the normal method and ensures that the method metaclass performs the
L<MooseX::MethodAttributes::Role::Meta::Method> role, which allows you to
introspect the attributes from the method objects returned by the MOP when
querying the metaclass.

=cut

# FIXME - Skip this logic if the method metaclass already does the right role?
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


sub _copy_attributes {
    my ($self, $thing) = @_;

    push @{ $thing->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $thing->_method_attribute_map }{ (keys(%{ $self->_method_attribute_map }), keys(%{ $thing->_method_attribute_map })) }
        = (values(%{ $self->_method_attribute_map }), values(%{ $thing->_method_attribute_map }));
};

# This allows you to say use Moose::Role -traits => 'MethodAttributes'
# This is replaced by MooseX::MethodAttributes::Role, and this trait registration
# is now only present for backwards compatibility reasons.
package # Hide from PAUSE
    Moose::Meta::Role::Custom::Trait::MethodAttributes;

sub register_implementation { 'MooseX::MethodAttributes::Role::Meta::Role' }

1;

