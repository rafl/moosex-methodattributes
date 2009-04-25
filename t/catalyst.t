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
    use MooseX::MethodAttributes;
    use namespace::clean -except => 'meta';
    BEGIN { extends qw/Catalyst::Controller/; }

    our $GET_ATTRIBUTE_CALLED = 0;
    sub get_attribute : Local { $GET_ATTRIBUTE_CALLED++ }

    sub other : Local {}
}
{
    package TestApp::Controller::Moose::MethodModifiers;
    use Moose;
    use MooseX::MethodAttributes;
    BEGIN { extends qw/TestApp::Controller::Moose/; }

    our $GET_ATTRIBUTE_CALLED = 0;
    after get_attribute => sub { $GET_ATTRIBUTE_CALLED++; }; # Wrapped only, should show up

    sub other : Local {}
    after other => sub {}; # Wrapped, wrapped should show up.
}

use Test::More tests => 9;
use Test::Exception;

my @methods;
lives_ok {
    @methods = TestApp::Controller::Moose::MethodModifiers->meta->get_nearest_methods_with_attributes;
} 'Can get nearest methods';

is @methods, 2;

my $method = (grep { $_->name eq 'get_attribute' } @methods)[0];
ok $method;
is $method->body, \&TestApp::Controller::Moose::MethodModifiers::get_attribute;
is $TestApp::Controller::Moose::GET_ATTRIBUTE_CALLED, 0;
is $TestApp::Controller::Moose::MethodModifiers::GET_ATTRIBUTE_CALLED, 0;
$method->body->();
is $TestApp::Controller::Moose::GET_ATTRIBUTE_CALLED, 1;
is $TestApp::Controller::Moose::MethodModifiers::GET_ATTRIBUTE_CALLED, 1;

my $other = (grep { $_->name eq 'other' } @methods)[0];
ok $other;

