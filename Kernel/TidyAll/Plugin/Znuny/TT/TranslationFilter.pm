# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::TT::TranslationFilter;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        # Process lines that deal with translation output in function form.
        while ( $Line =~ m{ \[% \s* \bTranslate\(([^()]*|\([^()]*\))*\)? (?<Filter>.*?) %\] }gsxm ) {

            # Check if output is not filtered.
            if ( $+{Filter} !~ m{ \s* (?:FILTER|\|) \s* (?:html|JSON) }sxm ) {
                $ErrorMessage
                    .= "Found unfiltered translation string in line $Counter: $Line\n";
            }
        }

        # Process lines that deal with translation output in filter form.
        while ( $Line =~ m{ (?:FILTER|\|) \s* \bTranslate (?<Filter>.*?) %\] }gsxm ) {

            # Check if output is not filtered.
            if ( $+{Filter} !~ m{ \s* (?:FILTER|\|) \s* (?:html|JSON) }sxm ) {
                $ErrorMessage
                    .= "Found unfiltered translation string in line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(
            "${ErrorMessage}Make sure to process translated strings with 'html' or 'JSON' filter."
        );
    }

    return;
}

1;
