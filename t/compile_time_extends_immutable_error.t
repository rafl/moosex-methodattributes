{
    package TestApp::Controller::MoosetestBase;
    use Moose;

    BEGIN {
        extends 'Catalyst::Controller';
        no Moose;
        __PACKAGE__->meta->make_immutable;
    }

    sub base : Moo {}
}
{
    package ChildClass;
    use Moose;
    use Test::More tests => 1;
    use Test::Exception;

    lives_ok {
        extends 'TestApp::Controller::MoosetestBase';
    } 'Do not know why this blows up in such an ugly manor';
}

