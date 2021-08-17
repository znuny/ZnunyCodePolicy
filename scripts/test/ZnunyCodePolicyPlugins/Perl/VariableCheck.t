# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
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

use scripts::test::ZnunyCodePolicyPlugins;

my @Tests = (
    {
        Name =>
            "6.0 - 'IsString' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsString($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsStringWithData' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsStringWithData($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsArrayRefWithData' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsArrayRefWithData($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsHashRefWithData' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsHashRefWithData($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsNumber' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsNumber($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsInteger' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsInteger($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsPositiveInteger' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsPositiveInteger($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsIPv4Address' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsIPv4Address($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsIPv6Address' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsIPv6Address($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'IsMD5Sum' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
IsMD5Sum($Test)
EOF
        Exception => 0,
    },
    {
        Name =>
            "6.0 - 'DataIsDifferent' Man... It's nice that you are using the variable check function but you forgot the use:",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::VariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
DataIsDifferent($Test)
EOF
        Exception => 0,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
