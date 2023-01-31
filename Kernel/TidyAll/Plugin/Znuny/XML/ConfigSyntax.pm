# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::ConfigSyntax;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # Check first XML line
        if ( $Counter == 1 ) {
            if (
                $Line    !~ /^<\?xml.+\?>/
                || $Line !~ /version=["'']1.[01]["']/
                || $Line !~ /encoding=["'](?:iso-8859-1|utf-8)["']/i
                )
            {
                $ErrorMessage
                    .= "First line of the file must read <?xml version=\"1.0\" encoding=\"utf-8\" ?>.\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }

        # Validate otrs_config tag
        if ( $Line =~ /^<otrs_config/ ) {
            my $Version = '2.0';

            if (
                $Line !~ /init="(Framework|Application|Config|Changes)"/
                || $Line !~ /version="$Version"/
                )
            {
                $ErrorMessage
                    .= "The <otrs_config> tag has missing or incorrect attributes. Example: <otrs_config version=\"2.0\" init=\"Application\">\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }
}

1;
