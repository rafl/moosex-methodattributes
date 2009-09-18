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
    use Moose::Role -traits => 'MethodAttributes';

    sub foo : Bar Baz('corge') { ... }

    package MyClass
    use Moose;

    with 'MyRole';

    my $attrs = MyClass->meta->get_method('foo')->attributes; # ["Bar", "Baz('corge')"]

=head1 DESCRIPTION

This module allows you to add code attributes to methods in Moose roles.

These attributes can then be found later once the methods are composed
into a class.

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
    default => [ 'MooseX::MethodAttributes::Role::Meta::Role::Application::Summation' ],
);

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
    my ($orig, $self, $thing, %opts) = @_;
    die("MooseX::MethodAttributes does not currently support method exclusion or aliasing.")
        if ($opts{alias} or $opts{exclude});
    $thing = $self->_apply_metaclasses($thing);
    my $ret = $self->$orig($thing, %opts);
    $self->_copy_attributes($thing);
    return $ret;
};

#requires qw/
#    _method_attribute_list
#    _method_attribute_map
#/;

sub _copy_attributes {
    my ($self, $thing) = @_;

    push @{ $thing->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $thing->_method_attribute_map }{ (keys(%{ $self->_method_attribute_map }), keys(%{ $thing->_method_attribute_map })) }
        = (values(%{ $self->_method_attribute_map }), values(%{ $thing->_method_attribute_map }));
};

package # Hide from PAUSE
    Moose::Meta::Role::Custom::Trait::MethodAttributes;

sub register_implementation { 'MooseX::MethodAttributes::Role::Meta::Role' }

1;

