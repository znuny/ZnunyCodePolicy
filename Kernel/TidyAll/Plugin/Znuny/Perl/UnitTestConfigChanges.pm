# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::UnitTestConfigChanges;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

our $ObjectManagerDisabled = 1;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $LineCounter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;
        if ( $Line =~ m{RestoreSystemConfiguration}smx ) {
            $ErrorMessage .= "Line $LineCounter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
The 'RestoreSystemConfiguration' flag is not available anymore for unit tests.
$ErrorMessage
EOF
    }

    return;
}

1;
