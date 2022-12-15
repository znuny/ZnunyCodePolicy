# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Misc::NotificationEvent;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for code overwriting Kernel::System::Ticket::Event::NotificationEvent or Kernel::System::Ticket::Event::NotificationEvent::Transport::Email.
Znuny-AdvancedNotificationEvent should be used instead.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    if (
        $Code =~ m{Kernel::System::Ticket::Event::NotificationEvent;}
        )
    {
        $Self->AddMessage(
            Message  => "Don't patch Kernel::System::Ticket::Event::NotificationEvent. Use Znuny-AdvancedNotificationEvent instead.",
            Priority => 'notice',
        );
    }

    if (
        $Code =~ m{Kernel::System::Ticket::Event::NotificationEvent::Transport::Email;}
        )
    {
        $Self->AddMessage(
            Message  => "Don't patch Kernel::System::Ticket::Event::NotificationEvent::Transport::Email. Use Znuny-AdvancedNotificationEvent instead.",
            Priority => 'notice',
        );
    }

    return;
}

1;
