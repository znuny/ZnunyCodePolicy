# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Common::Origin)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Code marker does not match package name",
        Filename => 'Kernel/System/Console/Command/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::CodeMarkerPackageName)],
        Source   => <<'EOF',
# ---
# Znuny-WrongPackageName
# ---
# ---
EOF
        ExpectedSource           => undef,    # no code change expected
        ExpectedMessageSubstring => [
            "Code marker '# Znuny-WrongPackageName' should be",
            'Znuny-SomeTestPackage',
        ],
        Settings => {
            'Context::OPM'       => 1,
            'Context::Framework' => 0,
            'ProductName'        => 'Znuny-SomeTestPackage',
        },
    },
    {
        Name     => "Code marker does match package name",
        Filename => 'Kernel/System/Console/Command/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::CodeMarkerPackageName)],
        Source   => <<'EOF',
# ---
# Znuny-SomeTestPackage
# ---
# ---
EOF
        ExpectedSource           => undef,    # no code change expected
        ExpectedMessageSubstring => undef,
        Settings                 => {
            'Context::OPM'       => 1,
            'Context::Framework' => 0,
            'ProductName'        => 'Znuny-SomeTestPackage',
        },
    },
    {
        Name     => "No code marker found",
        Filename => 'Kernel/System/Console/Command/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::CodeMarkerPackageName)],
        Source   => <<'EOF',
print "TEST";
EOF
        ExpectedSource           => undef,    # no code change expected
        ExpectedMessageSubstring => undef,
        Settings                 => {
            'Context::OPM'       => 1,
            'Context::Framework' => 0,
            'ProductName'        => 'Znuny-SomeTestPackage',
        },
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
