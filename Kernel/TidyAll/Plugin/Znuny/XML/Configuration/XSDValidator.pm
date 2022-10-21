# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::Configuration::XSDValidator;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

use File::Basename;

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my $XSDFile   = dirname(__FILE__) . '/../XSD/Configuration.xsd';
    my $WantedDir = 'Kernel/Config/Files/XML';

    if ( $Filename !~ m{$WantedDir/[^/]+[.]xml$}smx ) {
        $Self->AddErrorMessage(
            "Configuration file $Filename does not exist in the correct directory $WantedDir.\n"
        );
    }

    my $Command = sprintf( "xmllint --noout --nonet --schema %s %s %s 2>&1", $XSDFile, $Self->argv(), $Filename );

    my $Output  = `$Command`;

    # If execution failed, warn about installing package.
    if ( ${^CHILD_ERROR_NATIVE} == -1 ) {
        $Self->AddErrorMessage("'xmllint' was not found, please install it.\n");
    }

    if ( ${^CHILD_ERROR_NATIVE} ) {
        $Self->AddErrorMessage($Output);
    }
}

1;
