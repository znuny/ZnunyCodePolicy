# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Whitespace::FourSpaces;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter;
    my $ErrorMessage;
    my $IsTextArea = 0;    # in config files
    my $IsSOPMData = 0;    # database entries of sopm files

    #
    # Check for steps of four spaces
    #
    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        $Counter++;

        # textareas in config files
        if ( $Line =~ m{<TextArea>} ) {
            $IsTextArea = 1;
        }
        if ( $Line =~ m{<\/TextArea>} ) {
            $IsTextArea = 0;
        }

        # database entries of sopm files
        if ( $Line =~ m{ <Data \s}smx ) {
            $IsSOPMData = 1;
        }
        if ( $Line =~ m{ < \/ Data > }smx ) {
            $IsSOPMData = 0;
        }

        if ( $Line =~ m{^( +)} ) {
            my $SpaceString = $1;
            my $Length      = length $SpaceString;

            if ( $Length % 4 && !$IsTextArea && !$IsSOPMData ) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Spaces at the beginning of a line must be in steps of four.
$ErrorMessage
EOF
    }
}

1;
