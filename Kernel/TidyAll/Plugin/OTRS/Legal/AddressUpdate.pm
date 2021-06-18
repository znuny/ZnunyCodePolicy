# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::Legal::AddressUpdate;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $Code =~ s{Norsk-Data-Str\.\s+1}{Zimmersmühlenweg 11}smxg;
    $Code =~ s{61352\s+Bad\s+Homburg}{61440 Oberursel}smxg;

    return $Code;
}

1;
