# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::TODOCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for "todo"s in comments.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $LineCounter = 0;
    my $TODOLine    = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        my $LowerCaseLine = lc($Line);
        next LINE if $LowerCaseLine !~ m{\btodos?\b}smx;

        $TODOLine .= "Line $LineCounter: $Line\n";
    }

    my $ErrorMessage = '';
    if ( length $TODOLine ) {
        $ErrorMessage .= "Pay attention to tasks that may not have been completed:\n" . $TODOLine;
    }

    return if !length $ErrorMessage;

    $Self->AddMessage(
        Message  => $ErrorMessage,
        Priority => 'notice',
    );
}

1;
