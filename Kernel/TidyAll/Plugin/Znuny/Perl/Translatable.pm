# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::Translatable;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    if ( $Code =~ m{Translatable\(}xms && $Code !~ m{^use\s+Kernel::Language[^\n]+Translatable}xms ) {
        $Self->AddErrorMessage(<<"EOF");
The code uses Kernel::Language::Translatable(), but does not import it to the current package. Add:
use Kernel::Language qw(Translatable);
EOF
    }

    return;
}

1;
