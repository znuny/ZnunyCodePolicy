# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::LintWithOurParsers;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Parser = XML::Parser->new();
    if ( !eval { $Parser->parse($Code) } ) {
        $Self->AddErrorMessage("XML::Parser produced errors: $@\n");
    }

    # XML::Parser::Lite may not be installed, only check if present.
    if ( eval 'require XML::Parser::Lite' ) {    ## no critic
        my $ParserLite = XML::Parser::Lite->new();
        eval { $ParserLite->parse($Code) };
        if ($@) {
            $Self->AddErrorMessage("XML::Parser::Lite produced errors: $@");
        }
    }
}

1;
