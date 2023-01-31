# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::JavaScript::AlertFunction;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $Counter;

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        # Ignore comments (this still doesn't catch code in comment blocks /* */).
        next LINE if $Line =~ m{\A(//|/\*)};

        if ( $Line =~ m{\balert\((.*?)\)} ) {
            $ErrorMessage
                .= "Found alert() in line $Counter: $Line\n";
            $ErrorMessage .= "Use Core.UI.Dialog.ShowAlert('<Insert your alert title here>', $1) instead of alert().\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddMessage(
            Message  => $ErrorMessage,
            Priority => 'warning'
        );
    }
}

1;
