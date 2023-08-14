# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'No ObjectManager in use.',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectFunctionCall)],
        Source   => <<'EOF',
    my %Ticket = TicketObject->TicketGet(
        TicketID => 1,
        UserID   => 1,
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Object function call without variable declaration found.',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectFunctionCall)],
        Source   => <<'EOF',
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my %Ticket = TicketObject->TicketGet(
        TicketID => 1,
        UserID   => 1,
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => '
        Correct:
        Line 2:     my %Ticket = $TicketObject->TicketGet(',
    },
    {
        Name     => 'Nothing found.',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectFunctionCall)],
        Source   => <<'EOF',
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my %Ticket = $TicketObject->TicketGet(
        TicketID => 1,
        UserID   => 1,
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Check Object in String.',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectFunctionCall)],
        Source   => <<'EOF',
    $Self->{UnitTestDriverObject}->True(
        $Success,
        "HelperObject->DynamicFieldSet('$Field', '$Value') was successful."
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
