# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Znuny;

use strict;
use warnings;

use utf8;

use Code::TidyAll;

use parent qw(Code::TidyAll);

use File::Basename;
use File::Temp ();
use IO::File;
use IPC::System::Simple qw(capturex);
use POSIX ":sys_wait_h";
use Term::ANSIColor;
use File::Find;
use File::Spec;

=head2 new_from_conf_file()

    Initializes new TidyAll object.
    See Code::TidyAll::new_from_conf_file.

=cut

sub new_from_conf_file {
    my ( $Class, $ConfigFile, %Param ) = @_;

    my $CLIOptions = $Param{CLIOptions} // {};

    # because SUPER::new_from_conf_file would complain about unknown parameters
    delete $Param{CLIOptions};

    my $Self = $Class->SUPER::new_from_conf_file(
        $ConfigFile,
        %Param,
        no_cache   => 1,
        no_backups => 1,

        # Disable standard output
        msg_outputter => sub {
#             printf @_;
#             print "\n";
       },
    );

    $Self->_InitSettings(
        Mode       => $Param{mode},
        CLIOptions => $CLIOptions,
    );

    $TidyAll::Znuny::Object = $Self;

    # This contains the results, warnings and error messages of the code policy
    # plugins for each file (by path given in SOPM file list). Structure:
    #
    # {
    #     'Kernel/System/CSV.pm' => [
    #         TidyAllResultObject => $TidyAllResultObject, # Code::TidyAll::Result, returned from process_paths()
    #         Messages => [
    #             'Do not use print......',
    #             'Do not ....',
    #         ],
    #         ErrorMessages => [
    #             'This is not allowed...',
    #             'This is not allowed too...',
    #         ],
    #     ],
    # }
    $Self->{ResultsBySOPMFilePath} = {};

    return $Self;
}

=head2 SetSettings()

    Adds values from given hash to settings
    so that they can be easily retrieved later in plugin code without the need to
    mess around with separate variables for each setting.

    $TidyAllObject->SetSettings(
        ProductName => 'Znuny',
        Vendor      => 'Znuny GmbH',
    );

=cut

sub SetSettings {
    my ( $Self, %Param ) = @_;

    for my $Key ( keys %Param ) {
        $Self->{Settings}->{$Key} = $Param{$Key};
    }

    return 1;
}

=head2 GetSetting()

    Retrieves the value of a single setting with the given key.

    my $Value = $TidyAllObject->GetSetting('Framework::Version');

    Returns the stored value or undef if the key does not exist.

=cut

sub GetSetting {
    my ( $Self, $Key ) = @_;

    return if !exists $Self->{Settings}->{$Key};

    return $Self->{Settings}->{$Key};
}

=head2 GetSettings()

    Retrieves all stored settings.

    my $Settings = $TidyAllObject->GetSettings();

    Returns the stored values (can be empty hash).

=cut

sub GetSettings {
    my ( $Self, $Key ) = @_;

    return $Self->{Settings};
}

=head2 _DeleteSetting()

    Deletes the setting with the given key.

    $TidyAllObject->_DeleteSetting('Context::OPM');

=cut

sub _DeleteSetting {
    my ( $Self, $Key ) = @_;

    return 1 if !exists $Self->{Settings}->{$Key};

    delete $Self->{Settings}->{$Key};

    return 1;
}

=head2 _InitSettings()

    Initializes basic settings.
    Deletes all previous settings.

    $TidyAllObject->_InitSettings(
        Mode       => 'CLI', # or commit, etc.
        CLIOptions => {
            # options from command line
        },
    );

=cut

sub _InitSettings {
    my ( $Self, %Param ) = @_;

    $Self->{Settings} = {};

    # In Git context, the expected file structure for further
    # initialization is not present, so skip.
    # This is the case e.g. for the Git hooks.
    my $Mode = $Param{Mode} // '';
    $Self->SetSettings(
        Mode => $Mode,
    );
    return 1 if $Mode eq 'commit';

    # First check if in Framework/Znuny context.
    my $ReleaseFileInformation = $Self->_GetInformationFromZnunyReleaseFile();
    if ( ref $ReleaseFileInformation eq 'HASH') {
        $Self->SetSettings(
            'Context::Framework' => 1,
        );

        $Self->SetSettings( %{$ReleaseFileInformation} );
    }

    # Check for OPM context.
    else {
        my $SOPMFileInformation = $Self->_GetInformationFromSOPMFile();
        if ( ref $SOPMFileInformation eq 'HASH' ) {
            $Self->SetSettings(
                %{$SOPMFileInformation},
                'Context::OPM' => 1,
            );
        }
    }

    # Third party flag
    my $Vendor              = $Self->GetSetting('Vendor') // '';
    my $IsThirdPartyProduct = $Vendor eq 'Znuny GmbH' ? 0 : 1;
    $Self->SetSettings(
        IsThirdPartyProduct => $IsThirdPartyProduct,
    );

    my $FilePathsToCheck = $Self->_AssembleFilePathsToCheck(
        %{ $Param{CLIOptions} },
        AddSOPMFile => $Self->GetSetting('Context::OPM') ? 1 : 0,
    );

    $Self->SetSettings(
        'FilePaths::Check' => $FilePathsToCheck // [],
    );

    if ( $Self->GetSetting('Context::OPM') ) {
        my $AllFilePathsOfOPMDirectory = $Self->_FindFilesInDirectory( $Self->{root_dir} );
        $Self->SetSettings(
            'FilePaths::Directory' => $AllFilePathsOfOPMDirectory,
        );
    }

    # Misc. settings
    $Self->SetSettings(
        'TidyAll::RootDir' => $Self->{root_dir},
        'TidyAll::DataDir' => $Self->{data_dir},
    );

    return 1;
}

=head2 HasValidContext()

    Checks if code policy could determine a context (Framework or OPM).

    my $HasValidContext = $TidyAllObject->HasValidContext();

    Returns true value if a context has been set.

=cut

sub HasValidContext {
    my ( $Self, %Param ) = @_;

    return $Self->GetSetting('Context::Framework') || $Self->GetSetting('Context::OPM');
}

=head2 _GetInformationFromZnunyReleaseFile()

    Retrieves information from RELEASE file within the root directory of the Znuny installation
    from which the code policy is being executed.

    my $Information = $TidyAllObject->_GetInformationFromZnunyReleaseFile(
        FilePath => '../RELEASE', # optional, will be determined automatically by default

        # OR

        FileContent => '... content of file ...',
    );

    Returns:

    my $Information = {
        'Framework::Version' => '6.4',
        ProductName          => 'Znuny',
        Vendor               => 'Znuny GmbH',
    };

    Or undef if RELEASE file not found or does not contain expected data.

=cut

sub _GetInformationFromZnunyReleaseFile {
    my ( $Self, %Param ) = @_;

    my $Content = $Param{FileContent};
    if ( !defined $Content ) {
        my $FilePath = $Param{FilePath};
        if ( !defined $FilePath ) {
            $FilePath = File::Spec->catfile( $Self->{root_dir}, '/RELEASE' );
            return if !-r $FilePath;
        }

        my $FileHandle = IO::File->new( $FilePath, 'r' );
        my @Content    = $FileHandle->getlines();
        return if !@Content;

        $Content = join "\n", @Content;
    }

    #
    # Product name
    #
    return if $Content !~ m{^PRODUCT\s*=\s*(Znuny.*)$}m;
    my $ProductName = $1;

    #
    # Version
    #
    return if $Content !~ m{^VERSION\s*=\s*(\d+\.\d+)\.(?:x|\d+)}m;
    my $FrameworkVersion = $1;
    my $FrameworkVersionSupported = $Self->IsFrameworkVersionSupported($FrameworkVersion);
    return if !$FrameworkVersionSupported;

    my %Information = (
        'Framework::Version' => $FrameworkVersion,
        ProductName          => $ProductName,
        Vendor               => 'Znuny GmbH',
    );

    return \%Information;
}

=head2 _GetSOPMFilename()

    Returns name of the SOPM file, if present.

    Only a single SOPM file is allowed to be present.
    Also no RELEASE file is allowed to be present (would indicate framework context).
    Otherwise, no filename will be returned.

    my $SOPMFilename = $TidyAllObject->_GetSOPMFilename();

    Returns:
    my $SOPMFilename = 'MyPackage.sopm';

=cut

sub _GetSOPMFilename {
    my ( $Self, %Param ) = @_;

    my $ReleaseFilePath = $Self->{root_dir} . '/RELEASE';
    return if -f $ReleaseFilePath;

    my @SOPMFilePaths = glob $Self->{root_dir} . "/*.sopm";
    return if @SOPMFilePaths != 1;
    my $SOPMFilePath = $SOPMFilePaths[0];

    my $SOPMFilename = File::Spec->abs2rel(
        $SOPMFilePath,
        $Self->{root_dir},
    );

    return $SOPMFilename;
}


=head2 _GetInformationFromSOPMFile()

    Retrieves information from an SOPM file within the root directory.
    Only one SOPM file (an no RELEASE file) is allowed to be present.

    my $Information = $TidyAllObject->_GetInformationFromSOPMFile(
        FilePath => '../Znuny-Test.sopm', # optional, will be determined automatically by default

        # OR

        FileContent => '... content of file ...',
    );

    Returns:

    my $Information = {
        ProductName => 'Znuny-DatabaseBackend',
        Vendor      => 'Znuny GmbH',
    };

    Or undef if SOPM file not found or does not contain expected data.

=cut

sub _GetInformationFromSOPMFile {
    my ( $Self, %Param ) = @_;

    my $Content = $Param{FileContent};
    if ( !defined $Content ) {
        my $FilePath = $Param{FilePath};
        if ( !defined $FilePath ) {
            $FilePath = $Self->_GetSOPMFilename();
            return if !$FilePath;
        }

        my $FileHandle = IO::File->new( $FilePath, 'r' );
        my @Content    = $FileHandle->getlines();
        return if !@Content;

        $Content = join "\n", @Content;
    }

    # Framework version
    my %Information = (
        'SOPM::HasSupportedFrameworkVersion' => 0,
        ProductName                          => '',
        Vendor                               => '',
    );

    #
    # Check supported framework version
    #
    my $SupportedFrameworkVersion = $Self->GetSetting('Framework::Version');

    FRAMEWORKVERSION:
    while ( $Content =~ m{<Framework.*?>(\d+\.\d+)\.(?:x|\d+)</Framework>}mg ) {
        my $FrameworkVersion          = $1;
        my $FrameworkVersionSupported = $Self->IsFrameworkVersionSupported($FrameworkVersion);
        next FRAMEWORKVERSION if !$FrameworkVersionSupported;

        $Information{'SOPM::HasSupportedFrameworkVersion'} = 1;
        last FRAMEWORKVERSION;
    }

    # Product name
    if ( $Content =~ m{<Name>(.*?)</Name>}m ) {
        $Information{ProductName} = $1;
    }

    # Vendor
    if ( $Content =~ m{<Vendor>(.*?)</Vendor>}m ) {
        $Information{Vendor} = $1;
    }

    # Files
    my @FilePaths = sort ( $Content =~ m{<File .*?Location="(.*?)"}mg );
    $Information{'FilePaths::SOPM'} = \@FilePaths;

    return \%Information;
}

=head2 _AssembleFilePathsToCheck()

    Assembles file paths (relative to root dir) to handle by code policy according to given options.

    my $FilePaths = $TidyAllObject->_AssembleFilePathsToCheck(
        FilePath => 'Kernel/System.CSV.pm', # relative to root dir

        # OR
        Directory => 'Kernel/System', # relative to root dir

        # OR one of the following options
        # If no options are given, all staged and unstaged file paths will be fetched.
        StagedFiles => 1,
        AllFiles    => 1,

        # Will add the SOPM file if in OPM context if it's not part of the assembled file paths.
        # This is needed for some plugins that always check the SOPM file, regardless which
        # files were found to check.
        AddSOPMFile => 1,
    );

    Returns array with relative file paths, e.g.:
    my $FilePaths = [
        'Kernel/System/MyPackage.pm',
        'MyPackage.sopm',
        # ...
    ];

=cut

sub _AssembleFilePathsToCheck {
    my ( $Self, %Param ) = @_;

    my @FilePaths;

    # If in test mode, don't try to determine the file list to check
    # because there is no file/OPM context.
    my $Mode = $Self->GetSetting('Mode') // '';

    return \@FilePaths if $Mode eq 'tests';

    # Single file path
    if (
        defined $Param{FilePath}
        && length $Param{FilePath}
    ) {
        push @FilePaths, $Param{FilePath};
    }

    # Directory
    elsif (
        defined $Param{Directory}
        && length $Param{Directory}
    ) {
        my $FilePathsOfDirectory = $Self->_FindFilesInDirectory(
            File::Spec->catfile( $Self->{root_dir}, $Param{Directory} )
        );

        push @FilePaths, @{$FilePathsOfDirectory};
    }

    # All files
    elsif ( $Param{AllFiles} ) {
        my $FilePathsOfDirectory = $Self->_FindFilesInDirectory( $Self->{root_dir} );

        push @FilePaths, @{$FilePathsOfDirectory};
    }

    # Only staged files
    elsif ( $Param{StagedFiles} ) {
        my @StagedFilePaths = `git diff --name-only --cached`;
        for my $StagedFilePath (@StagedFilePaths) {
            chomp $StagedFilePath;
            push @FilePaths, $StagedFilePath;
        }
    }

    # Default: staged and unstaged files
    else {
        my $GitStatusOutput = capturex( 'git', "status", "--porcelain" );

        # Modified or added files
        push @FilePaths, ( $GitStatusOutput =~ m{^\s*[MA]+\s+(.*)}gm );

        # Moved files
        push @FilePaths, ( $GitStatusOutput =~ m{^\s*RM?+\s+.*?\s+->\s+(.*)}gm );
    }

#     # Only keep files for which at least one plugin is configured.
#     @FilePaths = grep { $Self->plugins_for_path($_) } @FilePaths;

    # Remove file paths that do not exist, are not readable, are symlinks, etc.
    @FilePaths = grep { -r $_ && !-l $_ } @FilePaths;

    # Add SOPM file (but only if there is at least one file which would be checked and yes
    # this could also be the changed SOPM file itself).
    # This is needed e.g. for checking if a newly added file has also been put into the SOPM's file list.
    if ( $Param{AddSOPMFile} && @FilePaths ) {
        my %FilePaths    = map { $_ => 1 } @FilePaths;
        my $SOPMFilename = $Self->_GetSOPMFilename();
        push @FilePaths, $SOPMFilename if $SOPMFilename && !$FilePaths{$SOPMFilename};
    }

    return \@FilePaths;
}

=head2

    Returns list of relative file paths in given directory (and its sub directories).

    my $FilePaths = $TidyAllObject->_FindFilesInDirectory('Kernel/System');

    Returns:

    my $FilePaths = [
        'Kernel/System/CSV.pm',
        'Kernel/System/Ticket.pm',
        # ...
    ];

=cut

sub _FindFilesInDirectory {
    my ( $Self, $Directory ) = @_;

    my @FilePaths;

    my $FilePathFilter = sub {

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
        return if $File::Find::name =~ m{/var/tmp/} && $File::Find::name !~ m{.*\.sample\z};
        return if $File::Find::name =~ m{/var/public/dist/};

        push @FilePaths, File::Spec->abs2rel(
            $File::Find::name,
            $Self->{root_dir},
        );
    };

    File::Find::find(
        $FilePathFilter,
        $Directory,
    );

    return \@FilePaths;
}

=head2 AddFileCheckResult

    Adds a TidyAll result object, a message or an error message for the given file path.
    This function can be executed multiple times for the same file so that multiple messages
    can be added, etc.

    $TidyAllObject->AddFileCheckResult(
        FilePath => 'Kernel/System/CSV.pm',

        # and one (or more) of the following options
        TidyAllResultObject => $TidyAllResultObject, # Code::TidyAll::Result
        Message             => 'Do not use...',
        ErrorMessage        => 'Do not use...',
    );

=cut

sub AddFileCheckResult {
    my ( $Self, %Param ) = @_;

    my $FilePath = $Param{FilePath};
    return if !defined $FilePath || !length $FilePath;

    $FilePath = $Self->GetSOPMFilePathFromTidyAllFilePath($FilePath);

    if ( !exists $Self->{ResultsBySOPMFilePath}->{$FilePath} ) {
        $Self->{ResultsBySOPMFilePath}->{$FilePath} = {
            TidyAllResultObject => undef,
            Messages            => [],
            ErrorMessages       => [],
        };
    }

    if ( $Param{TidyAllResultObject} ) {
        $Self->{ResultsBySOPMFilePath}->{$FilePath}->{TidyAllResultObject} = $Param{TidyAllResultObject};
    }

    if ( $Param{Message} ) {
        push @{ $Self->{ResultsBySOPMFilePath}->{$FilePath}->{Messages} },
            $Param{Message};
    }

    if ( $Param{ErrorMessage} ) {
        push @{ $Self->{ResultsBySOPMFilePath}->{$FilePath}->{ErrorMessages} },
            $Param{ErrorMessage};
    }

    return 1;
}

=head2 GetFileCheckResults

    Returns hash with file check results, if any.

    my $FileCheckResults = $TidyAllObject->GetFileCheckResults();

    Returns:

    my $FileCheckResults = {
        'Kernel/System/Console/Command/Znuny.pm' => {
            Messages => [
                'TidyAll::Plugin::Znuny::CodeStyle::ConsolePrintCheck
                Use $Self->Print("Hello World\\n") in console commands instead of "print".
                If writing to a file, consider using Kernel::System::Main::FileWrite().
                        Line 1: print "ConsolePrintCheck \\n";'
            ],
            ErrorMessages => [],
            TidyAllResultObject => undef,
        },
    };

=cut

sub GetFileCheckResults {
    my ( $Self, %Param ) = @_;

    return $Self->{ResultsBySOPMFilePath} // {};
}

=head2 GetSOPMFilePathFromTidyAllFilePath()

    Turns a temp. TidyAll file path to an SOPM file path.
    E.g. '/tmp/TidyAll---/Kernel/System/CSV.pm' becomes 'Kernel/System/CSV.pm'.
    If no TidyAll part is found, the path will be returned unchanged.

    my $SOPMFilePath = $TidyAllObject->GetSOPMFilePathFromTidyAllFilePath(
        '/tmp/TidyAll---/Kernel/System/CSV.pm'
    );

    Returns e.g. 'Kernel/System/CSV.pm'

=cut

sub GetSOPMFilePathFromTidyAllFilePath {
    my ( $Self, $TidyAllFilePath ) = @_;

    my $SOPMFilePath = $TidyAllFilePath;

    # Remove temp path part of TidyAll
    $SOPMFilePath =~ s{\A.+\/Code-TidyAll-[^\/]+\/}{};

    return $SOPMFilePath;
}

=head2 ProcessFilePathsParallel()

    Executes TidyAll plugins for given file paths in parallel with multiple processes.

    my $Result = $TidyAllObject->ProcessFilePathsParallel(
        ProcessLimit     => 5,  # optional, defaults to setting of env var ZNUNY_CODE_POLICY_PROCESS_LIMIT or 6
        FilePathsToCheck => [], # array with relative file paths to check
    );

    Returns array ref with results.

=cut

sub ProcessFilePathsParallel {
    my ( $Self, %Param ) = @_;

    my $ProcessLimit     = $Param{ProcessLimit} // $ENV{ZNUNY_CODE_POLICY_PROCESS_LIMIT} // 6;
    my @FilePathsToCheck = @{ $Param{FilePathsToCheck} // [] };

    # No parallel processing needed: execute directly.
    if ( $ProcessLimit <= 1 ) {
        print "Using only 1 process.\n\n";

        my @Results = $Self->process_paths(@FilePathsToCheck);

        for my $Result (@Results) {
            $Self->AddFileCheckResult(
                FilePath            => $Result->path(),
                TidyAllResultObject => $Result,
            );
        }

        return $Self->GetFileCheckResults();
    }

    # Parallel processing: Chunk the data and execute the chunks in parallel.
    #
    # TidyAll's built-in --jobs flag is not used, it seems to be way too slow,
    #   perhaps because of forking for each single job.
    my %ActiveChildPID;

    my $Stop = sub {

        # Propagate kill signal to all forks
        for my $PID ( sort keys %ActiveChildPID ) {
            kill 9, $PID;
        }

        print "Stopped by user\n";
        return 1;
    };

    local $SIG{INT}  = sub { $Stop->() };
    local $SIG{TERM} = sub { $Stop->() };

    print "Using up to $ProcessLimit parallel processes.\n\n";

    # To store results from child processes.
    my $TempDirectory = File::Temp->newdir() || die "Could not create temporary directory: $!";

    # split chunks of files for every process
    my @Chunks;
    my $ChunkCount = 0;

    for my $FilePath (@FilePathsToCheck) {
        my $ChunkIndex = $ChunkCount % $ProcessLimit;
        push @{ $Chunks[$ChunkIndex] }, $FilePath;

        $ChunkCount++;
    }

    CHUNK:
    for my $Chunk (@Chunks) {

        # Create a child process.
        my $PID = fork;
        if ( $PID < 0 ) {
            die "Unable to fork child process";
        }

        # Child process.
        if ( !$PID ) {
            my @Results = $Self->process_paths( @{$Chunk} );

            for my $Result (@Results) {
                $Self->AddFileCheckResult(
                    FilePath            => $Result->path(),
                    TidyAllResultObject => $Result,
                );
            }

            my $ChildPID = $$;
            Storable::store( $Self->GetFileCheckResults(), "$TempDirectory/$ChildPID.tmp" );

            # Close child process at the end.
            exit 0;
        }

        # Parent process.
        $ActiveChildPID{$PID} = {
            PID => $PID,
        };
    }

    my %ResultsBySOPMFilePath;

    # Check the status of all child processes every 0.1 seconds.
    # Wait for all child processes to be finished.
    while (%ActiveChildPID) {
        sleep 0.1;

        PID:
        for my $PID ( sort keys %ActiveChildPID ) {
            my $WaitResult = waitpid( $PID, WNOHANG );
            next PID if !$WaitResult;

            die "Child process '$PID' exited with errors: $?" if $WaitResult == -1;

            my $TempFile = "$TempDirectory/$PID.tmp";
            if ( !-r $TempFile ) {
                die "Could not read results of process $PID from file $TempFile";
            }

            my $ResultsBySOPMFilePath = Storable::retrieve($TempFile);
            unlink $TempFile;

            # Join the child results.
            %ResultsBySOPMFilePath = (
                %ResultsBySOPMFilePath,
                %{ $ResultsBySOPMFilePath // {} },
            );

            delete $ActiveChildPID{$PID};
        }
    }

    return \%ResultsBySOPMFilePath;
}

=head2 ProcessFileContentsParallel()

    Executes TidyAll plugins for given file paths in parallel with multiple processes.

    my $Result = $TidyAllObject->ProcessFileContentsParallel(
        ProcessLimit        => 5,  # optional, defaults to setting of env var ZNUNY_CODE_POLICY_PROCESS_LIMIT or 6
        FileContentsToCheck => { # hash with relative file paths and their content to check
            'Kernel/System/CSV.pm' => 'content of file...',
            # ...
        },
    );

    Returns array ref with results.

=cut

sub ProcessFileContentsParallel {
    my ( $Self, %Param ) = @_;

    my $ProcessLimit        = $Param{ProcessLimit} // $ENV{ZNUNY_CODE_POLICY_PROCESS_LIMIT} // 6;
    my %FileContentsToCheck = %{ $Param{FileContentsToCheck} // {} };

    # No parallel processing needed: execute directly.
    if ( $ProcessLimit <= 1 ) {
        print "Using only 1 process.\n\n";

        for my $FilePathToCheck ( sort keys %FileContentsToCheck ) {
            my $FileContentToCheck = $FileContentsToCheck{$FilePathToCheck};

            my $Result = $Self->process_source( $FileContentToCheck, $FilePathToCheck );

            $Self->AddFileCheckResult(
                FilePath            => $Result->path(),
                TidyAllResultObject => $Result,
            );
        }

        return $Self->GetFileCheckResults();
    }

    # Parallel processing: Chunk the data and execute the chunks in parallel.
    #
    # TidyAll's built-in --jobs flag is not used, it seems to be way too slow,
    #   perhaps because of forking for each single job.
    my %ActiveChildPID;

    my $Stop = sub {

        # Propagate kill signal to all forks
        for my $PID ( sort keys %ActiveChildPID ) {
            kill 9, $PID;
        }

        print "Stopped by user\n";
        return 1;
    };

    local $SIG{INT}  = sub { $Stop->() };
    local $SIG{TERM} = sub { $Stop->() };

    print "Using up to $ProcessLimit parallel processes.\n\n";

    # To store results from child processes.
    my $TempDirectory = File::Temp->newdir() || die "Could not create temporary directory: $!";

    # split chunks of files for every process
    my @Chunks;
    my $ChunkCount = 0;

    for my $FilePath ( sort keys %FileContentsToCheck ) {
        my $ChunkIndex = $ChunkCount % $ProcessLimit;
        push @{ $Chunks[$ChunkIndex] }, $FilePath;

        $ChunkCount++;
    }

    CHUNK:
    for my $Chunk (@Chunks) {

        # Create a child process.
        my $PID = fork;
        if ( $PID < 0 ) {
            die "Unable to fork child process";
        }

        # Child process.
        if ( !$PID ) {
            for my $FilePathToCheck ( @{$Chunk} ) {
                my $FileContentToCheck = $FileContentsToCheck{$FilePathToCheck};

                my $Result = $Self->process_source( $FileContentToCheck, $FilePathToCheck );

                $Self->AddFileCheckResult(
                    FilePath            => $Result->path(),
                    TidyAllResultObject => $Result,
                );
            }

            my $ChildPID = $$;
            Storable::store( $Self->GetFileCheckResults(), "$TempDirectory/$ChildPID.tmp" );

            # Close child process at the end.
            exit 0;
        }

        # Parent process.
        $ActiveChildPID{$PID} = {
            PID => $PID,
        };
    }

    my %ResultsBySOPMFilePath;

    # Check the status of all child processes every 0.1 seconds.
    # Wait for all child processes to be finished.
    while (%ActiveChildPID) {
        sleep 0.1;

        PID:
        for my $PID ( sort keys %ActiveChildPID ) {
            my $WaitResult = waitpid( $PID, WNOHANG );
            next PID if !$WaitResult;

            die "Child process '$PID' exited with errors: $?" if $WaitResult == -1;

            my $TempFile = "$TempDirectory/$PID.tmp";
            if ( !-r $TempFile ) {
                die "Could not read results of process $PID from file $TempFile";
            }

            my $ResultsBySOPMFilePath = Storable::retrieve($TempFile);
            unlink $TempFile;

            # Join the child results.
            %ResultsBySOPMFilePath = (
                %ResultsBySOPMFilePath,
                %{ $ResultsBySOPMFilePath // {} },
            );

            delete $ActiveChildPID{$PID};
        }
    }

    return \%ResultsBySOPMFilePath;
}

=head2 PrintResults()

    Prints results of TidyAll run.

    my $ExitCode = $TidyAllObject->PrintResults(
        [], # Array ref with results of call to ProcessFilePathsParallel().
    );

    Returns exit code 1 if there were errors.

=cut

sub PrintResults {
    my ( $Self, $TidyAllResults ) = @_;

    my %ResultsBySOPMFilePath = %{ $TidyAllResults // {} };

    my $ExitCode = 0;

    SOPMFILEPATH:
    for my $SOPMFilePath ( sort keys %ResultsBySOPMFilePath ) {
        my $Result = $ResultsBySOPMFilePath{$SOPMFilePath};

        my $TidyAllResultObject = $Result->{TidyAllResultObject};

        my %ValidTidyAllStates = (
            error   => 1,
            checked => 1,
            tidied  => 1,
        );

        my $TidyAllState = $TidyAllResultObject->state();
        next SOPMFILEPATH if !$ValidTidyAllStates{$TidyAllState};

        # Since 'die' is not used anymore for signalling code policy errors in plugins,
        # manually check for real errors.
        print "$SOPMFilePath\n";

        if ( $TidyAllState eq 'tidied' ) {
            print $Self->ReplaceColorTags("    <green>[File was tidied]</green>\n");
        }

        # TidyAll plugin runtime errors
        my $TidyAllError = $TidyAllResultObject->error();
        if ($TidyAllError) {
            print $Self->ReplaceColorTags("    <red>[Error]</red> ");
            print "$TidyAllError\n";
            $ExitCode = 1;
        }

        # TidyAll plugin content errors (these are already colored).
        for my $ErrorMessage ( @{ $Result->{ErrorMessages} // [] } ) {
            print $Self->ReplaceColorTags("    <red>[Error]</red> ");
            print $ErrorMessage;

            $ExitCode = 1;
        }

        # TidyAll plugin content messages (no errors) (these are already colored).
        for my $Message ( @{ $Result->{Messages} // [] } ) {
            print $Self->ReplaceColorTags("    <yellow>[Warning]</yellow> ");
            print $Message;
        }
    }

    return $ExitCode;
}

=head2 ReplaceColorTags()

    Replaces color tags in string with those provided by ColorString() function.

    my $String = $TidyAllObject->ReplaceColorTags('<red>Error message</red>');

=cut

sub ReplaceColorTags {
    my ( $Self, $String ) = @_;

    $String //= '';
    $String =~ s{<((bright_)?(green|yellow|red))>(.*?)</\1>}{$Self->ColorString($4, "$1")}gsme;

    return $String;
}

=head2 ColorString()

    Colors the given string (see Term::ANSIColor::color()) if ANSI output is available and active
    and environment variable ZNUNY_CODE_POLICY_NO_COLOR_OUTPUT is not set.

    Otherwise the text stays unchanged.

    my $ColoredText = $TidyAllObject->ColorString( $String, 'green' );

=cut

sub ColorString {
    my ( $Self, $String, $Color ) = @_;

    return $String if $ENV{ZNUNY_CODE_POLICY_NO_COLOR_OUTPUT};

    return Term::ANSIColor::color($Color) . $String . Term::ANSIColor::color('reset');
}

=head2 IsFrameworkVersionSupported()

    Checks if the given framework version is supported by this version of the code policy.

    my $VersionSupported = $TidyAllObject->IsFrameworkVersionSupported('6.4.2');
    my $VersionSupported = $TidyAllObject->IsFrameworkVersionSupported('6.4.x');
    my $VersionSupported = $TidyAllObject->IsFrameworkVersionSupported('6.4');


    Returns true value if version is supported.

=cut

sub IsFrameworkVersionSupported {
    my ( $Self, $Version ) = @_;

    return if !defined $Version;
    return if $Version !~ m{\A(\d+)\.(\d+)(?:\.(?:x|\d+))?\z};

    my $VersionMajor = $1;
    my $VersionMinor = $2;

    my $SupportedFrameworkVersions = $Self->GetSupportedFrameworkVersions();
    return $SupportedFrameworkVersions->{"$VersionMajor.$VersionMinor"};
}

=head2 GetSupportedFrameworkVersions()

    Returns framework version supported by this version of code policy.

    my $SupportedFrameworkVersions = $TidyAllObject->GetSupportedFrameworkVersions();

=cut

sub GetSupportedFrameworkVersions {
    my ( $Self ) = @_;

    my %SupportedFrameworkVersions = (
        '6.0' => 1,
        '6.1' => 1,
        '6.2' => 1,
        '6.3' => 1,
        '6.4' => 1,
        '6.5' => 1,
    );

    return \%SupportedFrameworkVersions;
}

1;
