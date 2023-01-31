# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'exit, forbidden',
        Filename => 'Kernel/System/Console/Command/Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::NoExitInConsoleCommands)],
        Source   => <<'EOF',
exit 1;
EOF
        ExpectedMessageSubstring => "Don't use 'exit' in console commands",
    },
    {
        Name     => 'exit, forbidden',
        Filename => 'Kernel/System/Console/Command/Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::NoExitInConsoleCommands)],
        Source   => <<'EOF',
    if (1) { exit; };
EOF
        ExpectedMessageSubstring => "Don't use 'exit' in console commands",
    },
    {
        Name     => '$Self->ExitCodeOk()',
        Filename => 'Kernel/System/Console/Command/Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::NoExitInConsoleCommands)],
        Source   => <<'EOF',
    return $Self->ExitCodeOk();
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
