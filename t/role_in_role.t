{
    package FirstRole;
    use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
    use namespace::clean -except => 'meta';

    our $FOO_CALLED = 0;
    sub foo : Local { $FOO_CALLED++; }
    
    our $BEFORE_FOO_CALLED = 0;
    before 'foo' => sub { $BEFORE_FOO_CALLED++; };
    
    our $BAR_CALLED = 0;
    sub bar : Local { $BAR_CALLED++; }
}
{
    package SecondRole;
    use Moose::Role;
    use namespace::clean -except => 'meta';
    with 'FirstRole';
}
{
    package MyClass;
    use Moose;
    use namespace::clean -except => 'meta';

    with 'SecondRole';

}

use Test::More tests => 21;
use Test::Exception;

{
    my $method = FirstRole->meta->get_method('foo');
    ok $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method'), 'Method metaclass for foo in FirstRole does role';
    
    $method = FirstRole->meta->get_method('bar');
    ok $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method'), 'Method metaclass for bar in FirstRole does role'
}
{
    my $method = SecondRole->meta->get_method('foo');
    ok $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method'), 'Method metaclass for foo in SecondRole does role';
    
    $method = SecondRole->meta->get_method('bar');
    ok $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method'), 'Method metaclass for bar in SecondRole does role'
}
{
    my $method = MyClass->meta->get_method('foo');
    ok $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method'), 'Method metaclass for foo in MyClass does role';
    
    $method = MyClass->meta->get_method('bar');
    ok $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method'), 'Method metaclass for bar in MyClass does role'
}

exit;

{
    my @methods = TestApp::Controller::Moose->meta->get_all_methods_with_attributes;
    my @local_methods = TestApp::Controller::Moose->meta->get_method_with_attributes_list;
    is @methods, 3;
    is @local_methods, 3;
}


{
    my @methods = TestApp::Controller::Moose::MethodModifiers->meta->get_all_methods_with_attributes;
    my @local_methods = TestApp::Controller::Moose::MethodModifiers->meta->get_method_with_attributes_list;
    is @methods, 3;
    is @local_methods, 1;
}

my @methods;
lives_ok {
    @methods = TestApp::Controller::Moose::MethodModifiers->meta->get_nearest_methods_with_attributes;
} 'Can get nearest methods';

is @methods, 3;

my $method = (grep { $_->name eq 'get_attribute' } @methods)[0];
ok $method;
is eval { $method->body }, \&TestApp::Controller::Moose::MethodModifiers::get_attribute;
is $TestApp::Controller::Moose::GET_ATTRIBUTE_CALLED, 0;
is $TestApp::Controller::Moose::MethodModifiers::GET_ATTRIBUTE_CALLED, 0;
is $TestApp::Controller::Moose::GET_FOO_CALLED, 0;
is $TestApp::Controller::Moose::BEFORE_GET_FOO_CALLED, 0;

eval { $method->body->() };
ok !$@ or warn $@;

eval { (grep { $_->name eq 'get_foo' } @methods)[0]->body->(); };
ok !$@ or warn $@;

is $TestApp::Controller::Moose::GET_ATTRIBUTE_CALLED, 1;
is $TestApp::Controller::Moose::MethodModifiers::GET_ATTRIBUTE_CALLED, 1;
is $TestApp::Controller::Moose::GET_FOO_CALLED, 1;
is $TestApp::Controller::Moose::BEFORE_GET_FOO_CALLED, 1;

my $other = (grep { $_->name eq 'other' } @methods)[0];
ok $other;

