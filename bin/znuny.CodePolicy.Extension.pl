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

use Cwd            qw(abs_path);
use File::Basename qw(dirname);
use File::Copy     qw(copy);
use File::Find;
use File::Path qw(make_path);
use File::Spec;
use FindBin qw($RealBin);
use Getopt::Long;
use Term::ANSIColor qw(colored);

use lib dirname($RealBin) . '/Kernel';
use TidyAll::Znuny::Extension;

# Ensure UTF-8 output works.
binmode( \*STDOUT, ':encoding(UTF-8)' );
binmode( \*STDERR, ':encoding(UTF-8)' );

# Global variables
my $TargetRepoRoot = dirname($RealBin);
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
sub ListAvailableExtensions {
    my $ExtensionsDir = File::Spec->catdir( $TargetRepoRoot, 'Extensions' );
    if ( !-d $ExtensionsDir ) {
        Print( 'warning', "No extension directory found.\n" );
        return;
    }

    return TidyAll::Znuny::Extension::Available( RepoRoot => $TargetRepoRoot );
}

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

sub RemoveCommand {
    my ( $ExtensionName, $ExtensionsDir ) = @_;

    if ( $Options{All} ) {
        RemoveAllExtensions();
    }
    else {
        my $Result = TidyAll::Znuny::Extension::Remove(
            RepoRoot => $TargetRepoRoot,
            Name     => $ExtensionName,
            Verbose  => $Options{Verbose},
        );
        PrintLog( $Result->{Log} );
    }

    RebuildGitignore();

    Print("\n");
    PrintRemovalSummary($ExtensionName);
    return;
}

sub StatusCommand {
    my $Status = TidyAll::Znuny::Extension::Status( RepoRoot => $TargetRepoRoot );

    Print( 'header', "=== Extension Links Status ===" );
    Print("\n\n");

    my $Index = 0;
    GROUP:
    for my $Group ( @{ $Status->{Groups} } ) {
        $Index++;
        Print( 'step', "$Index. $Group->{Title}" );
        Print("\n");

        if ( $Group->{DirectoryMissing} ) {
            Print( 'yellow', "  ℹ $Group->{DirectoryMissing}\n" );
        }

        my $Shown = 0;
        LINK:
        for my $Link ( @{ $Group->{Links} // [] } ) {
            $Shown = 1;
            if ( $Link->{Broken} ) {
                Print( 'red', "  ✗ $Link->{Label}" );
                Print( 'red', " -> $Link->{Target} (broken link)\n" );
                next LINK;
            }
            Print( 'green', "  ✓ $Link->{Label}" );
            Print( 'white', " -> $Link->{Target}\n" );
        }

        MISSING:
        for my $Missing ( @{ $Group->{Missing} // [] } ) {
            $Shown = 1;
            Print( 'red', "  ✗ $Missing->{Label} ($Missing->{Reason})\n" );
        }

        if ( !$Shown && !$Group->{DirectoryMissing} ) {
            Print( 'yellow', "  ℹ $Group->{Empty}\n" );
        }
        Print("\n");
    }

    if ( $Status->{Incomplete} ) {
        Print( 'warning', "=== Status: Extension links are missing ===\n" );
    }
    elsif ( $Status->{Active} ) {
        Print( 'success', "=== Status: Extensions are active ===\n" );
    }
    else {
        Print( 'success', "=== Status: No extension links found ===\n\n" );
        Print( 'info',    "Use 'add' command to activate extensions.\n" );
    }
    return;
}

sub AddSingleExtension {
    my ( $ExtensionName, $ExtensionDir ) = @_;

    my $Result = TidyAll::Znuny::Extension::Add(
        RepoRoot => $TargetRepoRoot,
        Name     => $ExtensionName,
        Verbose  => $Options{Verbose},
    );
    PrintLog( $Result->{Log} );
    RebuildGitignore();
    Print("\n");
    PrintAdditionSummary( $ExtensionName, $ExtensionDir );
    return;
}

sub AddAllExtensions {
    my ($ExtensionsDir) = @_;

    my @AvailableExtensions = ListAvailableExtensions();
    if ( !@AvailableExtensions ) {
        Print( 'warning', "No extensions found in Extensions/ directory.\n" );
        RebuildGitignore();
        exit 0;
    }

    Print( 'warning', "⚠ WARNING: Adding ALL available extensions!\n" );
    Print( 'warning', "This will add the following extensions:" );
    EXTENSION:
    for my $Extension (@AvailableExtensions) {
        Print("\n");
        Print( 'warning', "  - $Extension" );
    }
    Print("\n\n");
    Print( 'magenta', "Are you sure you want to continue? [Y/n]: " );

    my $Response = <ARGV>;
    if ($Response) {
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

    my $Cleared = TidyAll::Znuny::Extension::Clear(
        RepoRoot => $TargetRepoRoot,
        Scope    => 'all',
    );
    PrintLog( $Cleared->{Log} );
    Print("\n");

    EXTENSION:
    for my $Extension (@AvailableExtensions) {
        Print("\n");
        Print( 'header', "=== Adding Extension: $Extension ===" );
        Print("\n\n");
        my $Linked = TidyAll::Znuny::Extension::Link(
            RepoRoot => $TargetRepoRoot,
            Name     => $Extension,
            Verbose  => $Options{Verbose},
        );
        PrintLog( $Linked->{Log} );
    }

    RebuildGitignore();
    Print("\n");
    Print( 'header', "=== Addition Summary (All Extensions) ===" );
    Print("\n\n");
    Print("Added extensions:\n");
    EXTENSION:
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

sub RemoveAllExtensions {
    my @LinkedExtensions = TidyAll::Znuny::Extension::Linked( RepoRoot => $TargetRepoRoot );

    Print( 'warning', "⚠ WARNING: Removing ALL extension links!" );
    Print("\n");
    if (@LinkedExtensions) {
        Print( 'warning', "This will remove the following extensions:\n" );
        EXTENSION:
        for my $Extension (@LinkedExtensions) {
            Print( 'yellow', "  - $Extension\n" );
        }
        Print("\n");
    }
    else {
        Print( 'info', "No extension links found to remove.\n" );
        RebuildGitignore();
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
    my $Result = TidyAll::Znuny::Extension::Remove(
        RepoRoot => $TargetRepoRoot,
        All      => 1,
    );
    PrintLog( $Result->{Log} );
    return;
}

# Rebuild .gitignore from the template and the extension symlinks that exist now.
sub RebuildGitignore {

    Print( 'step', "Rebuilding .gitignore from template..." );
    Print("\n");

    my $GitignoreFile = File::Spec->catfile( $TargetRepoRoot, '.gitignore' );
    my $TemplateFile  = File::Spec->catfile( $TargetRepoRoot, '.gitignore.template' );

    if ( !-f $TemplateFile ) {
        Print( 'warning', "  ⚠ Template not found: $TemplateFile\n" );
        return;
    }

    if ( !copy( $TemplateFile, $GitignoreFile ) ) {
        Print( 'warning', "  ⚠ Could not copy template: $!\n" );
        return;
    }

    Print( 'green', "  ✓ Restored .gitignore from template\n" );

    my @SymLinks = _ExtensionSymlinks();
    if ( !@SymLinks ) {
        Print( 'info', "  ℹ No extension symbolic links found\n" );
        return;
    }

    if ( open my $FH, '>>', $GitignoreFile ) {    ## no critic
        LINK:
        for my $Link (@SymLinks) {
            print $FH "$Link\n";
            Print( 'green', "  ✓ Added: " );
            Print( 'info',  $Link . "\n" );
        }
        close $FH;

        my $Count = scalar @SymLinks;
        Print("\n");
        Print( 'green', "  ✓ Rebuilt .gitignore with $Count extension symbolic link(s)\n" );
    }
    else {
        Print( 'warning', "  ⚠ Could not write to .gitignore: $!\n" );
    }

    return;
}

# Relative paths of symlinks that point into Extensions/.
# Skips Extensions/, node_modules and .git so unrelated links stay out.
sub _ExtensionSymlinks {
    my @Links;

    File::Find::find(
        {
            wanted => sub {
                my $Path = $File::Find::name;

                if ( -d $Path && $Path =~ m{/(?:\.git|node_modules|Extensions)\z} ) {
                    $File::Find::prune = 1;
                    return;
                }

                return if !-l $Path;

                my $Target = readlink $Path;
                return if !defined $Target;
                return if $Target !~ m{(?:^|/)Extensions/};

                push @Links, File::Spec->abs2rel( $Path, $TargetRepoRoot );
                return;
            },
            no_chdir => 1,
        },
        $TargetRepoRoot,
    );

    my @Sorted = sort @Links;
    return @Sorted;
}

sub PrintAdditionSummary {
    my ( $ExtensionName, $ExtensionDir ) = @_;

    my $Summary = TidyAll::Znuny::Extension::LinkSummary(
        RepoRoot     => $TargetRepoRoot,
        Name         => $ExtensionName,
        ExtensionDir => $ExtensionDir,
    );

    Print( 'header', "=== Addition Summary ===" );
    Print("\n\n");
    Print( 'info', "Extension: $ExtensionName" );
    Print("\n");
    Print("Linked components:\n");
    _PrintCount( 'TidyAll configurations', $Summary->{Config} );
    _PrintCount( 'TidyAll PM files',       $Summary->{Module} );
    _PrintCount( 'Tests',                  $Summary->{Test} );
    _PrintCount( 'Plugins',                $Summary->{Plugin} );
    _PrintCount( 'Documentation',          $Summary->{Documentation} );

    Print("\n");
    Print( 'success', "=== Addition completed successfully! ===" );
    Print("\n\n");
    Print( 'info', "To test the extension:" );
    Print("\n");
    Print( 'magenta', "  perl bin/znuny.CodePolicy.pl --verbose --file-path README.md\n" );
    Print("\n");
    return;
}

sub PrintRemovalSummary {
    my ($ExtensionName) = @_;

    my $Remaining = TidyAll::Znuny::Extension::RemainingSummary( RepoRoot => $TargetRepoRoot );

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

    Print("Remaining extension links:\n");
    _PrintRemaining( 'TidyAll configurations', $Remaining->{Config} );
    _PrintRemaining( 'TidyAll PM files',       $Remaining->{Module} );
    _PrintRemaining( 'Plugins',                $Remaining->{Plugin} );
    _PrintRemaining( 'Tests',                  $Remaining->{Test} );
    _PrintRemaining( 'Documentation',          $Remaining->{Documentation} );

    Print( 'success', "\n=== Removal completed successfully! ===\n" );

    Print( 'info', "\nTo verify removal:" );
    Print( 'info', " perl bin/znuny.CodePolicy.pl --verbose --file-path README.md\n\n" );
    return;
}

sub PrintLog {
    my ($Log) = @_;

    ENTRY:
    for my $Entry ( @{ $Log // [] } ) {
        next ENTRY if !defined $Entry->{Text};
        if ( defined $Entry->{Color} && length $Entry->{Color} ) {
            Print( $Entry->{Color}, $Entry->{Text} );
        }
        else {
            Print( $Entry->{Text} );
        }
    }
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

sub _PrintCount {
    my ( $Label, $Count ) = @_;

    $Count //= 0;
    Print("- $Label: ");
    Print( $Count > 0 ? 'green' : 'white', $Count );
    Print(" files\n");
    return;
}

sub _PrintRemaining {
    my ( $Label, $Count ) = @_;

    $Count //= 0;
    Print("- $Label: ");
    Print( $Count == 0 ? 'green' : 'red', $Count );
    Print(" files\n");
    return;
}

# Start the application
Run();
