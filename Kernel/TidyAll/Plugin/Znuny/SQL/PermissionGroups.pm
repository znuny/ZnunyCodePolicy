# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SQL::PermissionGroups;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks if table 'groups' is uses as ForeignTable.
This is no longer supported since Znuny 6.1.1.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsFrameworkVersionLessThan('6.1');
    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter      = 0;
    my $ErrorMessage = '';
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line =~ m{\A\s*#}sm;

        next LINE if $Line !~ m{<ForeignKey ForeignTable="groups">}sm;

        $ErrorMessage .= "\nLine $Counter: $Line";
    }

    return if !length $ErrorMessage;

    my $Message = "Using table 'groups' as ForeignTable is no longer supported since 6.1.1. Please use renamed table 'permission_groups' instead." . $ErrorMessage;

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'error',
    );

    return;
}

1;
