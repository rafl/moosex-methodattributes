package MooseX::MethodAttributes::Role::Meta::Class;
# ABSTRACT: metaclass role for storing code attributes

use Moose::Role;
use Moose::Util qw/find_meta does_role/;
use MooseX::Types::Moose qw/HashRef ArrayRef Str Int/;

use namespace::clean -except => 'meta';

has _method_attribute_map => (
    is        => 'ro',
    isa       => HashRef[ArrayRef[Str]],
    lazy      => 1,
    default   => sub { +{} },
);

has _method_attribute_list => (
    is      => 'ro',
    isa     => ArrayRef[Int],
    lazy    => 1,
    default => sub { [] },
);

=method register_method_attributes ($code, $attrs)

Register a list of attributes for a code reference.

=cut

sub register_method_attributes {
    my ($self, $code, $attrs) = @_;
    push @{ $self->_method_attribute_list }, 0 + $code;
    $self->_method_attribute_map->{ 0 + $code } = $attrs;
    return;
}

=method get_method_attributes ($code)

Get a list of attributes associated with a coderef.

=cut

sub get_method_attributes {
    my ($self, $code) = @_;
    return $self->_method_attribute_map->{ 0 + $code } || [];
}

=method get_method_with_attributes_list

Gets the list of meta methods for local methods of this class that have
attributes in the order they have been registered.

=cut

sub get_method_with_attributes_list {
    my ($self) = @_;
    my @methods = values %{ $self->get_method_map };
    my %order;

    {
        my $i = 0;
        $order{$_} = $i++ for @{ $self->_method_attribute_list };
    }

    return map {
        $_->[1]
    } sort {
        $order{ $a->[0] } <=> $order{ $b->[0] }
    } map {
        my $addr = 0 + $_->_get_attributed_coderef;
        exists $self->_method_attribute_map->{$addr}
        ? [$addr, $_]
        : ()
    } grep { 
        $_->can('_get_attributed_coderef')
    } @methods;
}

=method get_all_methods_with_attributes

Gets the list of meta methods of local and inherited methods of this class,
that have attributes. Baseclass methods come before subclass methods. Methods
of one class have the order they have been declared in.

=cut

sub get_all_methods_with_attributes {
    my ($self) = @_;
    my %seen;

    return reverse grep {
        !$seen{ $_->name }++
    } reverse map {
        my $meth;
        my $meta = find_meta($_);
        ($meta && ($meth = $meta->can('get_method_with_attributes_list')))
            ? $meta->$meth
            : ()
    } reverse $self->linearized_isa;
}

=method get_nearest_methods_with_attributes

The same as get_all_methods_with_attributes, except that methods from parent classes
are not included if there is an attributeless method in a child class.

For example, given:

    package BaseClass;

    sub foo : Attr {}

    sub bar : Attr {}

    package SubClass;
    use base qw/BaseClass/;

    sub foo {}

    after bar => sub {}

C<< SubClass->meta->get_all_methods_with_attributes >> will return 
C<< BaseClass->meta->get_method('foo') >> for the above example, but
this method will not, and will return the wrapped bar method, wheras
C<< get_all_methods_with_attributes >> will return the original method.

=cut

sub get_nearest_methods_with_attributes {
    my ($self) = @_;
    my @list = map {
        my $m = $self->find_method_by_name($_->name);
        my $meth = $m->can('attributes');
        my $attrs = $meth ? $m->$meth() : [];
        scalar @{ $attrs } ? ( $m ) : ( );
    } $self->get_all_methods_with_attributes;
    return @list;
}

foreach my $type (qw/after before around/) {
    after "add_${type}_method_modifier" => sub {
        my ($meta, $method_name) = @_;
        my $method = $meta->get_method($method_name);
        if (
            does_role($method->get_original_method, 'MooseX::MethodAttributes::Role::Meta::Method')
            || does_role($method->get_original_method, 'MooseX::MethodAttributes::Role::Meta::Method::Wrapped')
        ) { 
            MooseX::MethodAttributes::Role::Meta::Method::Wrapped->meta->apply($method);
        }
    }
}

1;

