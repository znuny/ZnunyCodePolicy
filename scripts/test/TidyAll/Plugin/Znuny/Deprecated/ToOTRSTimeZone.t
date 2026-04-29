# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::ToOTRSTimeZone)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep ToOTRSTimeZone method call (ignore Framework version).',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ToOTRSTimeZone)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
$EnvObject->ToOTRSTimeZone();
EOF
        ExpectedSource => <<'EOF',
$EnvObject->ToOTRSTimeZone();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename ToOTRSTimeZone method call to ToZnunyTimeZone',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ToOTRSTimeZone)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
$EnvObject->ToOTRSTimeZone();
EOF
        ExpectedSource => <<'EOF',
$EnvObject->ToZnunyTimeZone();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename ToOTRSTimeZone function call',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ToOTRSTimeZone)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
$Blub->ToOTRSTimeZone(
);
EOF
        ExpectedSource => <<'EOF',
$Blub->ToZnunyTimeZone(
);
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'ToZnunyTimeZone is allowed',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ToOTRSTimeZone)],
        Source   => <<'EOF',
$EnvObject->ToZnunyTimeZone();
EOF
        ExpectedSource => <<'EOF',
$EnvObject->ToZnunyTimeZone();
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
