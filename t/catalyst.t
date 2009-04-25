{
    package Catalyst::Controller;
    use Moose;
    use namespace::clean -except => 'meta';
    BEGIN { extends qw/MooseX::MethodAttributes::Inheritable/; }
}
{
    package TestApp::Controller::Moose;
    use Moose;
    use namespace::clean -except => 'meta';
    BEGIN { extends qw/Catalyst::Controller/; }

    sub get_attribute : Local {}

    sub other : Local {}

    sub notwrapped : Local {}
}
{
    package TestApp::Controller::Moose::MethodModifiers;
    use Moose;
    BEGIN { extends qw/TestApp::Controller::Moose/; }

    after get_attribute => sub { };

    sub other : Local {}
    after other => sub {};

    sub notwrapped {}
}

use Test::More tests => 1;
use Test::Exception;

lives_ok {
    TestApp::Controller::Moose::MethodModifiers->meta->get_nearest_methods_with_attributes;
} 'Can get nearest methods';

