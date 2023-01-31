# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SOPM::License;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->GetSetting('IsThirdPartyProduct');

    $Code
        =~ s{<License> .*? </License>}{<License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>}gsmx;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->GetSetting('IsThirdPartyProduct');

    if ( $Code !~ m{<License> .+? </License>}smx ) {
        $Self->AddErrorMessage("Could not find a valid OPM license header.");
    }

    if (
        $Code
        !~ m{<License>GNU \s AFFERO \s GENERAL \s PUBLIC \s LICENSE \s Version \s 3, \s November \s 2007</License>}smx
        )
    {
        $Self->AddErrorMessage(<<"EOF");
Invalid license found.
Use <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>.
EOF
    }

    return;
}

1;
