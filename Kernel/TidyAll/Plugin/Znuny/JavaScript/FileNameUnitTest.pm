# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::JavaScript::FileNameUnitTest;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my $Code       = $Self->GetFileContent($Filename);
    my $NameOfFile = substr( basename($Filename), 0, -3 );    # cut off .js

    my $Counter;

    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{^([^= ]+)\s*=\s*\(function\s*\(Namespace\)\s*\{ }xms ) {

            if ( $1 . ".UnitTest" ne $NameOfFile ) {
                $Self->AddErrorMessage(<<"EOF");
Filename ($NameOfFile.js) is not correct for the unit tests of JavaScript namespace ($1): Must be $1.UnitTest.js.
EOF
            }
        }
    }

    return;
}

1;
