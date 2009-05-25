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

    sub not_attributed : Local {} # This method should get composed as foo.
}
{
    package roles::Controller::Foo;
    use Moose;
    BEGIN { extends 'Catalyst::Controller'; }

    use Test::More tests => 1;
    use Test::Exception;
    throws_ok {
        with 'ControllerRole' => { alias => { not_attributed => 'foo' } };
    } qr/oes not currently support/;
    exit;

    sub not_attributed {}
}
__END__
use Test::More tests => 4;

my $meta = roles::Controller::Foo->meta;
my %expected = (
    foo => ["Local"],
    not_attributed => [],
);
foreach my $method_name (keys %expected) {
    my $method = $meta->get_method($method_name);
    ok $method, "Have method $method_name";
    my $attrs = $meta->get_method_attributes($method->body);
    is_deeply $attrs, $expected{$method_name},
        "Attributes on $method_name as expected";
}

