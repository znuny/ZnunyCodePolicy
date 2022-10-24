# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Znuny::Git::PreCommit;

use strict;
use warnings;

=head1 SYNOPSIS

This commit hook loads the Znuny version of Code::TidyAll
with the custom plugins, executes it for any modified files
and returns a corresponding status code.

=cut

use File::Spec;
use File::Basename;
use IPC::System::Simple qw(capturex);
use Try::Tiny;
use TidyAll::Znuny;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my $Self = @_;

    print "Znuny code policy pre-commit hook starting...\n";

    my $ErrorMessage;

    try {

        # Find conf file at git root
        my $RootDir = capturex( 'git', "rev-parse", "--show-toplevel" );
        chomp($RootDir);

        # Gather file paths to be committed
        my $Output = capturex( 'git', "status", "--porcelain" );

        # Fetch only staged files that will be committed.
        my @ChangedFiles = grep { -f && !-l } ( $Output =~ /^[MA]+\s+(.*)/gm );
        push @ChangedFiles, grep { -f && !-l } ( $Output =~ /^\s*RM?+\s+(.*?)\s+->\s+(.*)/gm );
        return if !@ChangedFiles;

        # Always include all SOPM files to verify the file list.
        for my $SOPMFile ( map { File::Spec->abs2rel( $_, $RootDir ) } grep { !-l $_ } glob("$RootDir/*.sopm") ) {
            if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
                push @ChangedFiles, $SOPMFile;
            }
        }

        # Find code policy configuration
        my $ScriptDirectory;
        if ( -l $0 ) {
            $ScriptDirectory = dirname( readlink($0) );
        }
        else {
            $ScriptDirectory = dirname($0);
        }
        my $ConfigFile = $ScriptDirectory . '/../tidyallrc';

        my $TidyAll = TidyAll::Znuny->new_from_conf_file(
            $ConfigFile,
            check_only => 1,
            mode       => 'cli',
            root_dir   => $RootDir,
            data_dir   => File::Spec->tmpdir(),
        );

        if ( !$TidyAll ) {
            print "Error creating TidyAll object.\n";
            exit 1;
        }

        my $TidyAllSettings = $TidyAll->GetSettings();

        if (
            !$TidyAll->HasValidContext()
            || !$TidyAllSettings->{'SOPM::HasSupportedFrameworkVersion'}
        ) {
            print "Framework and/or OPM information could not be retrieved or OPM framework version is incompatible. Note that only the framework versions of the executed code policy are supported.\n";

            # Use exit code 0 (not 1) because the CI environment's git hook should not lead to reject the push if the framework version is not supported.
            exit 0;
        }

        print "\n================================================================================\n";
        print "Code policy context:         " . ( $TidyAllSettings->{'Context::Framework'} ? 'Framework' : 'OPM' )  . "\n";
        print "Vendor:                      $TidyAllSettings->{Vendor}\n";
        print "Product name:                $TidyAllSettings->{ProductName}\n";
        print "================================================================================\n";

        my$TidyAllResults = $TidyAll->ProcessFilePathsParallel(
            FilePathsToCheck => [ map {"$RootDir/$_"} @ChangedFiles ],
        );

        my $ExitCode = $TidyAll->PrintResults($TidyAllResults);
        if ($ExitCode) {
            print "Error: Some file(s) did not pass validation.\n";
            exit 1;
        }

        exit 0;
    }
    catch {
        my $Exception = $_;
        print "Error during pre-commit hook:\n$Exception\n";
    };

    if ($ErrorMessage) {
        print "$ErrorMessage\n";
        exit 1;
    }

    exit 0;
}

1;
