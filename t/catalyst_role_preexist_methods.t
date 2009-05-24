use strict;
use warnings;

{
    package Catalyst::Controller;
    use Moose;
    use namespace::clean -except => 'meta';
    use MooseX::MethodAttributes;
    BEGIN { extends 'MooseX::MethodAttributes::Inheritable'; }
}

{
    package ControllerRole;
    use Moose::Role -traits => 'MethodAttributes';
    use namespace::clean -except => 'meta';
}
{
    package roles::Controller::Foo;
    use Moose;
    BEGIN { extends 'Catalyst::Controller'; }

    with 'ControllerRole';

    sub load : Chained('base') PathPart('') CaptureArgs(1) { }
    
    sub base : Chained('/') PathPart('foo') CaptureArgs(0) { }

    sub entry : Chained('load') PathPart('') CaptureArgs(0) { }

    sub some_page : Chained('entry') { }
}

use Test::More tests => 8;

my $meta = roles::Controller::Foo->meta;
my %expected = (
    base => ["Chained('/')", "PathPart('foo')", "CaptureArgs(0)"],
    load => ["Chained('base')", "PathPart('')", "CaptureArgs(1)"],
    entry => ["Chained('load')", "PathPart('')", "CaptureArgs(0)"],
    some_page => ["Chained('entry')"],
);
foreach my $method_name (keys %expected) {
    my $method = $meta->get_method($method_name);
    ok $method, "Have method $method_name";
    my $attrs = $meta->get_method_attributes($method->body);
    is_deeply $attrs, $expected{$method_name},
        "Attributes on $method_name as expected";
}
 
