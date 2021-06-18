# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Perl::BinScripts;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTRS::Perl);

# We only want to allow a handful of scripts in bin. All the rest should be
#   migrated to console commands.

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my %AllowedFiles = (
        'otrs.CheckModules.pl'   => 1,
        'otrs.CheckSum.pl'       => 1,
        'otrs.CodePolicy.pl'     => 1,
        'otrs.Console.pl'        => 1,
        'otrs.Daemon.pl'         => 1,
        'otrs.SetPermissions.pl' => 1,
    );

    if ( !$AllowedFiles{ File::Basename::basename($Filename) } ) {
        return $Self->DieWithError(<<"EOF");
Please migrate all bin/ scripts to Kernel::System::Console::Command objects.
EOF
    }
}

1;
