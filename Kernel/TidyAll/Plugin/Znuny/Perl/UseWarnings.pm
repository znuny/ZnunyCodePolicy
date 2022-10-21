# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::UseWarnings;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

# Perl::Critic will make sure that 'use strict' is enabled.
# Now we check that 'use warnings' is also.
sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check if use warnings is present, otherwise add it
    if ( $Code !~ m{^[ \t]*use\s+warnings;}mx ) {
        $Code =~ s{^[ \t]*use\s+strict;}{use strict;\nuse warnings;}mx;
    }

    return $Code;
}

1;
