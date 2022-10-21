# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::TT::Breadcrumb;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Code =~ m{\[% INCLUDE "Breadcrumb\.tt" Path = BreadcrumbPath %\]};

    my $Message = "Found no breadcrumbs in admin template. Add/adjust the following:\n"
        . '[% INCLUDE "Breadcrumb.tt" Path = BreadcrumbPath %]'
        . '[See: https://github.com/znuny/Znuny/blob/1d2c412eebf80e74e6be1ac0529be09c1e1c6067/Kernel/Output/HTML/Templates/Standard/AdminUser.tt#L30';

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'notice',
    );
}

1;
