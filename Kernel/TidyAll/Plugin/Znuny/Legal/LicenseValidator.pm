# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Legal::LicenseValidator;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    return $Code if $Self->IsOriginalOTRSCode($Code);

    # Remove "This software is part of the OTRS project".
    $Code =~ s{\n ^=head1 \s+ TERMS \s+ AND \s+ CONDITIONS .*? ^=cut\n?}{}smx;

    return $Code;
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Code = $Self->_GetFileContents($Filename);
    return $Code if !$Self->IsOriginalZnunyCode($Code);

    my $CorrectLicenseHeaderFound;

    # Search for first line of possible license header
    if ( $Code =~ m{^(# |// )?This software comes with ABSOLUTELY NO WARRANTY\. For details, see$}m ) {
        my $LinePrefix = $1;

        my $ExpectedLicenseText = $LinePrefix . "This software comes with ABSOLUTELY NO WARRANTY. For details, see\n"
            . $LinePrefix . "the enclosed file COPYING for license information (AGPL). If you\n"
            . $LinePrefix . "did not receive this file, see http://www.gnu.org/licenses/agpl.txt.\n";

        if ( $Code =~ m{^\Q$ExpectedLicenseText\E}m ) {
            $CorrectLicenseHeaderFound = 1;
        }
    }

    return if $CorrectLicenseHeaderFound;

    my $Message = "No valid license header found. Remove any license text and add the following text to the header:\n\n"
        . "This software comes with ABSOLUTELY NO WARRANTY. For details, see\n"
        . "the enclosed file COPYING for license information (AGPL). If you\n"
        . "did not receive this file, see http://www.gnu.org/licenses/agpl.txt.\n";

    my $FilePath = $Self->FilePath($Code) || $Filename->[0];
    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'error',
        Message  => $Message,
        FilePath => $FilePath,
    );

    return;
}

1;
