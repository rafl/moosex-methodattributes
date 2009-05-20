use strict;
use warnings;

{
    package FirstRole;
    use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
    use namespace::clean -except => 'meta';

    our $FOO_CALLED = 0;
    sub foo : Local { $FOO_CALLED++; }
    
    our $BAR_CALLED = 0;
    sub bar : Local { $BAR_CALLED++; }

    our $BEFORE_BAR_CALLED = 0;
    before 'bar' => sub { $BEFORE_BAR_CALLED++; };

    our $BAZ_CALLED = 0;
    sub baz : Local { $BAZ_CALLED++; }

    our $QUUX_CALLED = 0;
    sub quux : Local { $QUUX_CALLED++; }
}
{
    package SecondRole;
    use Moose::Role;
    use namespace::clean -except => 'meta';
    with 'FirstRole';
    our $BEFORE_BAZ_CALLED = 0;
    before 'baz' => sub { $BEFORE_BAZ_CALLED++ };
}
{
    package MyClass;
    use Moose;
    use namespace::clean -except => 'meta';

    with 'SecondRole';
    our $BEFORE_QUUX_CALLED = 0;
    before 'quux' => sub { $BEFORE_QUUX_CALLED++; };
}

use Test::More tests => 23;
use Test::Exception;

my @method_names = qw/foo bar baz quux/;

foreach my $class (qw/FirstRole SecondRole MyClass/) {
    foreach my $method_name (@method_names) {
        my $method = $class->meta->get_method($method_name);
        ok(
            (
                $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method')
                or $method->meta->does_role('MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped')
            ), 
            sprintf(
                'Method metaclass for %s in %s does role'
                => $method_name, $class
            )
        );
    }   
}

foreach my $method_name (@method_names) {
    lives_ok {
        MyClass->$method_name();
    } "Call $method_name method";
}

is $FirstRole::FOO_CALLED, 1, '->foo called once';
is $FirstRole::BAR_CALLED, 1, '->bar called once';
is $FirstRole::BAZ_CALLED, 1, '->baz called once';
is $FirstRole::QUUX_CALLED, 1, '->quux called once';

is $FirstRole::BEFORE_BAR_CALLED, 1, 'modifier for ->bar called once';
is $SecondRole::BEFORE_BAZ_CALLED, 1, 'modifier for ->baz called once';
is $MyClass::BEFORE_QUUX_CALLED, 1, 'modifier for ->quux called once';

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

