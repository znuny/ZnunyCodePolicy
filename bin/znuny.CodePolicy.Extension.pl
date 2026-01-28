#!/usr/bin/env perl
# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use Cwd            qw(getcwd abs_path);
use File::Basename qw(dirname basename);
use File::Find;
use File::Path qw(make_path);
use File::Spec;
use FindBin qw($RealBin);
use Getopt::Long;
use Term::ANSIColor qw(colored);

# Ensure UTF-8 output works.
binmode( \*STDOUT, ':encoding(UTF-8)' );
binmode( \*STDERR, ':encoding(UTF-8)' );

# Global variables
my $TargetRepoRoot = dirname($RealBin);
my $RemovedCount   = 0;
my %Options;

# Main function to run the script
sub Run {

    # MAIN SCRIPT
    # ===========

    GetOptions(
        'help|h'    => \$Options{Help},
        'verbose|v' => \$Options{Verbose},
        'all'       => \$Options{All},
    );

    if ( $Options{Help} || !@ARGV ) {
        Usage();
    }

    my $Command = shift @ARGV;
    if ( $Command !~ /^(add|remove|status)$/ ) {
        Print( 'error', "ERROR: Invalid command '$Command'. Use 'add', 'remove', or 'status'." );
        Usage();
    }

    # Handle special cases for '--all'
    my $ExtensionName;
    if ( $Command eq 'status' ) {

        # Status command doesn't need an extension name
        $ExtensionName = '';
    }
    elsif ( ( $Command eq 'remove' || $Command eq 'add' ) && $Options{All} ) {
        $ExtensionName = '--all';
    }
    elsif ( !@ARGV && $Command eq 'remove' && !$Options{All} ) {
        Print( 'error', "ERROR: Extension name required for remove command (or use --all)." );
        Usage();
    }
    elsif ( !@ARGV && $Command eq 'add' && !$Options{All} ) {
        Print( 'error', "ERROR: Extension name required for add command (or use --all)." );
        Usage();
    }
    elsif ( !@ARGV && $Command ne 'status' ) {
        Print( 'error', "ERROR: Extension name required." );
        Usage();
    }
    elsif ( $Command ne 'status' ) {
        $ExtensionName = $ARGV[0];
    }

    my $ExtensionsDir = File::Spec->catdir( $TargetRepoRoot, 'Extensions' );
    my $ExtensionDir  = $Options{All} ? '' : File::Spec->catdir( $ExtensionsDir, $ExtensionName );

    Print( 'header', "=== ZnunyCodePolicy Extension Management ===" );
    Print("\n\n");
    if ( $Options{Verbose} ) {
        Print( 'info', "Command: $Command" );
        Print( 'info', "Extension: $ExtensionName" );
    }
    if ( !$Options{All} ) {
        Print( 'info', "Extensions directory: $ExtensionsDir \n" );
        Print( 'info', "Target directory:     $TargetRepoRoot \n" );
    }
    Print("\n");

    # Check if Extensions directory exists
    if ( !$Options{All} && !-d $ExtensionsDir ) {
        Print( 'error', "ERROR: Extensions/ directory not found!\n" );

        # Create the directory
        make_path($ExtensionsDir) || die "Cannot create directory $ExtensionsDir: $!";
        Print( 'error', "Created Extensions directory: $ExtensionsDir\n\n" );
    }

    # Check if specific extension directory exists (for add command)
    if ( $Command eq 'add' && !$Options{All} && !-d $ExtensionDir ) {
        Print( 'error', "ERROR: Extension '$ExtensionName' not found in Extensions/ directory!" );
        Print( 'error', "Extension path: $ExtensionDir" );
        Print("\n");
        Print( 'info', "Available extensions:" );
        my @AvailableExtensions = ListAvailableExtensions();
        if (@AvailableExtensions) {
            for my $Extension (@AvailableExtensions) {
                Print("  - $Extension\n");
            }
        }
        else {
            Print("  No extensions found\n");
        }
        exit 1;
    }

    # Check if we're in a valid ZnunyCodePolicy repository
    my $TidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    if ( !-d $TidyAllDir ) {
        Print( 'error', "ERROR: ZnunyCodePolicy repository structure not found!" );
        Print( 'error', "Please run this script from the ZnunyCodePolicy root directory:" );
        Print( 'error', "  cd /path/to/ZnunyCodePolicy" );
        Print( 'error', "  perl bin/znuny.CodePolicy.Extension.pl $Command $ExtensionName" );
        exit 1;
    }

    # Convert to absolute paths (for add command)
    if ( $Command eq 'add' && !$Options{All} ) {
        $ExtensionDir = abs_path($ExtensionDir);
        Print( 'info', "Extension directory: $ExtensionDir" );
        Print("\n");
        Print( 'info', "Extension name: $ExtensionName" );
        Print("\n\n");
    }

    # MAIN EXECUTION
    # ==============

    if ( $Command eq 'add' ) {
        AddCommand( $ExtensionName, $ExtensionDir, $ExtensionsDir );
    }
    elsif ( $Command eq 'remove' ) {
        RemoveCommand( $ExtensionName, $ExtensionsDir );
    }
    elsif ( $Command eq 'status' ) {
        StatusCommand();
    }

    exit 0;
}

sub Usage {
    my @AvailableExtensions = ListAvailableExtensions();

    Print( 'info',   "Usage: \n" );
    Print( 'green',  "$0 " );
    Print( 'yellow', " <command> <extension-name> " );
    Print( 'white',  "[options]" );
    Print("\n\n");

    Print( 'white', "Manage ZnunyCodePolicy extensions from the Extensions/ directory." );
    Print("\n\n");

    Print( 'yellow', "Commands:\n" );
    Print( 'green',  "  add" );
    Print( 'yellow', " <extension-name>" );
    Print( 'white',  "      Add an extension\n" );
    Print( 'green',  "  add" );
    Print( 'yellow', " --all" );
    Print( 'white',  "                 Add all available extensions\n" );

    Print( 'green',  "  remove" );
    Print( 'yellow', " <extension-name>" );
    Print( 'white',  "   Remove an extension\n" );
    Print( 'green',  "  remove" );
    Print( 'yellow', " --all" );
    Print( 'white',  "              Remove all extension links (use with caution)\n" );

    Print( 'green', "  status" );
    Print( 'white', "                    Show status of all linked files\n\n" );

    Print( 'yellow', "Arguments:\n" );
    Print( 'yellow', "  extension-name" );
    Print( 'white',  "            Name of the extension from Extensions/ directory\n\n" );

    Print( 'yellow', "Options:\n" );
    Print( 'yellow', "  -h, --help" );
    Print( 'white',  "                Show this usage message\n" );
    Print( 'yellow', "  -v, --verbose" );
    Print( 'white',  "             Show detailed output\n\n" );

    Print( 'yellow', "Available Extensions:\n" );

    if (@AvailableExtensions) {
        for my $Extension (@AvailableExtensions) {
            Print( 'green', "  $Extension\n" );
        }
    }
    else {
        Print( 'red', "  No extensions found in Extensions/ directory.\n" );
    }

    Print( 'yellow', "\nExamples:\n" );

    if (@AvailableExtensions) {
        my $Count = 0;
        EXTENSION:
        for my $Extension (@AvailableExtensions) {

            Print( 'green',  "  $0 " );
            Print( 'yellow', "add " );
            Print( 'white',  $Extension . "\n" );
            Print( 'green',  "  $0 " );
            Print( 'yellow', "remove " );
            Print( 'white',  $Extension . "\n" );
            last EXTENSION if ++$Count >= 2;    # Show max 2 examples
        }
    }

    Print( 'green',  "  $0 " );
    Print( 'yellow', "add --all" );
    Print( 'white',  "                 # Add all available extensions\n" );
    Print( 'green',  "  $0 " );
    Print( 'yellow', "remove --all" );
    Print( 'white',  "              # Remove all extension links (use with caution)\n" );
    Print( 'green',  "  $0 " );
    Print( 'yellow', "status" );
    Print( 'white',  "                    # Show status of all linked files\n\n" );

    Print( 'yellow', "The extension should contain:\n" );
    Print( 'white',  " - Kernel/TidyAll/*.tidyallrc (configuration files)\n" );
    Print( 'white',  " - Kernel/TidyAll/Plugin/     (custom plugins)\n" );
    Print( 'white',  " - scripts/test/              (test files)\n\n" );

    exit 1;
}

# Function to the add command
sub AddCommand {
    my ( $ExtensionName, $ExtensionDir, $ExtensionsDir ) = @_;

    if ( $Options{All} ) {
        AddAllExtensions($ExtensionsDir);
    }
    else {
        AddSingleExtension( $ExtensionName, $ExtensionDir );
    }
    return;
}

# Function to adding a single extension
sub AddSingleExtension {
    my ( $ExtensionName, $ExtensionDir ) = @_;

    CleanupOldLinks($ExtensionName);
    LinkTidyAllFiles( $ExtensionDir, $ExtensionName );
    Print("\n");
    LinkTidyAllPmFiles( $ExtensionDir, $ExtensionName );
    Print("\n");
    LinkPluginDirectories( $ExtensionDir, $ExtensionName );
    Print("\n");
    LinkTests( $ExtensionDir, $ExtensionName );
    Print("\n");
    LinkDocumentation( $ExtensionDir, $ExtensionName );
    Print("\n");
    AddGitignore();
    Print("\n");
    PrintAdditionSummary( $ExtensionName, $ExtensionDir );
    return;
}

# Function to handle adding all extensions
sub AddAllExtensions {
    my ($ExtensionsDir) = @_;

    my @AvailableExtensions = ListAvailableExtensions();

    if ( !@AvailableExtensions ) {
        Print( 'warning', "No extensions found in Extensions/ directory.\n" );
        exit 0;
    }

    Print( 'warning', "⚠ WARNING: Adding ALL available extensions!\n" );
    Print( 'warning', "This will add the following extensions:" );
    for my $Ext (@AvailableExtensions) {
        Print("\n");
        Print( 'warning', "  - $Ext" );
    }
    Print("\n\n");
    Print( 'magenta', "Are you sure you want to continue? [Y/n]: " );

    my $Response = <ARGV>;
    if ( $Response ) {
        chomp $Response;
    }

    if ( $Response && $Response =~ /^[nN]$/ ) {
        Print("\n");
        Print( 'success', "✓ Aborted." );
        exit 1;
    }

    Print("\n");
    Print( 'step', "Adding All Available Extensions..." );
    Print("\n");

    # Cleanup all old links once before adding extensions
    CleanupAllOldLinks();
    Print("\n");

    for my $Extension (@AvailableExtensions) {
        my $CurrentExtensionDir = File::Spec->catdir( $ExtensionsDir, $Extension );
        $CurrentExtensionDir = abs_path($CurrentExtensionDir);

        Print("\n");
        Print( 'header', "=== Adding Extension: $Extension ===" );
        Print("\n\n");
        LinkTidyAllFiles( $CurrentExtensionDir, $Extension );
        Print("\n");
        LinkTidyAllPmFiles( $CurrentExtensionDir, $Extension );
        Print("\n");
        LinkPluginDirectories( $CurrentExtensionDir, $Extension );
        Print("\n");
        LinkTests( $CurrentExtensionDir, $Extension );
        Print("\n");
        LinkDocumentation( $CurrentExtensionDir, $Extension );
        Print("\n");
    }

    # Print combined summary for all extensions
    Print("\n");
    Print( 'header', "=== Addition Summary (All Extensions) ===" );
    Print("\n\n");
    Print("Added extensions:\n");
    for my $Extension (@AvailableExtensions) {
        Print( 'green', "  - $Extension\n" );
    }
    Print("\n");
    Print( 'success', "=== All extensions added successfully! ===" );
    Print("\n\n");
    Print( 'info', "To test the extensions:" );
    Print("\n");
    Print( 'magenta', "  perl bin/znuny.CodePolicy.pl --verbose --file-path README.md\n" );
    Print("\n");
    return;
}

# Function to print addition summary
sub PrintAdditionSummary {
    my ( $ExtensionName, $ExtensionDir ) = @_;

    Print( 'header', "=== Addition Summary ===" );
    Print("\n\n");
    Print( 'info', "Extension: $ExtensionName" );
    Print("\n");
    Print("Linked components:\n");

    # Count linked components
    my $TidyAllrcCount   = 0;
    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir );
        $TidyAllrcCount = grep { /\.tidyallrc$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);
    }
    Print("- TidyAll configurations: ");
    Print( $TidyAllrcCount > 0 ? 'green' : 'white', $TidyAllrcCount );
    Print(" files\n");

    my $PmCount = 0;
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir );
        $PmCount = grep { /\.pm$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);
    }
    Print("- TidyAll PM files: ");
    Print( $PmCount > 0 ? 'green' : 'white', $PmCount );
    Print(" files\n");

    my $TestsCount = 0;
    my $TestsDir   = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test', $ExtensionName );
    if ( -d $TestsDir ) {
        File::Find::find( sub { $TestsCount++ if -f $_ && /\.t$/ }, $TestsDir );
    }
    Print("- Tests: ");
    Print( $TestsCount > 0 ? 'green' : 'white', $TestsCount );
    Print(" files\n");

    my $ExtPluginDir = File::Spec->catdir( $ExtensionDir, 'Kernel', 'TidyAll', 'Plugin' );
    my $PluginCount  = 0;
    if ( -d $ExtPluginDir ) {
        File::Find::find( sub { $PluginCount++ if -f $_ && /\.pm$/ }, $ExtPluginDir );
    }
    Print("- Plugins: ");
    Print( $PluginCount > 0 ? 'green' : 'white', $PluginCount );
    Print(" files\n");

    my $ExtDocDir = File::Spec->catdir( $ExtensionDir, 'doc' );
    my $DocCount  = 0;
    if ( -d $ExtDocDir ) {
        File::Find::find( sub { $DocCount++ if -f $_ }, $ExtDocDir );
    }
    Print("- Documentation: ");
    Print( $DocCount > 0 ? 'green' : 'white', $DocCount );
    Print(" files\n");

    Print("\n");
    Print( 'success', "=== Addition completed successfully! ===" );
    Print("\n\n");
    Print( 'info', "To test the extension:" );
    Print("\n");
    Print( 'magenta', "  perl bin/znuny.CodePolicy.pl --verbose --file-path README.md\n" );
    Print("\n");

    return;
}

# Function to the remove command
sub RemoveCommand {
    my ( $ExtensionName, $ExtensionsDir ) = @_;

    if ( $Options{All} ) {
        RemoveAllExtensions();
        RemoveGitignore();
    }
    else {
        RemoveSpecificExtension($ExtensionName);
        RemoveGitignore();
        AddGitignore();
    }

    Print("\n");
    PrintRemovalSummary( $ExtensionName, $ExtensionsDir, 'remove' );
    return;
}

# Function to show status of all linked files
sub StatusCommand {

    Print( 'header', "=== Extension Links Status ===" );
    Print("\n\n");

    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    my $FoundAnyLinks    = 0;

    # Check TidyAll configuration files (.tidyallrc)
    Print( 'step', "1. TidyAll Configuration Files (.tidyallrc)" );
    Print("\n");
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @TidyAllrcFiles = grep { /\.tidyallrc$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);

        if (@TidyAllrcFiles) {
            for my $File (@TidyAllrcFiles) {
                my $FilePath   = File::Spec->catfile( $KernelTidyAllDir, $File );
                my $LinkTarget = CleanupPathForDisplay( readlink($FilePath) );
                Print( 'green', "  ✓ $File" );
                Print( 'white', " -> $LinkTarget\n" );
                $FoundAnyLinks = 1;
            }
        }
        else {
            Print( 'yellow', "  ℹ No .tidyallrc links found\n" );
        }
    }

    Print("\n");

    # Check TidyAll PM files (.pm)
    Print( 'step', "2. TidyAll PM Files (.pm)" );
    Print("\n");
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @PmFiles = grep { /\.pm$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);

        if (@PmFiles) {
            for my $File (@PmFiles) {
                my $FilePath   = File::Spec->catfile( $KernelTidyAllDir, $File );
                my $LinkTarget = CleanupPathForDisplay( readlink($FilePath) );
                Print( 'green', "  ✓ $File" );
                Print( 'white', " -> $LinkTarget\n" );
                $FoundAnyLinks = 1;
            }
        }
        else {
            Print( 'yellow', "  ℹ No .pm links found\n" );
        }
    }

    Print("\n");

    # Check Plugin directories
    Print( 'step', "3. Plugin Directories" );
    Print("\n");
    my $PluginDir = File::Spec->catdir( $KernelTidyAllDir, 'Plugin' );
    if ( -d $PluginDir ) {
        opendir( my $DH, $PluginDir ) || warn "Cannot open $PluginDir: $!";
        my @PluginSubDirs = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $PluginDir, $_ ) } readdir($DH);
        closedir($DH);

        if (@PluginSubDirs) {
            for my $SubDir (@PluginSubDirs) {
                my $SubDirPath = File::Spec->catdir( $PluginDir, $SubDir );
                my $LinkTarget = CleanupPathForDisplay( readlink($SubDirPath) );
                Print( 'green', "  ✓ Plugin/$SubDir" );
                Print( 'white', " -> $LinkTarget\n" );
                $FoundAnyLinks = 1;
            }
        }
        else {
            Print( 'yellow', "  ℹ No plugin directory links found\n" );
        }
    }
    else {
        Print( 'yellow', "  ℹ Plugin directory not found\n" );
    }

    Print("\n");

    # Check Test directories (recursively look for .t files)
    Print( 'step', "4. Test Directories" );
    Print("\n");
    my $TestDir        = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test' );
    my $TestLinksFound = 0;

    if ( -d $TestDir ) {

        # Look for test files recursively in extension subdirectories
        File::Find::find(
            sub {
                return if !-f $_ || !/\.t$/ || !-l $_;

                my $FullPath     = $File::Find::name;
                my $RelativePath = File::Spec->abs2rel( $FullPath, File::Spec->catdir( $TargetRepoRoot, 'scripts' ) );
                my $LinkTarget   = CleanupPathForDisplay( readlink($FullPath) );

                Print( 'green', "  ✓ scripts/$RelativePath" );
                Print( 'white', " -> $LinkTarget\n" );
                $TestLinksFound = 1;
                $FoundAnyLinks  = 1;
            },
            $TestDir
        );

        if ( !$TestLinksFound ) {
            Print( 'yellow', "  ℹ No test file links found\n" );
        }
    }
    else {
        Print( 'yellow', "  ℹ Test directory not found\n" );
    }

    Print("\n");

    # Check Documentation directories
    Print( 'step', "5. Documentation Directories" );
    Print("\n");
    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc' );
    if ( -d $DocDir ) {
        opendir( my $DH, $DocDir ) || warn "Cannot open $DocDir: $!";
        my @DocItems = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $DocDir, $_ ) } readdir($DH);
        closedir($DH);

        if (@DocItems) {
            for my $Item (@DocItems) {
                my $ItemPath   = File::Spec->catdir( $DocDir, $Item );
                my $LinkTarget = CleanupPathForDisplay( readlink($ItemPath) );
                Print( 'green', "  ✓ doc/$Item" );
                Print( 'white', " -> $LinkTarget\n" );
                $FoundAnyLinks = 1;
            }
        }
        else {
            Print( 'yellow', "  ℹ No documentation directory links found\n" );
        }
    }
    else {
        Print( 'yellow', "  ℹ Documentation directory not found\n" );
    }

    Print("\n");

    # Summary
    if ($FoundAnyLinks) {
        Print( 'success', "=== Status: Extensions are active ===\n" );
    }
    else {
        Print( 'success', "=== Status: No extension links found ===\n\n" );
        Print( 'info',    "Use 'add' command to activate extensions.\n" );
    }

    return;
}

# Function to removing a specific extension
sub RemoveSpecificExtension {
    my ($ExtensionName) = @_;

    Print("\n");
    Print( 'header', "=== Removing specific extension links ===" );
    Print("\n");

    Print( 'step', "1. Removing TidyAll Configuration Files for: $ExtensionName..." );
    Print("\n");
    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @TidyAllrcFiles = grep {/\.tidyallrc$/} readdir($DH);
        closedir($DH);

        for my $File (@TidyAllrcFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            if ( -l $FilePath && IsLinkPointsToExtension( $FilePath, $ExtensionName ) ) {
                RemoveLink( $FilePath, "TidyAll configuration" );
            }
        }
    }

    Print("\n");
    Print( 'step', "2. Removing TidyAll PM Files for: $ExtensionName..." );
    Print("\n");
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @PmFiles = grep {/\.pm$/} readdir($DH);
        closedir($DH);

        for my $File (@PmFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            if ( -l $FilePath && IsLinkPointsToExtension( $FilePath, $ExtensionName ) ) {
                RemoveLink( $FilePath, "TidyAll PM file" );
            }
        }
    }

    Print("\n");
    Print( 'step', "3. Removing Plugin Subdirectories for: $ExtensionName..." );
    Print("\n");

    # Find and remove plugin subdirectories that belong to this extension
    my $ExtensionDir = File::Spec->catdir( $TargetRepoRoot, 'Extensions', $ExtensionName );
    my $ExtPluginDir = File::Spec->catdir( $ExtensionDir,   'Kernel',     'TidyAll', 'Plugin' );

    if ( -d $ExtPluginDir ) {
        opendir( my $DH, $ExtPluginDir ) || warn "Cannot open $ExtPluginDir: $!";
        my @PluginSubDirs = grep { $_ ne '.' && $_ ne '..' && -d File::Spec->catdir( $ExtPluginDir, $_ ) } readdir($DH);
        closedir($DH);

        my $TargetPluginDir = File::Spec->catdir( $KernelTidyAllDir, 'Plugin' );
        for my $SubDir (@PluginSubDirs) {
            my $TargetSubDir = File::Spec->catdir( $TargetPluginDir, $SubDir );
            RemoveLink( $TargetSubDir, "Plugin subdirectory" );
        }
    }

    Print("\n");
    Print( 'step', "4. Removing Test Directory for: $ExtensionName..." );
    Print("\n");
    my $TestDir = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test', $ExtensionName );
    if ( -l $TestDir ) {
        RemoveLink( $TestDir, "Test directory" );
    }
    elsif ( -d $TestDir ) {

        # Remove all test links recursively
        File::Find::finddepth(
            sub {
                if ( -l $_ ) {
                    RemoveLink( $File::Find::name, "Test file" );
                }
                elsif ( -d $_ && $_ ne $TestDir ) {
                    RemoveEmptyDir($_);
                }
            },
            $TestDir
        );
        RemoveEmptyDir($TestDir);
    }

    Print("\n");
    Print( 'step', "5. Removing Documentation Directory for: $ExtensionName..." );
    Print("\n");
    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc', $ExtensionName );
    RemoveLink( $DocDir, "Documentation directory" );
    return;
}

# Function to removing all extensions
sub RemoveAllExtensions {

    # Get list of currently linked extensions
    my @LinkedExtensions = GetLinkedExtensions();

    Print( 'warning', "⚠ WARNING: Removing ALL extension links!" );
    Print("\n");
    if (@LinkedExtensions) {
        Print( 'warning', "This will remove the following extensions:\n" );
        for my $Extension (@LinkedExtensions) {
            Print( 'yellow', "  - $Extension\n" );
        }
        Print("\n");
    }
    else {
        Print( 'info', "No extension links found to remove." );
        exit 0;
    }

    Print( 'warning', "This will remove all symbolic links in:" );
    Print("\n");
    Print( 'warning', "  - Kernel/TidyAll/ (*.tidyallrc files)" );
    Print("\n");
    Print( 'warning', "  - Kernel/TidyAll/ (*.pm files)" );
    Print("\n");
    Print( 'warning', "  - Kernel/TidyAll/Plugin/ (plugin directories)" );
    Print("\n");
    Print( 'warning', "  - scripts/test/ (test directories)" );
    Print("\n");
    Print( 'warning', "  - doc/ (documentation directories)" );
    Print("\n\n");
    Print( 'magenta', "Are you sure you want to continue? [Y/n]: " );
    Print("\n");

    my $Response = <ARGV>;
    chomp $Response;
    if ( $Response =~ /^[nN]$/ ) {
        Print("\n");
        Print( 'success', "✓ Aborted." );
        exit 1;
    }

    Print("\n");
    Print( 'header', "=== Removing ALL extension links ===" );
    Print("\n");

    Print( 'step', "1. Removing All .tidyallrc Symbolic Links..." );
    Print("\n");
    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @TidyAllrcFiles = grep {/\.tidyallrc$/} readdir($DH);
        closedir($DH);

        for my $File (@TidyAllrcFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            RemoveLink( $FilePath, "TidyAll configuration" ) if -l $FilePath;
        }
    }

    Print("\n");
    Print( 'step', "2. Removing All TidyAll PM Links..." );
    Print("\n");
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @PmFiles = grep {/\.pm$/} readdir($DH);
        closedir($DH);

        for my $File (@PmFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            RemoveLink( $FilePath, "TidyAll PM file" ) if -l $FilePath;
        }
    }

    Print("\n");
    Print( 'step', "3. Removing All Plugin Directory Links..." );
    Print("\n");
    my $PluginDir = File::Spec->catdir( $KernelTidyAllDir, 'Plugin' );
    if ( -d $PluginDir ) {
        opendir( my $DH, $PluginDir ) || warn "Cannot open $PluginDir: $!";
        my @PluginSubDirs = readdir($DH);
        closedir($DH);

        PLUGIN_SUBDIR:
        for my $SubDir (@PluginSubDirs) {
            next PLUGIN_SUBDIR if $SubDir eq '.' || $SubDir eq '..';
            my $SubDirPath = File::Spec->catdir( $PluginDir, $SubDir );
            RemoveLink( $SubDirPath, "Plugin directory" ) if -l $SubDirPath;
        }
    }

    Print("\n");
    Print( 'step', "4. Removing All Test Directory Links..." );
    Print("\n");
    my $TestDir = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test' );
    if ( -d $TestDir ) {
        opendir( my $DH, $TestDir ) || warn "Cannot open $TestDir: $!";
        my @TestItems = readdir($DH);
        closedir($DH);

        TEST_ITEM:
        for my $Item (@TestItems) {
            next TEST_ITEM if $Item eq '.' || $Item eq '..';
            my $ItemPath = File::Spec->catdir( $TestDir, $Item );
            RemoveLink( $ItemPath, "Test directory" ) if -l $ItemPath;
        }
    }

    Print("\n");
    Print( 'step', "5. Removing All Documentation Directory Links..." );
    Print("\n");
    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc' );
    if ( -d $DocDir ) {
        opendir( my $DH, $DocDir ) || warn "Cannot open $DocDir: $!";
        my @DocItems = readdir($DH);
        closedir($DH);

        DOC_ITEM:
        for my $Item (@DocItems) {
            next DOC_ITEM if $Item eq '.' || $Item eq '..';
            my $ItemPath = File::Spec->catdir( $DocDir, $Item );
            RemoveLink( $ItemPath, "Documentation directory" ) if -l $ItemPath;
        }
    }
    return;
}

# Function to print removal summary
sub PrintRemovalSummary {
    my ( $ExtensionName, $ExtensionsDir, $Command ) = @_;

    Print("\n");
    Print("\n");
    Print( 'header', "=== Removal Summary ===" );
    Print("\n");
    if ( $ExtensionName eq '--all' ) {
        Print( 'info', "Removed ALL extension links from ZnunyCodePolicy" );
    }
    else {
        Print( 'info', "Extension: $ExtensionName" );
        Print( 'info', "Removed symbolic links and empty directories" );
    }

    # Count remaining links (approximate)
    my $RemainingTidyallrc = 0;
    my $RemainingPm        = 0;
    my $RemainingPlugins   = 0;
    my $RemainingTests     = 0;
    my $RemainingDocs      = 0;

    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir );
        $RemainingTidyallrc = grep { /\.tidyallrc$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);
    }

    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir );
        $RemainingPm = grep { /\.pm$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);
    }

    my $PluginDir = File::Spec->catdir( $KernelTidyAllDir, 'Plugin' );
    if ( -d $PluginDir ) {
        opendir( my $DH, $PluginDir );
        $RemainingPlugins = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $PluginDir, $_ ) } readdir($DH);
        closedir($DH);
    }

    my $TestDir = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test' );
    if ( -d $TestDir ) {
        opendir( my $DH, $TestDir );
        $RemainingTests = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $TestDir, $_ ) } readdir($DH);
        closedir($DH);
    }

    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc' );
    if ( -d $DocDir ) {
        opendir( my $DH, $DocDir );
        $RemainingDocs = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $DocDir, $_ ) } readdir($DH);
        closedir($DH);
    }

    Print("Remaining extension links:\n");
    Print("- TidyAll configurations: ");
    Print( $RemainingTidyallrc == 0 ? 'green' : 'red', $RemainingTidyallrc );
    Print(" files\n");
    Print("- TidyAll PM files: ");
    Print( $RemainingPm == 0 ? 'green' : 'red', $RemainingPm );
    Print(" files\n");
    Print("- Plugins: ");
    Print( $RemainingPlugins == 0 ? 'green' : 'red', $RemainingPlugins );
    Print(" files\n");
    Print("- Tests: ");
    Print( $RemainingTests == 0 ? 'green' : 'red', $RemainingTests );
    Print(" files\n");
    Print("- Documentation: ");
    Print( $RemainingDocs == 0 ? 'green' : 'red', $RemainingDocs );
    Print(" files\n");

    Print( 'success', "\n=== Removal completed successfully! ===\n" );

    if ( $ExtensionName ne '--all' && $Command eq 'remove' ) {
        my $ExtensionCheckDir = File::Spec->catdir( $ExtensionsDir, $ExtensionName );
        if ( -d $ExtensionCheckDir ) {
            Print( 'info', "Note: The extension directory '$ExtensionName' still exists in Extensions/." );
            Print( 'info', "If it's a git submodule, you can remove it with:" );
            Print( 'info', "  cd Extensions && git submodule deinit -f $ExtensionName\n" );
            Print( 'info', "  cd Extensions && git rm $ExtensionName\n" );
            Print( 'info', "  rm -rf .git/modules/Extensions/$ExtensionName\n" );
        }
        else {
            Print( 'info', "Extension directory '$ExtensionName' not found or already removed from Extensions/." );
        }
    }

    Print( 'info', "\nTo verify removal:" );
    Print( 'info', " perl bin/znuny.CodePolicy.pl --verbose --file-path README.md\n\n" );
    return;
}

# Function to list available extensions
sub ListAvailableExtensions {
    my $ExtensionsDir = File::Spec->catdir( $TargetRepoRoot, 'Extensions' );

    if ( !-d $ExtensionsDir ) {
        Print( 'warning', "No extension directory found.\n" );
        return ();
    }

    opendir( my $DH, $ExtensionsDir ) || return ();
    my @Extensions = grep { $_ ne '.' && $_ ne '..' && -d File::Spec->catdir( $ExtensionsDir, $_ ) } readdir($DH);
    closedir($DH);

    @Extensions = sort @Extensions;
    return @Extensions;
}

# Function to get list of currently linked extensions
sub GetLinkedExtensions {
    my @LinkedExtensions;
    my %ExtensionSeen;

    # Check TidyAll plugin directories
    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot,   'Kernel', 'TidyAll' );
    my $PluginDir        = File::Spec->catdir( $KernelTidyAllDir, 'Plugin' );
    if ( -d $PluginDir ) {
        opendir( my $DH, $PluginDir ) || warn "Cannot open $PluginDir: $!";
        my @PluginSubDirs = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $PluginDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $Extension (@PluginSubDirs) {
            $ExtensionSeen{$Extension} = 1;
        }
    }

    # Check test directories
    my $TestDir = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test' );
    if ( -d $TestDir ) {
        opendir( my $DH, $TestDir ) || warn "Cannot open $TestDir: $!";
        my @TestItems = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $TestDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $Extension (@TestItems) {
            $ExtensionSeen{$Extension} = 1;
        }
    }

    # Check doc directories
    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc' );
    if ( -d $DocDir ) {
        opendir( my $DH, $DocDir ) || warn "Cannot open $DocDir: $!";
        my @DocItems = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $DocDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $Extension (@DocItems) {
            $ExtensionSeen{$Extension} = 1;
        }
    }

    @LinkedExtensions = sort keys %ExtensionSeen;
    return @LinkedExtensions;
}

# Function to cleanup path for display (remove relative path components)
sub CleanupPathForDisplay {
    my ($Path) = @_;

    # Remove leading relative path components like ../../ or ../
    $Path =~ s|^(?:\.\./)+||;

    return $Path;
}

# Function to check if a link points to our extension
sub IsLinkPointsToExtension {
    my ( $LinkPath, $ExtensionName ) = @_;

    my $LinkTarget = readlink($LinkPath);
    return 0 if !defined $LinkTarget;

    return $LinkTarget =~ /\Q$ExtensionName\E/;
}

# Function to create directory if it doesn't exist
sub CreateDir {
    my ($Dir) = @_;

    if ( !-d $Dir ) {
        make_path($Dir) || die "Cannot create directory $Dir: $!";
        if ( $Options{Verbose} ) {
            Print( 'green', "  ✓ Created directory: $Dir\n" );
        }
    }
    return 1;
}

# Function to create symbolic link
sub CreateLink {
    my ( $Source, $Target, $Description ) = @_;

    # Remove existing link if present
    if ( -l $Target ) {
        unlink $Target || warn "Cannot remove existing link $Target: $!";
    }
    elsif ( -e $Target ) {
        Print( 'warning', "  WARNING: $Target exists and is not a symbolic link. Skipping..." );
        return 0;
    }

    # Calculate relative path from target to source
    my $RelSource = File::Spec->abs2rel( $Source, dirname($Target) );

    # Create the symbolic link
    symlink( $RelSource, $Target ) || do {
        Print( 'error', "Cannot create symbolic link $Target -> $RelSource: $!" );
        return 0;
    };

    Print( 'green', "  ✓ Linked: " );
    Print( 'info',  basename($Source) . " -> $Target\n" );
    return 1;
}

# Function to link TidyAll files
sub LinkTidyAllFiles {
    my ( $ExtensionDir, $ExtensionName ) = @_;

    Print( 'step', "2. Linking TidyAll Configuration Files for: $ExtensionName..." );
    Print("\n");

    my $ExtTidyAllDir    = File::Spec->catdir( $ExtensionDir,   'Kernel', 'TidyAll' );
    my $TargetTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );

    if ( !-d $ExtTidyAllDir ) {
        Print( 'warning', "  ⚠ No Kernel/TidyAll directory found in extension" );
        return;
    }

    # Link .tidyallrc files (1:1, no prefix modification)
    opendir( my $DH, $ExtTidyAllDir ) || warn "Cannot open $ExtTidyAllDir: $!";
    my @TidyAllrcFiles = grep { /\.tidyallrc$/ && -f File::Spec->catfile( $ExtTidyAllDir, $_ ) } readdir($DH);
    closedir($DH);

    for my $File (@TidyAllrcFiles) {
        my $SourceFile = File::Spec->catfile( $ExtTidyAllDir,    $File );
        my $TargetFile = File::Spec->catfile( $TargetTidyAllDir, $File );
        CreateLink( $SourceFile, $TargetFile, "TidyAll configuration" );
    }
    return;
}

# Function to link TidyAll PM files
sub LinkTidyAllPmFiles {
    my ( $ExtensionDir, $ExtensionName ) = @_;

    Print( 'step', "3. Linking TidyAll PM Files for: $ExtensionName..." );
    Print("\n");

    my $ExtTidyAllDir    = File::Spec->catdir( $ExtensionDir,   'Kernel', 'TidyAll' );
    my $TargetTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );

    if ( !-d $ExtTidyAllDir ) {
        Print( 'warning', "  ⚠ No Kernel/TidyAll directory found in extension" );
        return;
    }

    # Link .pm files (1:1, no prefix modification)
    opendir( my $DH, $ExtTidyAllDir ) || warn "Cannot open $ExtTidyAllDir: $!";
    my @PmFiles = grep { /\.pm$/ && -f File::Spec->catfile( $ExtTidyAllDir, $_ ) } readdir($DH);
    closedir($DH);

    for my $File (@PmFiles) {
        my $SourceFile = File::Spec->catfile( $ExtTidyAllDir,    $File );
        my $TargetFile = File::Spec->catfile( $TargetTidyAllDir, $File );
        CreateLink( $SourceFile, $TargetFile, "TidyAll PM file" );
    }
    return;
}

# Function to link plugin directories
sub LinkPluginDirectories {
    my ( $ExtensionDir, $ExtensionName ) = @_;

    Print( 'step', "4. Linking Plugin Directories for: $ExtensionName..." );
    Print("\n");

    my $ExtTidyAllDir    = File::Spec->catdir( $ExtensionDir,   'Kernel', 'TidyAll' );
    my $TargetTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );

    if ( !-d $ExtTidyAllDir ) {
        Print( 'warning', "  ⚠ No Kernel/TidyAll directory found in extension" );
        return;
    }

    # Link Plugin directory contents
    my $ExtPluginDir = File::Spec->catdir( $ExtTidyAllDir, 'Plugin' );
    if ( -d $ExtPluginDir ) {
        my $TargetPluginDir = File::Spec->catdir( $TargetTidyAllDir, 'Plugin' );

        # Link each subdirectory in the Plugin directory individually
        opendir( my $DH, $ExtPluginDir ) || warn "Cannot open $ExtPluginDir: $!";
        my @PluginSubDirs = grep { $_ ne '.' && $_ ne '..' && -d File::Spec->catdir( $ExtPluginDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $SubDir (@PluginSubDirs) {
            my $SourceSubDir = File::Spec->catdir( $ExtPluginDir,    $SubDir );
            my $TargetSubDir = File::Spec->catdir( $TargetPluginDir, $SubDir );
            CreateLink( $SourceSubDir, $TargetSubDir, "Plugin subdirectory" );
        }
    }
    else {
        Print( 'warning', "  ⚠ No Plugin directory found in extension" );
    }
    return;
}

# Function to link tests
sub LinkTests {
    my ( $ExtensionDir, $ExtensionName ) = @_;

    Print( 'step', "5. Linking Test Directory for: $ExtensionName..." );
    Print("\n");

    my $ExtTestDir    = File::Spec->catdir( $ExtensionDir,   'scripts', 'test' );
    my $TargetTestDir = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test', $ExtensionName );

    if ( !-d $ExtTestDir ) {
        Print( 'warning', "  ⚠ No scripts/test directory found in extension" );
        return;
    }

    CreateDir($TargetTestDir);

    # Link all test files recursively
    File::Find::find(
        sub {
            return if !/\.t$/;
            return if !-f $_ && !( -l $_ && -f readlink($_) );

            my $SourceFile = $File::Find::name;
            my $RelPath    = File::Spec->abs2rel( $SourceFile, $ExtTestDir );
            my $TargetFile = File::Spec->catfile( $TargetTestDir, $RelPath );
            my $TargetDir  = dirname($TargetFile);

            CreateDir($TargetDir);
            CreateLink( $SourceFile, $TargetFile, "Test file" );
        },
        $ExtTestDir
    );
    return;
}

# Function to link documentation
sub LinkDocumentation {
    my ( $ExtensionDir, $ExtensionName ) = @_;

    Print( 'step', "6. Linking Documentation Directory for: $ExtensionName..." );
    Print("\n");

    # Documentation
    my $ExtDocDir = File::Spec->catdir( $ExtensionDir, 'doc' );
    if ( -d $ExtDocDir ) {
        my $TargetDocDir = File::Spec->catdir( $TargetRepoRoot, 'doc', $ExtensionName );
        CreateLink( $ExtDocDir, $TargetDocDir, "Documentation directory" );
    }
    else {
        Print( 'warning', "  ⚠ No documentation directory found in extension" );
    }
    return;
}

# Function to safely remove symbolic link
sub RemoveLink {
    my ( $Target, $Description ) = @_;

    if ( -l $Target ) {
        if ( unlink $Target ) {

            Print( 'green', "  ✓ Removed: " );
            Print( 'info',  "$Target ($Description)\n" );
            $RemovedCount++;
            return 1;
        }
        else {
            Print( 'error', "  Cannot remove $Target: $!" );
            return 0;
        }
    }
    elsif ( -e $Target ) {
        Print( 'warning', "  ⚠ WARNING: $Target exists but is not a symbolic link. Skipping for safety." );
        return 0;
    }
    else {
        if ( $Options{Verbose} ) {
            Print( 'cyan', "  ℹ Not found: $Target\n" );
        }
        return 1;
    }
}

# Function to remove directory if empty and it's a symbolic link directory
sub RemoveEmptyDir {
    my ($Dir) = @_;

    if ( -l $Dir ) {
        if ( unlink $Dir ) {
            Print( 'green', "  ✓ Removed directory link: $Dir\n" );
            return 1;
        }
    }
    elsif ( -d $Dir && !glob("$Dir/*") && !glob("$Dir/.*") ) {

        # Only remove if truly empty (no files, no hidden files except . and ..)
        if ( rmdir $Dir ) {
            Print( 'green', "  ✓ Removed empty directory: $Dir\n" );
            return 1;
        }
    }
    return 0;
}

# Function to remove old extension links
sub CleanupOldLinks {
    my ($ExtensionName) = @_;

    Print( 'step', "1. Cleaning Up Old Extension Links for: $ExtensionName..." );
    Print("\n");

    # Remove tidyallrc links
    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @TidyAllrcFiles = grep { /\.tidyallrc$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $File (@TidyAllrcFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            unlink $FilePath;
        }
    }

    # Remove PM links
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @PmFiles = grep { /\.pm$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $File (@PmFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            unlink $FilePath;
        }
    }

    # Remove plugin directory links
    my $PluginDir = File::Spec->catdir( $KernelTidyAllDir, 'Plugin', $ExtensionName );
    if ( -l $PluginDir ) {
        unlink $PluginDir;
    }

    # Remove doc directory link
    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc', $ExtensionName );
    if ( -l $DocDir ) {
        unlink $DocDir;
    }

    Print( 'green', "  ✓ Cleanup completed\n" );
    Print("\n");
    return;
}

# Function to cleanup all old extension links (for --all)
sub CleanupAllOldLinks {

    Print( 'step', "1. Cleaning Up All Old Extension Links..." );
    Print("\n");

    my $KernelTidyAllDir = File::Spec->catdir( $TargetRepoRoot, 'Kernel', 'TidyAll' );

    # Remove all tidyallrc links
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @TidyAllrcFiles = grep { /\.tidyallrc$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $File (@TidyAllrcFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            unlink $FilePath;
        }
    }

    # Remove all PM links
    if ( -d $KernelTidyAllDir ) {
        opendir( my $DH, $KernelTidyAllDir ) || warn "Cannot open $KernelTidyAllDir: $!";
        my @PmFiles = grep { /\.pm$/ && -l File::Spec->catfile( $KernelTidyAllDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $File (@PmFiles) {
            my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $File );
            unlink $FilePath;
        }
    }

    # Remove all plugin directory links
    my $PluginDir = File::Spec->catdir( $KernelTidyAllDir, 'Plugin' );
    if ( -d $PluginDir ) {
        opendir( my $DH, $PluginDir ) || warn "Cannot open $PluginDir: $!";
        my @PluginSubDirs = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $PluginDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $SubDir (@PluginSubDirs) {
            my $SubDirPath = File::Spec->catdir( $PluginDir, $SubDir );
            unlink $SubDirPath if -l $SubDirPath;
        }
    }

    # Remove all test directory links
    my $TestDir = File::Spec->catdir( $TargetRepoRoot, 'scripts', 'test' );
    if ( -d $TestDir ) {
        opendir( my $DH, $TestDir ) || warn "Cannot open $TestDir: $!";
        my @TestItems = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $TestDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $Item (@TestItems) {
            my $ItemPath = File::Spec->catdir( $TestDir, $Item );
            unlink $ItemPath if -l $ItemPath;
        }
    }

    # Remove all doc directory links
    my $DocDir = File::Spec->catdir( $TargetRepoRoot, 'doc' );
    if ( -d $DocDir ) {
        opendir( my $DH, $DocDir ) || warn "Cannot open $DocDir: $!";
        my @DocItems = grep { $_ ne '.' && $_ ne '..' && -l File::Spec->catdir( $DocDir, $_ ) } readdir($DH);
        closedir($DH);

        for my $Item (@DocItems) {
            my $ItemPath = File::Spec->catdir( $DocDir, $Item );
            unlink $ItemPath if -l $ItemPath;
        }
    }

    Print( 'green', "  ✓ All old extension links cleaned up\n" );
    return;
}

sub Print {
    my ( $Color, $Text ) = @_;

    my %ColorMap = (
        'success' => 'green',
        'info'    => 'white',
        'warning' => 'yellow',
        'error'   => 'red',
        'header'  => 'cyan',
        'step'    => 'blue',
    );

    if ( !defined $Text ) {
        $Text  = $Color;
        $Color = 'info';
    }

    my $ActualColor;
    if ( defined $Color && exists $ColorMap{$Color} ) {
        $ActualColor = $ColorMap{$Color};
    }
    elsif ( defined $Color ) {
        $ActualColor = $Color;    # Assume it's already a color name
    }
    else {
        $ActualColor = $ColorMap{info};    # Default to 'white' if no argument or undef
    }

    my $ColoredText = $ENV{ZNUNY_CODE_POLICY_NO_COLOR_OUTPUT} ? $Text : colored( $Text, $ActualColor );
    print $ColoredText;

    return;
}

# Function to update .gitignore after adding extension (append symbolic links)
sub AddGitignore {

    Print( 'step', "7. Adding symbolic links to .gitignore file..." );
    Print("\n");

    my $GitignoreFile = File::Spec->catfile( $TargetRepoRoot, '.gitignore' );

    # Get all symbolic links
    my $FindCommand = "cd '$TargetRepoRoot' && find . -type l | sed -e 's/^\.\\///g'";
    my @SymLinks    = `$FindCommand`;
    chomp @SymLinks;

    if ( $? != 0 ) {
        Print( 'warning', "  ⚠ Could not find symbolic links: $!\n" );
        return;
    }

    if ( !@SymLinks ) {
        Print( 'info', "  ℹ No symbolic links found\n" );
        return;
    }

    # Read existing .gitignore content
    my %ExistingPatterns;
    if ( -f $GitignoreFile ) {
        if ( open my $FH, '<', $GitignoreFile ) {    ## no critic
            LINE:
            while ( my $Line = <$FH> ) {
                chomp $Line;
                $Line =~ s/^\s+|\s+$//g;                           # Trim whitespace
                next LINE if !$Line || $Line =~ /^#/;              # Skip empty lines and comments
                $ExistingPatterns{$Line} = 1;
            }
            close $FH;
        }
    }

    # Collect new links that are not yet in .gitignore
    my @NewLinks;
    LINK:
    for my $Link (@SymLinks) {
        next LINK if exists $ExistingPatterns{$Link};
        push @NewLinks, $Link;
    }

    if ( !@NewLinks ) {
        Print( 'green', "  ✓ All symbolic links are already in .gitignore.\n" );
        return;
    }

    # Add new links to .gitignore
    if ( open my $FH, '>>', $GitignoreFile ) {    ## no critic
        for my $Link (@NewLinks) {
            print $FH "$Link\n";
            Print( 'green', "  ✓ Added: " );
            Print( 'info',  $Link . "\n" );
        }
        close $FH;

        my $Count = scalar @NewLinks;

        Print("\n");
        Print( 'green', "  ✓ Added $Count new symbolic links successfully\n" );
    }
    else {
        Print( 'warning', "  ⚠ Could not write to .gitignore: $!\n" );
    }

    return;
}

# Function to update .gitignore after removing extension (regenerate symbolic links section)
sub RemoveGitignore {

    Print( 'step', "6. Restoring .gitignore file from template..." );
    Print("\n");

    my $GitignoreFile = File::Spec->catfile( $TargetRepoRoot, '.gitignore' );
    my $TemplateFile  = File::Spec->catfile( $TargetRepoRoot, '.gitignore.template' );

    # Use template if available, otherwise keep existing content up to marker
    if ( -f $TemplateFile ) {

        # Copy template as base
        my $CopyCommand = "cd '$TargetRepoRoot' && cp .gitignore.template .gitignore";
        if ( system($CopyCommand) == 0 ) {
            Print( 'green', "  ✓ Restored successfully\n" );
        }
        else {
            Print( 'warning', "  ⚠ Could not copy template: $!\n" );
            return;
        }
    }
    else {
        Print( 'warning', "  ⚠ Could not find template: $!\n" );
        return;
    }
    return;
}

# Start the application
Run();
