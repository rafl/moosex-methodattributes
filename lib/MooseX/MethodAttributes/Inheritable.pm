package MooseX::MethodAttributes::Inheritable;
# ABSTRACT: inheritable code attribute introspection

=head1 SYNOPSIS

    package BaseClass;
    use base qw/MooseX::MethodAttributes::Inheritable/;

    package SubClass;
    use base qw/SubClass/;

    sub foo : Bar {}

    my $attrs = SubClass->meta->get_method('foo')->attributes; # ["Bar"]

=head1 DESCRIPTION

This module does the same as C<MooseX::MethodAttributes>, except that classes
inheriting from other classes using it don't need to do anything special to get
their code attributes captured.

=cut

use Moose;

use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::AttrContainer::Inheritable';

__PACKAGE__->meta->make_immutable;

1;
