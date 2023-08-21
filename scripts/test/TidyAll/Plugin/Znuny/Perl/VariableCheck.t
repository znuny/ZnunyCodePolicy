# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
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
        Name =>
            "'IsString' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsString($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsStringWithData' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsStringWithData($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsArrayRefWithData' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsArrayRefWithData($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsHashRefWithData' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsHashRefWithData($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsNumber' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsNumber($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsInteger' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsInteger($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsPositiveInteger' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsPositiveInteger($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsIPv4Address' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsIPv4Address($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsIPv6Address' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsIPv6Address($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'IsMD5Sum' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
IsMD5Sum($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'DataIsDifferent' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
DataIsDifferent($Test)
EOF
        ExpectedMessageSubstring => "'use' statement for Kernel::System::VariableCheck is missing",
    },
    {
        Name =>
            "'DataIsDifferent' Man... It's nice that you are using the variable check function but you forgot the use",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
use Kernel::System::VariableCheck qw(:all);
DataIsDifferent($Test)
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name =>
            "use Kernel::System::VariableCheck - but never used a VariableCheck function",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Source   => <<'EOF',
use Kernel::System::VariableCheck qw(:all);
EOF
        ExpectedMessageSubstring =>
            "'use' statement for Kernel::System::VariableCheck is used, but no VariableCheck function was ever used.",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
