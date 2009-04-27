{
    package Catalyst::Controller;
    use Moose;
    use namespace::clean -except => 'meta';
    use MooseX::MethodAttributes;
    BEGIN { extends 'MooseX::MethodAttributes::Inheritable'; }
}
{
    package TestApp::Controller::Moose;
    use Moose;
    use namespace::clean -except => 'meta';
    BEGIN { extends qw/Catalyst::Controller/; }

    our $GET_ATTRIBUTE_CALLED = 0;
    our $BEFORE_GET_ATTRIBUTE_CALLED = 0;
    sub get_attribute : Local { $GET_ATTRIBUTE_CALLED++ }
    before 'get_attribute' => sub { $BEFORE_GET_ATTRIBUTE_CALLED++ };

    sub other : Local {}
}
{
    package TestApp::Controller::Moose::MethodModifiers;
    use Moose;
    BEGIN { extends qw/TestApp::Controller::Moose/; }
    # Do not put any methods with attributes in this package.
    our $GET_ATTRIBUTE_CALLED = 0;
    after get_attribute => sub { $GET_ATTRIBUTE_CALLED++; }; # Wrapped only, should show up

    after other => sub {}; # Wrapped, wrapped should show up.
}

use Test::More tests => 15;
use Test::Exception;
use Moose::Util qw/does_role/;

my @base_class_methods = TestApp::Controller::Moose->meta->get_nearest_methods_with_attributes;

is @base_class_methods, 2;
ok does_role(TestApp::Controller::Moose->meta, 'MooseX::MethodAttributes::Role::Meta::Class');
ok does_role(TestApp::Controller::Moose::MethodModifiers->meta, 'MooseX::MethodAttributes::Role::Meta::Class');

my @methods;
lives_ok {
    @methods = TestApp::Controller::Moose::MethodModifiers->meta->get_nearest_methods_with_attributes;
} 'Can get nearest methods';

is @methods, 2;

my $method = (grep { $_->name eq 'get_attribute' } @methods)[0];
ok $method;
is eval { $method->body }, \&TestApp::Controller::Moose::MethodModifiers::get_attribute;
is $TestApp::Controller::Moose::GET_ATTRIBUTE_CALLED, 0;
is $TestApp::Controller::Moose::BEFORE_GET_ATTRIBUTE_CALLED, 0;
is $TestApp::Controller::Moose::MethodModifiers::GET_ATTRIBUTE_CALLED, 0;
eval { $method->body->(); };
ok !$@;
is $TestApp::Controller::Moose::GET_ATTRIBUTE_CALLED, 1;
is $TestApp::Controller::Moose::BEFORE_GET_ATTRIBUTE_CALLED, 1;
is $TestApp::Controller::Moose::MethodModifiers::GET_ATTRIBUTE_CALLED, 1;

my $other = (grep { $_->name eq 'other' } @methods)[0];
ok $other;

