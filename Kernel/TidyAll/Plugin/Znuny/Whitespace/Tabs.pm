# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Whitespace::Tabs;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter = 1;
    my $ErrorMessage;

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{\t} ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Substitute all tabs with four spaces.
$ErrorMessage
EOF
    }
}

1;
