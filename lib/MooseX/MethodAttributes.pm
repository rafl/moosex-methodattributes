use strict;
use warnings;

package MooseX::MethodAttributes;
# ABSTRACT: code attribute introspection

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

=head1 SYNOPSIS

    package MyClass;

    use Moose;
    use MooseX::MethodAttributes;

    sub foo : Bar Baz('corge') { ... }

    my $attrs = MyClass->meta->get_method('foo')->attributes; # ["Bar", "Baz('corge')"]

=head1 DESCRIPTION

This module allows code attributes of methods to be introspected using the
Moose meta method objects.

=cut

Moose::Exporter->setup_import_methods;

sub init_meta {
    my ($class, %options) = @_;
    my $meta = Moose->init_meta(%options);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class              => $options{for_class},
        metaclass_roles        => ['MooseX::MethodAttributes::Role::Meta::Class'],
        method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method'],
    );
    Moose::Util::MetaRole::apply_base_class_roles(
        for_class => $options{for_class},
        roles     => ['MooseX::MethodAttributes::Role::AttrContainer'],
    );
    return $meta;
}

1;
