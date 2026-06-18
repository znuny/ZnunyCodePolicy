# --
# Copyright (C) 2023 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::TT::ObligatoryFilter;

use strict;
use warnings;
use utf8;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->GetSetting('IsThirdPartyProduct');

    my $Lines = 1;
    my $Found = 0;
    my $Hits = '';

    # Parse out all [% … %] bracketed expressions
    # Using /p we get ${^PREMATCH}, ${^MATCH} and ${^POSTMATCH} defined
    while ( $Code =~ m{\[% \s* .*? %\]}xspg ) {
        my $Match = ${^MATCH};    # ${^MATCH} is read-only and clobbered by the next RE
        $Code = ${^POSTMATCH};    # Next iteration uses only the part after the match
        $Lines += ${^PREMATCH} =~ tr{\n}{\n};

        # If there's an interpolation of Data.* and no filter expression ("| foo")
        if (
            $Match =~ m{ ^ \[% \s* Data \. . }xs
            && $Match !~ m{ \| \s* \w+ }xs
        ) {
            $Found++;
            $Hits .= "Line $Lines: $Match\n";
        }

        $Lines += $Match =~ tr{\n}{\n};
    }

    if( $Found ) {
        $Self->AddMessage(
            Message  => "Found $Found unfiltered data interpolations. Please check if they need some kind of filter like ' | html'.\n$Hits",
            Priority => 'warning',
        );
    }

    return;
}

1;
