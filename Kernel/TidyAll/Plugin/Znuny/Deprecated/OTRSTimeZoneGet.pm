# --
# Copyright (C) 2012-2024 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks and transforms for deprecated datetime helper C<OTRSTimeZoneGet()> to C<ZnunyTimeZoneGet()>.

Note: This plugin is only available for Znuny 7.5.0 and higher.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan('7.5');

    # Rename OTRSTimeZoneGet to ZnunyTimeZoneGet
    $Code =~ s{(->OTRSTimeZoneGet\()}{->ZnunyTimeZoneGet(}g;

    return $Code;
}

1;
