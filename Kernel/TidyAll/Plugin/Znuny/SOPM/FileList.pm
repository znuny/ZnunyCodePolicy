# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SOPM::FileList;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

# This module verifies that:
#   - all packaged files of an SOPM are available
#   - the SOPM does not try to create new top-level files or directories in /opt/otrs
#   - all files in a valid top-level directory are also packaged (except for documentation)

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessageMissingFiles, $ErrorMessageUnpackagedFiles, $ErrorMessageForbiddenTopLevel );

    # Only validate files in subdirectories that are active for checking by
    #   default or actually appear on the list of packaged files.
    my %SupportedTopLevelDirectories = (
        bin      => 1,
        Custom   => 1,
        doc      => 1,
        Kernel   => 1,
        scripts  => 1,
        var      => 1,
    );

    #
    # Check top-level directory of files from SOPM file list.
    #
    my $SOPMFilePaths = $Self->GetSetting('FilePaths::SOPM') // [];

    FILEPATH:
    for my $FilePath ( @{$SOPMFilePaths} ) {

        # Disallow file paths starting with '/'.
        if ( $FilePath =~ m{\A/} ) {
            $ErrorMessageForbiddenTopLevel .= "    $FilePath\n";
            next FILEPATH;
        }

        # Reject unknown top-level directories.
        my ($TopLevelDirectory) = $FilePath =~ m{^(.+?)/};
        if ( !$TopLevelDirectory || !$SupportedTopLevelDirectories{$TopLevelDirectory} ) {
            $ErrorMessageForbiddenTopLevel .= "    $FilePath\n";
        }
    }

    #
    # Check which files of the SOPM file list are not available in the file system.
    #
    my $FilePathsOfDirectory = $Self->GetSetting('FilePaths::Directory') // [];

    FILEPATH:
    for my $FilePath ( @{$SOPMFilePaths} ) {
        if ( !grep { $_ eq $FilePath } @{$FilePathsOfDirectory} ) {
            $ErrorMessageMissingFiles .= "    $FilePath\n";
        }
    }

    #
    # Check which files in the file system are missing in the SOPM file list.
    # Only consider supported top-level directories.
    #
    FILEPATH:
    for my $FilePath ( @{$FilePathsOfDirectory} ) {
        my ($TopLevelDirectory) = $FilePath =~ m{^(.*?)/};
        next FILEPATH if !$TopLevelDirectory;
        next FILEPATH if !$SupportedTopLevelDirectories{$TopLevelDirectory};

        # Skip documentation files, these don't have to be on the SOPM list.
        next FILEPATH if $TopLevelDirectory eq 'doc';

        # Allow unpackaged hidden files.
        next FILEPATH if $FilePath =~ m{/\.};

        if ( !grep { $_ eq $FilePath } @{$SOPMFilePaths} ) {
            $ErrorMessageUnpackagedFiles .= "    $FilePath\n";
        }
    }

    my $ErrorMessage;

    if ($ErrorMessageForbiddenTopLevel) {
        $ErrorMessage .= <<"EOF";
The following SOPM file list entries try to create new top-level files or directories which is not allowed:
$ErrorMessageForbiddenTopLevel
EOF
    }

    if ($ErrorMessageMissingFiles) {
        $ErrorMessage .= <<"EOF";
The following files were listed in the SOPM but not found in the directory:
$ErrorMessageMissingFiles
EOF
    }

    if ($ErrorMessageUnpackagedFiles) {
        $ErrorMessage .= <<"EOF";
The following files were found in the directory but not listed in the SOPM:
$ErrorMessageUnpackagedFiles
EOF
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }
}

1;
