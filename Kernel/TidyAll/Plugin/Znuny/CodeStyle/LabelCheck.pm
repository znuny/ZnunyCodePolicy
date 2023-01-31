# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::LabelCheck;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for next and last statements that refer to non-existing labels.
Additionally, labels will be checked for LOOP suffix (not allowed).

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my %Labels;
    my $LabelRegex  = '[A-Z][A-Z0-9_]*';
    my $LineCounter = 0;

    my $InvalidLabelMessage = '';
    my $UnknownLabelMessage = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;
        if ( $Line =~ m{\A\s*($LabelRegex)\:} ) {
            my $Label = $1;
            $Labels{$Label} = 1;

            if ( $Label =~ m{LOOP\z} ) {
                $InvalidLabelMessage .= "\tLine $LineCounter: $Line\n";
            }
        }

        next LINE if $Line !~ m{\A\s*(next|last)\s*($LabelRegex)\b};
        my $ReferencedLabel = $2;
        next LINE if $Labels{$ReferencedLabel};

        $UnknownLabelMessage .= "\tLine $LineCounter: $Line\n";
    }

    my $ErrorMessage = '';
    if ( length $InvalidLabelMessage ) {
        $ErrorMessage .= "Don't use LOOP suffix for labels:\n" . $InvalidLabelMessage . "\n";
    }
    if ( length $UnknownLabelMessage ) {
        $ErrorMessage .= "These statements reference unknown labels:\n" . $UnknownLabelMessage . "\n";
    }

    return if !length $ErrorMessage;

    $Self->AddErrorMessage($ErrorMessage);
}

1;
