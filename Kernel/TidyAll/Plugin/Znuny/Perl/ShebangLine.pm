# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::ShebangLine;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    if ( substr( $Code, 0, 15 ) eq '#!/usr/bin/perl' ) {
        $Code =~ s{\A\#!/usr/bin/perl.*?$}{#!/usr/bin/env perl}xms;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check for presence of the correct shebang line.
    if ( substr( $Code, 0, 20 ) ne "#!/usr/bin/env perl\n" ) {
        $Self->AddErrorMessage("Change the shebang line to '#!/usr/bin/env perl'.");
    }

    return;
}

1;
