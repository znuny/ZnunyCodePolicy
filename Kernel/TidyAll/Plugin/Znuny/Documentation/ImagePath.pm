# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Documentation::ImagePath;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for a correct image path (used in the documentation).

=cut

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );
    my $Code = $Self->GetFileContent($Filename);

    my $FilenameBasename = basename $Filename;
    my ( $Filenamename, $FilenameExtension ) = $FilenameBasename =~ /([\w_\-.]+\.(\w+?))$/;
    return if $FilenameExtension ne 'md';

    my $RootDir = $Self->GetSetting('TidyAll::RootDir');

    my $ImageLine   = '';
    my $LineCounter = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        my ($ImagePath) = $Line =~ m{\!\[.+\]\((.+)\)}xms;

        next LINE if !$ImagePath;
        next LINE if -e "$RootDir/$ImagePath";

        $ImageLine .= "\n\tCan't find file: '$RootDir/$ImagePath'\n\tLine $LineCounter: $Line";
    }

    my $ErrorMessage = '';
    if ( length $ImageLine ) {
        $ErrorMessage .= "Please pay attention to the correct image path:\n" . $ImageLine;
    }
    return if !length $ErrorMessage;

    $Self->AddErrorMessage($ErrorMessage);

    return;
}

1;
