package MooseX::MethodAttributes::Role::AttrContainer;
# ABSTRACT: Capture code attributes in the class' metaclass

use Moose::Role;
use Moose::Util qw/find_meta/;

use namespace::clean -except => 'meta';

sub MODIFY_CODE_ATTRIBUTES {
    my ($class, $code, @attrs) = @_;
    find_meta($class)->_attributes_for->{0 + $code} = \@attrs;
    return ();
}

1;
