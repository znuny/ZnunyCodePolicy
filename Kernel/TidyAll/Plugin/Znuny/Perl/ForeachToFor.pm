# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::ForeachToFor;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # The following test matches only for a foreach without a "#" in the
    # beginning of a line. The foreach has to be the first expression in a
    # line, spaces do not matter. The foreach is replaced with for.
    # Comments and other lines with other chars before the foreach are
    # ignored.

    $Code =~ s{^ ([^#] \s{0,200}) foreach (.*?) }{$1for$2}xmsg;

    return $Code;
}

1;
