use strict;
use warnings;
use MooseX::MethodAttributes ();

{
    package Bar;
    use Moose::Role -traits => 'MethodAttributes';
    use namespace::clean -except => 'meta';

    sub item :Chained(/app/root) PathPrefix CaptureArgs(1) { }
}

{
    package Foo;
    use Moose::Role -traits => 'MethodAttributes';
    use namespace::clean -except => 'meta';

    with 'Bar';

    sub live :Chained(item) PathPart Args(0) { }
    sub foo :Attr { }
    sub other :Attr { }
}

{
    package Catalyst::Controller;
    use Moose;
    use namespace::clean -except => 'meta';

    BEGIN { extends qw/MooseX::MethodAttributes::Inheritable/; }
}

use Test::More tests => 1;
use Moose::Util;
use Moose::Meta::Class;;
use Data::Dumper;

my @roles = qw/Foo/;

Moose::Meta::Class->create("MyClass",
    superclasses => [qw/Catalyst::Controller/],
    roles => \@roles,
);

my @methods;
for my $method (sort { $a->name cmp $b->name } MyClass->meta->get_all_methods_with_attributes) {
    push(@methods, $method->name . " :" . join("|", @{ $method->attributes }));
}

is_deeply \@methods, [
    'foo :Attr',
    'item :Chained(/app/root)|PathPrefix|CaptureArgs(1)',
    'live :Chained(item)|PathPart|Args(0)',
    'other :Attr',
], 'methods with expected attributes found'
    or warn Dumper(\@methods);

