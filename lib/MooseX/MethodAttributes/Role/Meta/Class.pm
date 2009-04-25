package MooseX::MethodAttributes::Role::Meta::Class;
# ABSTRACT: metaclass role for storing code attributes

use Moose::Role;
use Moose::Util qw/find_meta/;
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
    } grep { $_->can('_get_attributed_coderef') } @methods;
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
    } reverse $self->linearized_isa
}

=method get_all_methods_with_attributes_filtered

Takes the output of the get_all_methods_with_attributes list, and for each method,
checks if there is a method nearer in the inheritance hierarchy which does not
have any attributes, and if such a method is present, removes the method from the list.

For example, given:

    package BaseClass;

    sub foo : Attr {}

    package SubClass;
    use base qw/BaseClass/;

    sub foo {}

C<< SubClass->meta->get_all_methods_with_attributes >> will return 
C<< BaseClass->meta->get_method('foo') >> for the above example, but
this method will not.

=cut

sub get_all_methods_with_attributes_filtered {
    my ($self) = @_;
    
    grep { 
        scalar @{ $self->find_method_by_name($_->name)->attributes }
    } $self->get_all_methods_with_attributes;
}

1;

