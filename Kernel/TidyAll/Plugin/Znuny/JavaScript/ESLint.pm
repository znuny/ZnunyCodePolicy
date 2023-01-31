# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::JavaScript::ESLint;

use strict;
use warnings;

use Encode;
use parent qw(TidyAll::Plugin::Znuny::Base);

our $NodePath;
our $ESLintPath;

sub transform_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    if ( !$ESLintPath ) {

        # On some systems (Ubuntu) nodejs is called /usr/bin/nodejs instead of /usr/bin/node,
        #   which can lead to problems with calling the node scripts directly. Therefore we
        #   determine the nodejs binary and call it directly.
        $NodePath = `which nodejs 2>/dev/null` || `which node 2>/dev/null`;
        chomp $NodePath;
        if ( !$NodePath ) {
            $Self->AddErrorMessage(
                "Error: could not find the 'nodejs' binary."
            );
        }

        $ESLintPath = __FILE__;
        $ESLintPath =~ s{ESLint\.pm}{ESLint/node_modules/eslint/bin/eslint.js};
        if ( !-e $ESLintPath ) {
            $Self->AddErrorMessage(
                "Error: could not find the 'eslint' script. Please run `development/bin/znuny.CodePolicy.pl --install-eslint`."
            );
        }

        # Force the minimum version of eslint.
        my $ESLintVersion = `$NodePath $ESLintPath -v`;
        chomp $ESLintVersion;
        my ( $Major, $Minor, $Patch ) = $ESLintVersion =~ m{v(\d+)[.](\d+)[.](\d+)};
        my $Compare = sprintf( "%03d%03d%03d", $Major, $Minor, $Patch );
        if ( !length($Major) || $Compare < 6_000_001 ) {
            undef $ESLintPath;    # Make sure to re-issue this error for future files.
            $Self->AddErrorMessage(
                "Error: installed eslint version ($ESLintVersion) is outdated. Please run `development/bin/znuny.CodePolicy.pl --install-eslint`."
            );
        }
    }

    my $ESLintConfigPath = __FILE__;
    $ESLintConfigPath =~ s{ESLint\.pm}{ESLint/legacy.eslintrc.js};

    # ESLint plugins should be resolved relative to the root folder.
    my $ESLintPluginsPath = __FILE__;
    $ESLintPluginsPath =~ s{ESLint\.pm}{ESLint/};

    my $ESLintRulesPath = __FILE__;
    $ESLintRulesPath =~ s{ESLint\.pm}{ESLint/Rules};

    my $Command = sprintf(
        "%s %s --config %s --no-eslintrc --resolve-plugins-relative-to %s --rulesdir %s --fix %s --quiet",
        $NodePath, $ESLintPath, $ESLintConfigPath, $ESLintPluginsPath, $ESLintRulesPath, $Filename
    );

    my $Output = `$Command`;
    if ( ${^CHILD_ERROR_NATIVE} || $Output ) {
        Encode::_utf8_on($Output);    ## no critic
        $Self->AddErrorMessage($Output);
    }
}

1;
