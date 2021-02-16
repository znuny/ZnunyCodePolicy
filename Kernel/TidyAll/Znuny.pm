# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2021 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Znuny;

use strict;
use warnings;

use Code::TidyAll 0.56;
use File::Basename;
use File::Temp ();
use IO::File;
use POSIX ":sys_wait_h";
use Term::ANSIColor();
use Time::HiRes qw(sleep);

use parent qw(Code::TidyAll);

# Require some needed modules here for clarity / better error messages.
use Perl::Critic;
use Perl::Tidy;

# ---
# ZnunyCodePolicy
# ---
use File::Spec;
use Cwd;
our $DataDir;
our $OTRSRootDir;
our $CPRootDir;
our $PackageName;
our $ProductName = 'Znuny';
# ---
our $FrameworkVersionMajor = 0;
our $FrameworkVersionMinor = 0;
our $ThirdpartyModule      = 0;
our @FileList              = ();    # all files in current repository
# ---

sub new_from_conf_file {
    my ( $Class, $ConfigFile, %Param ) = @_;

    my $Self = $Class->SUPER::new_from_conf_file(
        $ConfigFile,
        %Param,
        no_cache   => 1,
        no_backups => 1,
    );

    # Reset when a new object is created
    $FrameworkVersionMajor = 0;
    $FrameworkVersionMinor = 0;
    $ThirdpartyModule      = 0;
    @FileList              = ();

    return $Self;
}

sub DetermineFrameworkVersionFromDirectory {
    my ( $Self, %Param ) = @_;

    # First check if we have an OTRS directory, use RELEASE info then.
    if ( -r $Self->{root_dir} . '/RELEASE' ) {
        my $FileHandle = IO::File->new( $Self->{root_dir} . '/RELEASE', 'r' );
        my @Content    = $FileHandle->getlines();

        my ( $VersionMajor, $VersionMinor ) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $FrameworkVersionMajor = $VersionMajor;
        $FrameworkVersionMinor = $VersionMinor;
# ---
# ZnunyCodePolicy
# ---
        if ( $Content[0] =~ m{\APRODUCT\s*=\s*(.*)} ) {
            $ProductName = $1;
        }
# ---
    }
    else {
        # Now check if we have a module directory with an SOPM file in it.
        my @SOPMFiles = glob $Self->{root_dir} . "/*.sopm";
        if (@SOPMFiles) {

            # Use the highest framework version from the first SOPM file.
            my $FileHandle = IO::File->new( $SOPMFiles[0], 'r' );
            my @Content    = $FileHandle->getlines();
            for my $Line (@Content) {
                if ( $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > }xms ) {
                    my ( $VersionMajor, $VersionMinor )
                        = $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > (\d+) \. (\d+) \. [^<*]+ <\/Framework> }xms;
                    if (
                        $VersionMajor > $FrameworkVersionMajor
                        || (
                            $VersionMajor == $FrameworkVersionMajor
                            && $VersionMinor > $FrameworkVersionMinor
                        )
                        )
                    {
                        $FrameworkVersionMajor = $VersionMajor;
                        $FrameworkVersionMinor = $VersionMinor;
                    }
                }

# ---
# ZnunyCodePolicy
# ---
#                elsif ( $Line =~ m{<Vendor>} && $Line !~ m{OTRS} ) {
                elsif ( $Line =~ m{<Vendor>} && $Line !~ m{OTRS|Znuny} ) {

# ---
                    $ThirdpartyModule = 1;
                }
            }
        }
    }

    if ($FrameworkVersionMajor) {
        print "Found $ProductName version $FrameworkVersionMajor.$FrameworkVersionMinor.\n";
    }
    else {
        print "Could not determine $ProductName version (assuming latest version)!\n";
    }

    if ($ThirdpartyModule) {
        print
# ---
# ZnunyCodePolicy
# ---
#            "This seems to be a module not copyrighted by OTRS AG. File copyright will not be changed.\n";
            "This software seems to be not copyrighted by Znuny GmbH. File copyright will not be changed.\n";
# ---
    }
    else {
        print
# ---
# ZnunyCodePolicy
# ---
#            "This module seems to be copyrighted by OTRS AG. File copyright will automatically be assigned to OTRS AG.\n";
            "This software seems to be copyrighted by Znuny GmbH. File copyright will automatically be assigned to Znuny GmbH.\n";
# ---
        print
            "  If this is not correct, you can change the <Vendor> tag in your SOPM.\n";
    }

# ---
# ZnunyCodePolicy
# ---
# define global otrs variables
    $TidyAll::OTRS::FrameworkVersionMajor = $FrameworkVersionMajor;
    $TidyAll::OTRS::FrameworkVersionMinor = $FrameworkVersionMinor;
    $TidyAll::OTRS::ThirdpartyModule      = $ThirdpartyModule;
# ---
    return;
}

#
# Process a list of file paths in parallel with forking (if needed).
#
sub ProcessPathsParallel {
    my ( $Self, %Param ) = @_;

    my $Processes = $Param{Processes} // $ENV{OTRSCODEPOLICY_PROCESSES} // 6;
    my @Files     = @{ $Param{FilePaths} // [] };

    # No parallel processing needed: execute directly.
    if ( $Processes <= 1 ) {
        return $Self->process_paths(@Files);
    }

    # Parallel processing. We chunk the data and execute the chunks in parallel.
    #
    # TidyAll's built-in --jobs flag is not used, it seems to be way too slow,
    #   perhaps because of forking for each single job.

    my %ActiveChildPID;

    my $Stop = sub {

        # Propagate kill signal to all forks
        for my $PID ( sort keys %ActiveChildPID ) {
            kill 9, $PID;
        }

        print "Stopped by user!\n";
        return 1;
    };

    local $SIG{INT}  = sub { $Stop->() };
    local $SIG{TERM} = sub { $Stop->() };

    my @GlobalResults;

# ---
# ZnunyCodePolicy
# ---
#     print "OTRSCodePolicy will use up to $Processes parallel processes.\n";
    print "ZnunyCodePolicy will use up to $Processes parallel processes.\n";
# ---

    # To store results from child processes.
    my $TempDirectory = File::Temp->newdir() || die "Could not create temporary directory: $!";

    # split chunks of files for every process
    my @Chunks;
    my $ItemCount = 0;

    for my $File (@Files) {
        push @{ $Chunks[ $ItemCount++ % $Processes ] }, $File;
    }

    CHUNK:
    for my $Chunk (@Chunks) {

        # Create a child process.
        my $PID = fork;

        # Child process could not be created.
        if ( $PID < 0 ) {
            die "Unable to fork a child process for tiding!";
        }

        # Child process.
        if ( !$PID ) {

            my @Results = $Self->process_paths( @{$Chunk} );

            my $ChildPID = $$;
            Storable::store( \@Results, "$TempDirectory/$ChildPID.tmp" );

            # Close child process at the end.
            exit 0;
        }

        # Parent process.
        $ActiveChildPID{$PID} = {
            PID => $PID,
        };
    }

    # Check the status of all child processes every 0.1 seconds.
    # Wait for all child processes to be finished.
    WAIT:
    while (1) {

        last WAIT if !%ActiveChildPID;
        sleep 0.1;

        PID:
        for my $PID ( sort keys %ActiveChildPID ) {

            my $WaitResult = waitpid( $PID, WNOHANG );

            die "Child process '$PID' exited with errors: $?" if $WaitResult == -1;

            if ($WaitResult) {

                my $TempFile = "$TempDirectory/$PID.tmp";
                my $Results;

                if ( !-e $TempFile ) {
                    die "Could not read results of process $PID.\n";
                }

                $Results = Storable::retrieve($TempFile);
                unlink $TempFile;

                # Join the child results.
                @GlobalResults = ( @GlobalResults, @{ $Results || [] } );

                delete $ActiveChildPID{$PID};
            }
        }
    }

    return @GlobalResults;
}

#
# Print a useful summary and die in case of errors.
#
sub HandleResults {
    my ( $Self, %Param ) = @_;

    my @GlobalResults = @{ $Param{Results} // [] };

    my @ErrorResults = grep { $_->error() } @GlobalResults;
    if (@ErrorResults) {
        my $ErrorCount   = scalar(@ErrorResults);
        my $ErrorMessage = sprintf(
            _ReplaceColorTags("\n<red>Error: %d file(s) did not pass validation.</red>\n"),
            $ErrorCount,
        );
        if ( $ErrorCount < 10 ) {
            for my $Error (@ErrorResults) {
                $ErrorMessage .= " - " . $Error->path() . "\n";
            }
        }
        die "$ErrorMessage\n";
    }

    my @TidiedResults = grep { $_->state() eq 'tidied' } @GlobalResults;
    if (@TidiedResults) {
        printf(
            _ReplaceColorTags("\n<green>Validation finished,</green> <yellow>%d file(s) were tidied.</yellow>\n"),
            scalar(@TidiedResults),
        );

    }
    else {
        print _ReplaceColorTags("\n<green>Validation finished, no problems found.</green>\n");
    }

    return 1;
}

#
# Get a list (almost) all relative file paths from the root directory. This list is used in some plugins to make validation decisions,
#   not for the actual decision which files are to be validated.
#
sub GetFileListFromDirectory {
    my ( $Self, %Param ) = @_;

    # Only run once.
    return if @FileList;

    @FileList = $Self->FindFilesInDirectory( Directory => $Self->{root_dir} );
# ---
# ZnunyCodePolicy
# ---
# define global otrs variables
    @TidyAll::OTRS::FileList = @FileList;
# ---

    return;
}

#
# Get a list of all relative file paths in a directory with some global ignores for speed's sake.
#
sub FindFilesInDirectory {
    my ( $Self, %Param ) = @_;

    my $Directory = $Param{Directory};

    my @Files;

    my $Wanted = sub {

        # Skip non-regular files and directories.
        return if ( !-f $File::Find::name );

        # Also skip symbolic links, TidyAll does not like them.
        return if ( -l $File::Find::name );

        # Some global hard ignores that are meant to speed up the loading process,
        #   as applying the TidyAll ignore/select rules can be quite slow.
        return if $File::Find::name =~ m{/\.git/};
        return if $File::Find::name =~ m{/\.tidyall.d/};
        return if $File::Find::name =~ m{/\.vscode/};
        return if $File::Find::name =~ m{/node_modules/};
        return if $File::Find::name =~ m{/js-cache/};
        return if $File::Find::name =~ m{/css-cache/};
        return if $File::Find::name =~ m{/var/tmp/} && $File::Find::name !~ m{.*\.sample$};
        return if $File::Find::name =~ m{/var/public/dist/};

        push @Files, File::Spec->abs2rel( $File::Find::name, $Self->{root_dir} );
    };

    File::Find::find(
        $Wanted,
        $Directory,
    );

    return @Files;
}

#
# Filter relative file paths for only the files that are matched by at least one plugin.
#
sub FilterMatchedFiles {
    my ( $Self, %Param ) = @_;

    return grep { $Self->plugins_for_path($_) } @{ $Param{Files} };
}

sub _ReplaceColorTags {
    my ($Text) = @_;

    $Text //= '';

    $Text =~ s{<(green|yellow|red)>(.*?)</\1>}{_Color($1, $2)}gsmxe;

    return $Text;
}

=head2 _Color()

This will color the given text (see Term::ANSIColor::color()) if ANSI output is available and active, otherwise the text
stays unchanged.

    my $PossiblyColoredText = _Color('green', $Text);

=cut

sub _Color {
    my ( $Color, $Text ) = @_;

    return $Text if $ENV{OTRSCODEPOLICY_NOCOLOR};

    return Term::ANSIColor::color($Color) . $Text . Term::ANSIColor::color('reset');
}

# ---
# ZnunyCodePolicy
# ---
sub SetOTRSRootDir {
    my ( $Self, %Param ) = @_;

    $DataDir     = $Self->{data_dir};
    $OTRSRootDir = $Self->{root_dir};
}

sub SetCPRootDir {
    my ( $Self, $BinDir ) = @_;
    $CPRootDir = $BinDir;
    $CPRootDir =~ s{/bin}{};
}

sub SetPackageName {
    my ( $Self, %Param ) = @_;

    my @SOPMFilenames = grep { $_ =~ m{\A[^/]+\.sopm\z} } @TidyAll::OTRS::FileList;
    return if @SOPMFilenames != 1;

    my $SOPMFile = shift @SOPMFilenames;
    $SOPMFile    =~ s{\A(.*)\.sopm\z}{$1};
    $PackageName = $1;
}
# ---
1;
