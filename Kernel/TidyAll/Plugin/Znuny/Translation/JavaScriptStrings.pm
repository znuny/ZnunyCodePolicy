# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Translation::JavaScriptStrings;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks if you overwrite the JavaScriptStrings array.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code !~ m{\$Self\-\>\{JavaScriptStrings\}}ms;

    if (
        $Code =~ m{^\s*\$Self\-\>\{JavaScriptStrings\}\s*=}ms
        || $Code !~ m{^\s*push\s*\@\{\s*\$Self\-\>\{JavaScriptStrings\}\s*\}\s*,}ms
    ) {
        my $ErrorMessage = "If you use JavaScriptStrings, make sure that the original values are not overwritten.

    \$Self->{JavaScriptStrings} //= [];
    push \@{\$Self->{JavaScriptStrings}}, (
        'Translation',
        'Another',
    );";

        $Self->AddMessage(
            Message  => $ErrorMessage,
            Priority => 'warning',
        );
    }

    return;
}

1;
