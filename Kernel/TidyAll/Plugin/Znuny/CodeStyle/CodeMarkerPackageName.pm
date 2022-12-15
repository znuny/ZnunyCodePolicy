# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package TidyAll::Plugin::Znuny::CodeStyle::CodeMarkerPackageName;

use strict;
use warnings;

=head1 SYNOPSIS

This plugin checks for correct code marker naming

e.g.
# ---
# Znuny-CodePolicy
# ---

# ---

=cut

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # If there's a former-origin marker in the code, it's not possible to reliably
    # check the code markers because there could be others like '# ITSMCore'
    return if $Code =~ m{\$former-origin:}sm;

    my $IsOPMContext = $Self->GetSetting('Context::OPM');
    return if !$IsOPMContext;

    my $PackageName = $Self->GetSetting('ProductName');

    # Check coder markers
    my $MarkerStarted = 0;
    my $MarkerType    = '';
    my $MarkerName    = '';
    my $LineCounter   = 0;
    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        if (
            !$MarkerStarted
            && $Line =~ m{\A(#|//)\s---\z}
            )
        {
            $MarkerType    = $1;
            $MarkerStarted = 1;
            next LINE;
        }

        next LINE if !$MarkerStarted;

        if (
            length $MarkerName
            && $Line =~ m{\A(\#|\/\/)\s---\z}
            )
        {
            if ( $MarkerName ne $PackageName ) {
                my $Message = "Line $LineCounter: Code marker '$MarkerType $MarkerName' should be:\n\n$MarkerType ---\n$MarkerType $PackageName\n$MarkerType ---";
                $Self->AddErrorMessage($Message);
            }

            $MarkerStarted = 0;
            $MarkerName    = '';
            next LINE;
        }

        if ( $Line !~ m{\A(\#|\/\/)\s(\S+)\z} ) {
            $MarkerStarted = 0;
            $MarkerType    = '';
            next LINE;
        }

        $MarkerName = $2;
    }

    return;
}

1;
