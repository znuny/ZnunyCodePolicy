# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::ConfigDescription;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter, $NavBar );

    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ /<NavBar/ ) {
            $NavBar = 1;
        }
        if ( $Line =~ /<\/NavBar/ ) {
            $NavBar = 0;
        }

        if ( !$NavBar && $Line =~ /<Description.+?>(.).*?(.)<\/Description>/ ) {
            if ( $2 ne '.' && $2 ne '?' && $2 ne '!' ) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            elsif ( $1 !~ /[A-ZËÜÖ"]/ ) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Use complete sentences in <Description> tag: Start with a capital letter and finish with a dot.
$ErrorMessage
EOF
    }
}

1;
