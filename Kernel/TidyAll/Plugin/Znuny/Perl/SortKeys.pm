# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::SortKeys;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

=head1 SYNOPSIS

Inserts sort statements to lines like

    for my $Module (sort keys %Modules) ...

because the key's randomness can be a source of problems that is hard to debug.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $Code =~ s{ ^ (\s* for \s+ my \s+ \$ \w+ \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;
    $Code =~ s{ ^ (\s* for \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{ (?: sort)?[ ]keys \s+ [\$|\\] }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Don't use hash references while accessing its keys.
$ErrorMessage
EOF
    }

    return;
}

1;
