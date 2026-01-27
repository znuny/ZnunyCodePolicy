#!/usr/bin/env perl
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Perl::PerlCritic)

use strict;
use warnings;

use utf8;

use Code::TidyAll;
use Cwd;
use File::Basename;
use File::Spec;
use File::Temp qw(tempfile);
use FindBin    qw($RealBin);
use Getopt::Long;

use lib dirname($RealBin) . '/.';
use lib dirname($RealBin) . '/Kernel';
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use TidyAll::Znuny;

# Ensure UTF-8 output works.
binmode( \*STDOUT, ':encoding(UTF-8)' );
binmode( \*STDERR, ':encoding(UTF-8)' );

my %Options;
GetOptions(
    'help'            => \$Options{Help},
    'verbose'         => \$Options{Verbose},
    'install-eslint'  => \$Options{InstallESLint},
    'mode=s'          => \$Options{Mode},
    'process-limit=s' => \$Options{ProcessLimit},
    'all-files'       => \$Options{AllFiles},
    'staged-files'    => \$Options{StagedFiles},
    'directory=s'     => \$Options{Directory},
    'file-path=s'     => \$Options{FilePath},
);

if ( $Options{Help} ) {
    print <<"EOF";
Usage: bin/znuny.CodePolicy.pl

    Performs Znuny code policy checks with automatic configuration file loading.
    Run this script from the **top-level directory** of your package or Znuny installation.
    By default it will process all changed files (staged and unstaged) that are already known to Git.
    Other file selection options are --all-files, --staged-files, --file-path and --directory.

        Extensions Configuration Files:
    This script automatically loads extensions .tidyallrc configuration files from Kernel/TidyAll/:
    - custom.tidyallrc
    - Any other *.tidyallrc files in the directory

    These files are loaded in alphabetical order after the main tidyallrc configuration.
    This allows for modular plugin configurations and custom rule sets.

Options:
    -h, --help                 Show this usage message
    -v, --verbose              Activate diagnostics (shows loaded extensions config files)
    -i, --install-eslint       Install ESLint via npm
    -m, --mode                 Use custom Code::TidyAll mode (default: cli)
    -p, --process-limit        Max. number of processes to use (default: environment variable ZNUNY_CODE_POLICY_PROCESS_LIMIT if set, otherwise 6)
    -a, --all-files            Checks all files in all subdirectories recursively
    -s, --staged-files         Checks only files staged for a Git commit
    -f, --file-path            Checks only given file
    -d, --directory            Checks only given directory
EOF

    exit 0;
}

my $BinDir = dirname($0);

if ( $Options{InstallESLint} ) {
    my $ESLintDir = $BinDir . '/../Kernel/TidyAll/Plugin/Znuny/JavaScript/ESLint';

    if ( !-d $ESLintDir ) {
        print "Error: Please run this command from the top-level directory of your package or Znuny installation.\n";
        exit 1;
    }

    my $RedirectOutput = $Options{Verbose} ? '' : '--silent > /dev/null';

    print "Performing `npm install --no-save` to make sure all needed Node.js modules are present...\n";

    my $Success = system("cd $ESLintDir && npm install --no-save $RedirectOutput");

    if ( $Success != 0 ) {
        print "Error: Something went wrong during `npm install --no-save`.\n";
        exit 1;
    }

    print "Done.\n";
    exit 0;
}

# Find extensions files in the Kernel/TidyAll directory
sub FindExtensionsTidyAllrc {
    my $TidyAllDir      = $BinDir . '/../Kernel/TidyAll';
    my @ExtensionsFiles = ();

    # Look for *.tidyallrc files in the TidyAll directory
    if ( -d $TidyAllDir ) {
        opendir( my $DH, $TidyAllDir ) || die "Cannot open directory $TidyAllDir: $!";
        my @TidyAllrcFiles = grep { /\.tidyallrc$/ && -f "$TidyAllDir/$_" } readdir($DH);
        closedir($DH);

        # Sort files to ensure consistent loading order
        @TidyAllrcFiles = sort @TidyAllrcFiles;

        FILE:
        for my $FileName (@TidyAllrcFiles) {

            # Skip the main tidyallrc file
            next FILE if $FileName eq 'tidyallrc';

            my $FilePath = File::Spec->catfile( $TidyAllDir, $FileName );
            next FILE if !-f $FilePath || !-r $FilePath;

            push @ExtensionsFiles, $FilePath;
        }
    }

    return @ExtensionsFiles;
}

# Create a combined tidyallrc configuration file
sub CreateCombinedTidyAllRC {
    my ( $MainConfig, @ExtensionsConfigs ) = @_;

    return $MainConfig if !@ExtensionsConfigs;

    # Create a temporary file for the combined configuration
    my ( $FH, $TempConfig ) = tempfile(
        'tidyallrc_combined_XXXXXX',
        SUFFIX => '.ini',
        UNLINK => 1
    );

    # Read and write main configuration
    if ( open my $MainFH, '<', $MainConfig ) {
        while ( my $Line = <$MainFH> ) {
            print $FH $Line;
        }
        close $MainFH;
    }
    else {
        die "Cannot read main tidyallrc file: $MainConfig\n";
    }

    # Add separator and extensions configurations
    for my $ExtensionsConfig (@ExtensionsConfigs) {
        my $ConfigName = basename($ExtensionsConfig);
        print $FH "\n; ==== Extensions configuration from: $ConfigName ====\n";

        if ( open my $AddFH, '<', $ExtensionsConfig ) {
            while ( my $Line = <$AddFH> ) {
                print $FH $Line;
            }
            close $AddFH;
        }
        else {
            warn "Cannot read extensions tidyallrc file: $ExtensionsConfig\n";
        }
    }

    close $FH;

    print "Created combined configuration with " . scalar(@ExtensionsConfigs) . " extensions file(s).\n"
        if $Options{Verbose};

    return $TempConfig;
}

# Find and combine extensions files
my $MainTidyAllrc            = $BinDir . '/../Kernel/TidyAll/tidyallrc';
my @ExtensionsTidyAllrcFiles = FindExtensionsTidyAllrc();

# Show found extensions files in verbose mode
if ( $Options{Verbose} && @ExtensionsTidyAllrcFiles ) {
    print "================================================================================\n";
    print "Found extensions tidyallrc files:\n";
    for my $FilePath (@ExtensionsTidyAllrcFiles) {
        my $FileName = basename($FilePath);
        print "  - $FileName\n";
    }
}

my $TidyAllrcToUse = CreateCombinedTidyAllRC( $MainTidyAllrc, @ExtensionsTidyAllrcFiles );

my $TidyAllObject = TidyAll::Znuny->new_from_conf_file(
    $TidyAllrcToUse,
    check_only => 0,
    mode       => $Options{Mode} // 'cli',
    root_dir   => getcwd(),
    data_dir   => File::Spec->tmpdir(),
    verbose    => $Options{Verbose} ? 1 : 0,
    CLIOptions => \%Options,
);

my $TidyAllSettings = $TidyAllObject->GetSettings();

if (
    !$TidyAllObject->HasValidContext()
    || (
        $TidyAllSettings->{'Context::OPM'}
        && !$TidyAllSettings->{'SOPM::HasSupportedFrameworkVersion'}
    )
    )
{
    print
        "Framework and/or OPM information could not be retrieved or OPM framework version is incompatible. Note that only the framework versions of the executed code policy are supported.\n";

# Use exit code 0 (not 1) because the CI environment's git hook should not lead to reject the push if the framework version is not supported.
    if ( $Options{Mode} && $Options{Mode} eq 'ci' ) {
        exit 1;
    }
    else {
        exit 0;
    }
}

print "================================================================================\n";
print "Code policy context:         " . ( $TidyAllSettings->{'Context::Framework'} ? 'Framework' : 'OPM' ) . "\n";
print "Vendor:                      $TidyAllSettings->{Vendor}\n";
print "Product name:                $TidyAllSettings->{ProductName}\n";
print "================================================================================\n";

if ( !@{ $TidyAllSettings->{'FilePaths::Check'} // [] } ) {
    print "No files to check.\n";
    exit 0;
}

my $TidyAllResults = $TidyAllObject->ProcessFilePathsParallel(
    ProcessLimit     => $Options{ProcessLimit},
    FilePathsToCheck => $TidyAllSettings->{'FilePaths::Check'},
);

my $ExitCode = $TidyAllObject->PrintResults($TidyAllResults);
exit $ExitCode;
