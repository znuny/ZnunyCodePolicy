# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Common::CustomizationMarkers)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "No patched file",
        Filename => 'Kernel/System/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Misc::NotificationEvent)],
        Source   => <<'EOF',
# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::SomeEvent;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => "Patched Kernel::System::Ticket::Event::NotificationEvent",
        Filename => 'Kernel/System/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Misc::NotificationEvent)],
        Source   => <<'EOF',
# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::NotificationEvent;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Don't patch Kernel::System::Ticket::Event::NotificationEvent",
    },
    {
        Name     => "Patched Kernel::System::Ticket::Event::NotificationEvent::Transport::Email",
        Filename => 'Kernel/System/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Misc::NotificationEvent)],
        Source   => <<'EOF',
# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::NotificationEvent::Transport::Email;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Don't patch Kernel::System::Ticket::Event::NotificationEvent::Transport::Email",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
