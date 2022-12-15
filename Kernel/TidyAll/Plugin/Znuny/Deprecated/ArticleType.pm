# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Deprecated::ArticleType;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for deprecated ArticleType.

=cut

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    # exclude framework files
    return if index( $Filename, 'Kernel/System/Calendar/Event/Notification.pm' ) != -1;
    return if index( $Filename, 'Kernel/System/Ticket/Event/NotificationEvent.pm' ) != -1;

    my $Code = $Self->GetFileContent($Filename);
    return if $Self->IsPluginDisabled( Code => $Code );

    my $ArticleTypeCallLines = '';
    my $LineCounter          = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;
        next LINE if $Line !~ m{ArticleType [ ]+}xms;

        $ArticleTypeCallLines .= "\n\tLine $LineCounter: $Line";
    }

    return if !length $ArticleTypeCallLines;

    my $ErrorMessage = "There are lines containing 'ArticleType' which is deprecated:\n" . $ArticleTypeCallLines;

    return if !length $ErrorMessage;

    $Self->AddMessage(
        Message  => $ErrorMessage,
        Priority => 'notice',
    );

    return;
}

1;
