# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Whitespace::TrailingWhitespace;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Remove trailing spaces at end of lines
    $Code =~ s{^(.*?)[ ]+\n}{$1\n}xmsg;

    # Remove empty trailing lines
    $Code =~ s{\n(\s|\n)+\z}{\n}xmsg;

    return $Code;
}

1;
