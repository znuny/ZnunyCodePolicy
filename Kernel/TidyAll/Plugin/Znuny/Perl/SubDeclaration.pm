# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::SubDeclaration;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

=head1 SYNOPSIS

Checks for sub declarations with the brace in the following line and corrects them.

    sub abc
    {
        ...
    }

will become:

    sub abc {
        ...
    }

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    if ( $Code =~ m|^sub \s+ \w+ \s* \r?\n \{ |smx ) {
        $Code =~ s|^(sub \s+ \w+) \s* \r?\n \{ |$1 {|smxg;
    }

    return $Code;
}

1;
