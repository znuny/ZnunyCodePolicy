# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Common::CustomizationMarkersTT;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks that only valid customization markers are used to mark changed lines in customized template files.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Find customization markers with // in .tt files and replace them with #.
    #
    #   // ---
    #   // OTRSXyZ - Here a comment.
    #   // ---
    #
    #   to
    #
    #   # ---
    #   # OTRSXyZ - Here a comment.
    #   # ---
    #
    $Code =~ s{
        (
            ^ [ ]* \/\/ [ ]+ --- [ ]* $ \n
            ^ [ ]* \/\/ [ ]+ [^ ]+ (?: [ ]+ - [^\n]+ | ) $ \n
            ^ [ ]* \/\/ [ ]+ --- [ ]* $ \n
            (?: ^ [ ]* \/\/ [^\n]* $ \n )*
        )
    }{
        my $String = $1;
        $String =~ s{ ^ [ ]* \/\/ }{#}xmsg;
        $String;
    }xmsge;

    # Find wrong customization markers in .tt files and correct them.
    #
    #   // ---
    #
    #   to
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]* \/\/ [ ]+ --- [ ]* $ }{# ---}xmsg;

    return $Code;
}

1;
