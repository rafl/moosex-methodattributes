package MooseX::MethodAttributes::Role::Meta::Role::Application;
# ABSTRACT: generic role for applying a role with method attributes to something

use Moose::Role;
use Moose::Util qw/find_meta/;
use MooseX::MethodAttributes ();
use MooseX::MethodAttributes::Role ();
use namespace::clean -except => 'meta';

requires qw/
    _copy_attributes
    apply
/;

=method apply

The apply method is wrapped to ensure that the correct metaclasses to hold and propagate
method attribute data are present on the target for role application, delegates to
the original method to actually apply the role, then ensures that any attributes from
the role are copied to the target class.

=cut

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;
    $thing = $self->_apply_metaclasses($thing);

    my $ret = $self->$orig($thing, %opts);

    $self->_copy_attributes($thing);

    return $ret;
};

sub _apply_metaclasses {
    my ($self, $thing) = @_;
    if ($thing->isa('Moose::Meta::Class')) {
        $thing = MooseX::MethodAttributes->init_meta( for_class => $thing->name );
    }
    elsif ($thing->isa('Moose::Meta::Role')) {
        $thing = MooseX::MethodAttributes::Role->init_meta( for_class => $thing->name );
    }
    else {
        croak("Composing " . __PACKAGE__ . " onto instances is unsupported");
    }

    # Note that the metaclass instance we started out with may have been turned
    # into lies by the metatrait role application process, so we explicitly
    # re-fetch it here.

    # Alternatively, for epic shits and giggles, the meta trait application
    # process (onto $thing) may have applied roles to our metaclass, but (if
    # $thing is an anon class, not correctly replaced it in the metaclass cache.
    # This results in the DESTROY method in Class::MOP::Class r(eap|ape)ing the
    # package, which is unfortunate, as it removes all your methods and superclasses.
    # Therefore, we avoid that by ramming the metaclass we've just been handed into
    # the cache without weakening it.

    # I'm fairly sure the 2nd part of that is a Moose bug, and should go away..
    # Unfortunately, the implication of that is that whenever you apply roles to a class,
    # the metaclass instance can change, and so needs to be re-retrieved or handed back
    # to the caller :/
    if ($thing->can('is_anon_class') and $thing->is_anon_class) {
        Class::MOP::store_metaclass_by_name($thing->name, $thing);
    }
    else {
        return find_meta($thing->name);
    }
    return $thing;
}

1;
