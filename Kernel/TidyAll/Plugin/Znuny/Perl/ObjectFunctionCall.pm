# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::ObjectFunctionCall;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

=head1 SYNOPSIS

This plugin checks for missing variable declaration of objects on function calls.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Skip if the code doesn't use the ObjectManager
    return if $Code !~ m{\$Kernel::OM}smx;

    # Search for cases like this. The $ before TicketObject is missing:
    # my %Ticket = TicketObject->TicketGet(
    #     TicketID => 1,
    #     UserID   => 1,
    # );

    my $LineCounter = 0;
    my $Message    = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;
        next LINE if $Line =~ m{^ \#}smx;
        next LINE if $Line =~ m{\$\S*Object}smx;
        next LINE if $Line =~ m{"\S*Object}smx;
        next LINE if $Line !~ m{(\S*Object)->\S+\(}smx;
        my $Object = $1;

        my $NewLine = $Line;
        $NewLine =~ s{$Object}{\$$Object}smx;

        $Message .= "Line $LineCounter: $Line\n";
        $Message .= "\nCorrect:\n";
        $Message .= "Line $LineCounter: $NewLine";
    }

    my $ErrorMessage = '';
    if ( length $Message ) {
        $ErrorMessage .= "Object function call with missing variable declaration:\n" . $Message;
    }

    return if !length $ErrorMessage;

    $Self->AddErrorMessage($ErrorMessage);
}

1;
