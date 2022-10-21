# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SOPM::FileRights;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ExecutablePermissionCheck = qr{Permission="770"};
    my $StaticPermissionCheck     = qr{Permission="660"};
    my $Explanation = '<File> tag has wrong permissions. Script files normally need 770 rights, the others 660.';

    my ( $ErrorMessage, $LineCounter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        next LINE if $Line !~ m{<File.*Location="([^"]+)".*\/>};

        my $FilePath = $1;

        if ( $FilePath =~ m{\.(pl|sh|fpl|psgi|sh)$} ) {
            if ( $Line !~ $ExecutablePermissionCheck ) {
                $ErrorMessage .= "Line $LineCounter: $Line\n";
            }
        }
        else {
            if ( $Line !~ $StaticPermissionCheck ) {
                $ErrorMessage .= "Line $LineCounter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
$Explanation
$ErrorMessage
EOF
    }

    return;
}

1;
