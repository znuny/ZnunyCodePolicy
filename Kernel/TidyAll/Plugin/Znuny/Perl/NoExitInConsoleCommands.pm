# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::NoExitInConsoleCommands;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{ (^|\s+) exit (;|\s|\() }smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Don't use 'exit' in console commands. Use 'return \$Self->ExitCodeOk();' or 'return \$Self->ExitCodeError();' instead.
$ErrorMessage
EOF
    }

    return;
}

1;
