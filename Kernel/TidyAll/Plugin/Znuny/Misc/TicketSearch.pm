# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Misc::TicketSearch;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for code overwriting or redefining the TicketSearch function. Znuny-AdvancedTicketSearch should be used instead.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    if (
#         $Code =~ m{no \s warnings \s (?:\'|\")redefine(?:\'|\");}xms
#         && $Code =~ m{ Ticket::TicketSearch\s*\{ }ixms
        $Code =~ m{Kernel::System::Ticket::TicketSearch;}
        )
    {
        $Self->AddMessage(
            Message  => "Don't patch Kernel::System::Ticket::TicketSearch. Use Znuny-AdvancedTicketSearch instead.",
            Priority => 'notice',
        );
    }

    return;
}

1;
