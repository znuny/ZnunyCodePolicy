# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::OTRS::Common::Origin)

package TidyAll::Znuny::Git::PreReceive;

use strict;
use warnings;

=head1 SYNOPSIS

This pre-receive hook loads the Znuny version of Code::TidyAll
with the custom plugins, executes it for any modified files
and returns a corresponding status code.

=cut

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
    my ( $Self, %Param ) = @_;

    my $ErrorMessage;
    try {
        print "ZnunyCodePolicy pre-receive hook starting...\n";

        my $Input = $Param{Input};
        if ( !defined $Input ) {
            $Input = do { local $/ = undef; <> };
        }

        $ErrorMessage = $Self->HandleInput($Input);
    }
    catch {
        my $Exception = $_;
        print "*** Error running pre-receive hook (allowing push to proceed):\n$Exception";
        exit 1;
    };
    if ($ErrorMessage) {
        print "$ErrorMessage\n";
        print "*** Push was rejected. Please fix the errors and try again. ***\n";
        exit 1;
    }

    exit 0;
}

sub HandleInput {
    my ( $Self, $Input ) = @_;

    my @Lines = split( m/\n/, $Input );

    my (@Results);

    LINE:
    for my $Line (@Lines) {
        chomp($Line);
        my ( $Base, $Commit, $Ref ) = split( m/\s+/, $Line );

        next LINE if $Commit =~ m/^0+$/;

        if ( substr( $Ref, 0, 9 ) eq 'refs/tags' ) {

            # Only allow "rel-*" as name for new and updated tags.
            if ( $Ref !~ m{ \A refs/tags/rel-\d+_\d+_\d+ (_alpha\d+ | _beta\d+ | _rc\d+)? \z }xms ) {

                my $ErrorMessage
                    = "Error: found invalid tag '$Ref' - please only use rel-A_B_C or rel-A_B_C_(alpha|beta|rc)D.";
                return $ErrorMessage;
            }

            # Valid tag.
            next LINE;
        }

        print "Checking $Ref... ";

        my @FileList = $Self->GetGitFileList($Commit);

        # Create tidyall for each branch separately
        my $TidyAllObject = $Self->CreateTidyAll( $Commit, \@FileList );
        if ( !$TidyAllObject ) {
            return 'Error creating TidyAll object.';
        }

        my $TidyAllSettings = $TidyAllObject->GetSettings();

        if (
            !$TidyAllObject->HasValidContext()
            || !$TidyAllSettings->{'SOPM::HasSupportedFrameworkVersion'}
        ) {
            return 'Framework and/or OPM information could not be retrieved or OPM framework version is incompatible. Note that only the framework versions of the executed code policy are supported.';
        }

        print "\n\n================================================================================\n";
        print "Code policy context:         " . ( $TidyAllSettings->{'Context::Framework'} ? 'Framework' : 'OPM' )  . "\n";
        print "Vendor:                      $TidyAllSettings->{Vendor}\n";
        print "Product name:                $TidyAllSettings->{ProductName}\n";
        print "================================================================================\n";

        my @ChangedFiles = $Self->GetChangedFiles( $Base, $Commit );

        # Always include all SOPM files to verify the file list.
        for my $SOPMFile ( grep { $_ =~ m{\.sopm$} } @FileList ) {
            if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
                push @ChangedFiles, $SOPMFile;
            }
        }

        # Filter out files that were deleted. These won't be checked.
        my %FileList = map { $_ => 1 } @FileList;
        my @FilePathsToCheck = grep { $FileList{$_} } @ChangedFiles;
        next LINE if !@FilePathsToCheck;

        my %FileContentsToCheck;

        FILEPATH:
        for my $FilePath ( sort @FilePathsToCheck ) {

            # Get file from git repository, one by one only as the commits could be huge.
            my $Content = $Self->GetGitFileContents( $FilePath, $Commit );
            next FILEPATH if !defined $Content;

            $FileContentsToCheck{$FilePath} = $Content;
        }

        my $TidyAllResults = $TidyAllObject->ProcessFileContentsParallel(
            # Environment variable ZNUNY_CODE_POLICY_PROCESS_LIMIT will implicitly be used if set.
            # ProcessLimit        => 4,
            FileContentsToCheck => \%FileContentsToCheck,
        );

        my $ExitCode = $TidyAllObject->PrintResults($TidyAllResults);
        if ($ExitCode) {
            return 'Error: Some file(s) did not pass validation.';
        }
    }

    return;
}

sub CreateTidyAll {
    my ( $Self, $Commit, $FileList ) = @_;

    my $ConfigFile = dirname(__FILE__) . '/../../tidyallrc';

    my $TidyAllObject = TidyAll::Znuny->new_from_conf_file(
        $ConfigFile,
        check_only => 1,
        mode       => 'commit',
    );

    # Framework context
    if ( grep { $_ eq 'RELEASE' } @{$FileList} ) {
        my $Content = $Self->GetGitFileContents( 'RELEASE', $Commit );

        my $ReleaseFileInformation = $TidyAllObject->_GetInformationFromZnunyReleaseFile(
            FileContent => $Content,
        );

        if ( ref $ReleaseFileInformation eq 'HASH') {
            $TidyAllObject->SetSettings(
                'Context::Framework' => 1,
            );

            $TidyAllObject->SetSettings( %{$ReleaseFileInformation} );
        }
    }

    # Package context
    else {
        my @SOPMFilePaths = grep { $_ =~ m{\.sopm\z} } @{$FileList};
        if ( @SOPMFilePaths == 1 ) {
            my $SOPMFilePath = shift @SOPMFilePaths;
            my $Content      = $Self->GetGitFileContents( $SOPMFilePath, $Commit );

            my $SOPMFileInformation = $TidyAllObject->_GetInformationFromSOPMFile(
                FileContent => $Content,
            );

            if ( ref $SOPMFileInformation eq 'HASH' ) {
                $TidyAllObject->SetSettings(
                    %{$SOPMFileInformation},
                    'Context::OPM' => 1,
                );
            }
        }
    }

    # Third party flag
    my $Vendor              = $TidyAllObject->GetSetting('Vendor') // '';
    my $IsThirdPartyProduct = $Vendor eq 'Znuny GmbH' ? 0 : 1;
    $TidyAllObject->SetSettings(
        'IsThirdPartyProduct' => $IsThirdPartyProduct,
    );

    return $TidyAllObject;
}

sub GetGitFileContents {
    my ( $Self, $File, $Commit ) = @_;
    my $Content = capturex( "git", "show", "$Commit:$File" );
    return $Content;
}

sub GetGitFileList {
    my ( $Self, $Commit ) = @_;
    my $Output = capturex( "git", "ls-tree", "--name-only", "-r", "$Commit" );
    return split /\n/, $Output;
}

sub GetChangedFiles {
    my ( $Self, $Base, $Commit ) = @_;

    # Only use the last commit if we have a new branch.
    #   This is not perfect, but otherwise quite complicated.
    if ( $Base =~ m/^0+$/ ) {
        my $Output = capturex( 'git', 'diff-tree', '--no-commit-id', '--name-only', '-r', $Commit );
        my @Files  = grep {/\S/} split( m/\n/, $Output );
        return @Files;
    }

    my $Output = capturex( 'git', "diff", "--numstat", "--name-only", "$Base..$Commit" );
    my @Files  = grep {/\S/} split( m/\n/, $Output );
    return @Files;
}

1;
