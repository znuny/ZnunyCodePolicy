# --
# Copyright (C) 2012-2025 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Ensures that JavaScript code updating user preferences via Core.Agent.PreferencesUpdate
is accompanied by an explicit reminder to verify matching UserPreferencesUpdate###*
SysConfig settings.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my @Findings;
    my $LineCounter = 0;

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        $LineCounter++;

        # Ignore single line comments.
        next LINE if $Line =~ m{\A\s*//};
        next LINE if $Line =~ m{\A\s*/\*};

        next LINE if $Line !~ m{Core\.Agent\.PreferencesUpdate};

        push @Findings, "Line $LineCounter: $Line";
    }

    return if !@Findings;

    my $Message = <<"EOF";
Found Core.Agent.PreferencesUpdate call(s). Please verify/update matching SysConfig UserPreferencesUpdate###<Context> settings to allow the updated preference keys.
EOF

    $Message .= "\nAffected lines:";
    for my $Finding (@Findings) {
        $Message .= "\n    $Finding";
    }

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'notice',
    );

    return;
}

1;
