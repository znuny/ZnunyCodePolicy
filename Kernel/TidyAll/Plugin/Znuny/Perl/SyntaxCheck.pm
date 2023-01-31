# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::SyntaxCheck;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

use File::Temp;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $CleanedSource, $DeletableStatement );

    # Allow important modules that come with the Perl core or are external
    # dependencies of Znuny and can thus be assumed as being installed.
    my @AllowedExternalModules = qw(
        vars
        constant
        strict
        warnings
        threads
        lib

        Archive::Zip
        Archive::Tar
        Cwd
        Carp
        Data::Dumper
        DateTime
        DBI
        Fcntl
        File::Basename
        FindBin
        IO::Socket::IP
        IO::Socket::SSL
        List::Util
        Perl::Critic::Utils
        POSIX
        Readonly
        Template
        Template::Constants
        Time::HiRes
    );

    my $AllowedExternalModulesRegex = '\A \s* use \s+ (?: ' . join( '|', @AllowedExternalModules ) . ' ) [ ;(] ';

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        # Skip all 'use *;' statements except for core modules because the modules cannot be found at runtime.
        if ( $Line =~ m{ \A \s* use \s+ }xms && $Line !~ m{$AllowedExternalModulesRegex}xms ) {
            $DeletableStatement = 1;
        }

        if ($DeletableStatement) {
            $Line = "#$Line";
        }

        if ( $Line =~ m{ ; \s* \z }xms ) {
            $DeletableStatement = 0;
        }

        $CleanedSource .= $Line . "\n";
    }

    my $TempFile = File::Temp->new();
    print $TempFile $CleanedSource;
    $TempFile->flush();

    # syntax check
    my $ErrorMessage;
    my $FileHandle;
    if ( !open $FileHandle, '-|', "perl -cw " . $TempFile->filename() . " 2>&1" ) {    ## no critic
        $Self->AddErrorMessage("FILTER: Can't open tempfile: $!\n");
    }

    while ( my $Line = <$FileHandle> ) {
        if ( $Line !~ /(syntax OK|used only once: possible typo)/ ) {
            $ErrorMessage .= $Line;
        }
    }
    close $FileHandle;

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }
}

1;
