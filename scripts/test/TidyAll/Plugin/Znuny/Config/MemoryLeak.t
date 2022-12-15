# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Possible memory leak detected (no VERSION 1.1 marker found)',
        Filename => 'Kernel/Config/Files/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Config::MemoryLeak)],
        Source   => <<'EOF',
no warnings 'redefine';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Possible memory leak detected',
    },
    {
        Name     => 'Possible memory leak prevented via VERSION 1.1 marker',
        Filename => 'Kernel/Config/Files/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Config::MemoryLeak)],
        Source   => <<'EOF',
# VERSION:1.1
no warnings 'redefine';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Config file without redefine',
        Filename => 'Kernel/Config/Files/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Config::MemoryLeak)],
        Source   => <<'EOF',
$Self->{SomeKey} = 'SomeValue';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
