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

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->GetSetting('IsThirdPartyProduct');

    my $NewCode = '';
    my $Found = 0;
    # Parse out all [% … %] bracketed expressions
    # Using /p we get ${^PREMATCH}, ${^MATCH} and ${^POSTMATCH} defined
    while( $Code =~ m{\[% ( .*? ) %\]}xspg ) {
        print STDERR "matched: ${^MATCH}\n";
        $Code = ${^POSTMATCH};     # next iteration uses only the part after the match
        $NewCode .= ${^PREMATCH};  # no need to look at the part before

        my $Match = ${^MATCH};     # ${^MATCH} is read-only
        # If there's an access to Data.* and no filter expression ("| foo")
        if( $Match =~ m{ Data \. . }xs && $Match !~ m{ \| \s* \w+ }xs ) {
            # Count the mistake and fix it
            $Found++;
            $Match =~ s{%\] }{| html %]}xs;
            print STDERR "transformed ${^MATCH}\n";
        }
        $NewCode .= $Match; # Append either the good code verbatim or the fixed version
    }
    if( $Found ) {
        $Self->AddMessage(
            Message => "Found $Found unfiltered in-template tags",
            Priority => 'transform',
        );
    }
    return $NewCode . $Code;
}

1;
