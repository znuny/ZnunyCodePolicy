# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::GuardClause;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code =~ m{\# \s \$origin}xmsi;
    return if $Code =~ m{no \s warnings \s 'redefine'}xmsi;

    # Check for GuardClause in loops - http://rubular.com/r/2DPM4eycx6
    my $ForLoopGuardClauseRegEx = qr{ ( (^\s+)(?:for|while) .+? (^\s+)(if .+? ^\3\})\s+ ^\2\} ) }xms;

    FORGUARD:
    while ( $Code =~ m{$ForLoopGuardClauseRegEx}g ) {
        my $MatchedBlock   = $1;
        my $IndentationFor = $2;
        my $IndentationIf  = $3;
        my $IfBlock        = $4;

        $MatchedBlock =~ s{(^\Q$IndentationFor\E \}) .* \z}{$1}xms;

        # check again
        next FORGUARD if $MatchedBlock !~ m{$ForLoopGuardClauseRegEx};

        $MatchedBlock   = $1;
        $IndentationFor = $2;
        $IndentationIf  = $3;
        $IfBlock        = $4;

        next FORGUARD if $IfBlock =~ m{^\Q$IndentationIf\E else \s* \{}xms;
        next FORGUARD if $IfBlock =~ m{^\Q$IndentationIf\E elsif \s* \(}xms;

        my $Message  = "Possible guard clause before end of loop. It may be possible to invert the last if condition:\n$1";

        $Self->AddMessage(
            Message  => $Message,
            Priority => 'notice',
        );
    }

    return;
}

1;
