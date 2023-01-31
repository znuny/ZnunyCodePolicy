# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Legal::UpdateOTRSCopyright;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $Code =~ s{Copyright \(C\) 2001-\d{4} OTRS }{Copyright (C) 2001-2021 OTRS }smg;

    return $Code;
}

1;
