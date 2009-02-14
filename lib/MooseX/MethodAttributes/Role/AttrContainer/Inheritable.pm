package MooseX::MethodAttributes::Role::AttrContainer::Inheritable;

use Moose::Role;
use Moose::Util::MetaRole;
use Moose::Util qw/find_meta/;

use namespace::clean -except => 'meta';

with 'MooseX::MethodAttributes::Role::AttrContainer';

before MODIFY_CODE_ATTRIBUTES => sub {
    my ($class) = @_;
    return if find_meta($class);
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class                      => $class,
        metaclass_roles                => ['MooseX::MethodAttributes::Role::Meta::Class'],
        method_metaclass_roles         => ['MooseX::MethodAttributes::Role::Meta::Method'],
        wrapped_method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method::Wrapped'],
    );
};

1;
