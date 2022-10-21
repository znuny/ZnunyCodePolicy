# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SOPM::Name;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );
    my $Code = $Self->GetFileContent($Filename);

    my $ProductName          = $Self->GetSetting('ProductName');
    my $ProuctNameOfFilename = substr( basename($Filename), 0, -5 );    # cut off .sopm

    if ( $ProductName ne $ProuctNameOfFilename ) {
        $Self->AddErrorMessage(
            "The product name $ProductName is not equal to the name of the SOPM file ($ProuctNameOfFilename)."
        );
    }
}

1;
