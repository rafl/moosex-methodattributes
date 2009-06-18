package UsesMultipleRoles;
use Moose;
use namespace::clean -except => 'meta';

with qw/
    RoleWithAttributes/;
with qw/    OtherRoleWithAttributes
/;

__PACKAGE__->meta->make_immutable;

