# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Migrations::OTRS6::PermissionDataNotInSession;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

## nofilter(TidyAll::Plugin::OTRS::Migrations::OTRS6::PermissionDataNotInSession)
## nofilter(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 7, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{UserIsGroup}sm ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Since OTRS 6, group permission information is no longer stored in the session nor the LayoutObject and cannot be fetched with 'UserIsGroup[]'. Instead, it can be fetched with PermissionCheck() on Kernel::System::Group or Kernel::System::CustomerGroup.

Example:

    my \$HasPermission = \$Kernel::OM->Get('Kernel::System::Group')->PermissionCheck(
        UserID    => \$UserID,
        GroupName => \$GroupName,
        Type      => 'move_into',
    );

$ErrorMessage
EOF
    }

    return;
}

1;
