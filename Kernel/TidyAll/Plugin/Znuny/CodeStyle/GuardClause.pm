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

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code     = $Self->_GetFileContents($File);
    my $FilePath = $Self->FilePath($Code);

    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code =~ m{\# \s \$origin}xmsi;
    return if $Code =~ m{no \s warnings \s 'redefine'}xmsi;


    # Experimental feature!

    # if lookup needs a reversed line order to make accomplish a proper regex matching rate
    my $CodeReversed = join( "\n", reverse split( "\n", $Code ) );

    # Check for GuardClause before return - http://rubular.com/r/0fZmW3d93V
    my $IfGuardClauseRegEx = qr{ ( ^\} \s+ return (?:[^;]+); \s+ (^\s+)(\} .+? ^\2 if [^\n]+) ) }xms;
    IFGUARD:
    while ( $CodeReversed =~ m{$IfGuardClauseRegEx}g ) {
        my $MatchedBlock = $1;
        my $Indentation  = $2;
        my $IfBlock      = $3;

        # reverse the matched block back again so we can print it out to the user
        $MatchedBlock = join( "\n", reverse split( "\n", $MatchedBlock ) );

        next IFGUARD if $IfBlock =~ m{^\Q$Indentation\E else \s* \{}xms;
        next IFGUARD if $IfBlock =~ m{^\Q$Indentation\E elsif \s* \(}xms;
        next IFGUARD if $IfBlock =~ m{^\Q$Indentation\E \} .+}xms;
        next IFGUARD if $IfBlock =~ m{return}xms;
        next IFGUARD if $MatchedBlock =~ m{return [^;]+if[^;]+; \s+ \}}xms;

        my $Message = "NOTICE: Possible GuardClause before return. May be possible to invert the last if condition:\n$MatchedBlock\n";

        $Self->Print(
            Package  => __PACKAGE__,
            Priority => 'notice',
            Message  => $Message,
            FilePath => $FilePath,
        );
    }

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

        my $Message  = "NOTICE: Possible GuardClause before end of loop. May be possible to invert the last if condition:\n$1";

        $Self->Print(
            Package  => __PACKAGE__,
            Priority => 'notice',
            Message  => $Message,
            FilePath => $FilePath,
        );

    }

    return;
}

1;
