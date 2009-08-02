package MooseX::MethodAttributes::Role::AttrContainer::Inheritable;
# ABSTRACT: capture code attributes in the automatically initialized metaclass instance

=head1 DESCRIPTION

This role extends C<MooseX::MethodAttributes::Role::AttrContainer> with the
functionality of automatically initializing a metaclass for the caller and
applying the meta roles relevant for capturing method attributes.

=cut

use Moose::Role;
use MooseX::MethodAttributes ();

use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::AttrContainer';

before MODIFY_CODE_ATTRIBUTES => sub {
    my ($class, $code, @attrs) = @_;
    return unless @attrs;
	MooseX::MethodAttributes->init_meta( for_class => $class );
};

1;

