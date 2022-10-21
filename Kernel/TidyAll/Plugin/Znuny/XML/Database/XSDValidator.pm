# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::Database::XSDValidator;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {
    my ( $Self, $Filename ) = @_;
    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my $XSDFile = dirname(__FILE__) . '/../../XML/XSD/Database.xsd';
    my $CMD = "xmllint --noout --nonet --schema $XSDFile";

    my $Command = sprintf( "%s %s %s 2>&1", $CMD, $Self->argv(), $Filename );
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
