# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep OTRSTimeZoneGet method call (ignore Framework version).',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
$DateTimeObject->OTRSTimeZoneGet();
EOF
        ExpectedSource => <<'EOF',
$DateTimeObject->OTRSTimeZoneGet();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSTimeZoneGet method call to ZnunyTimeZoneGet',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
$DateTimeObject->OTRSTimeZoneGet();
EOF
        ExpectedSource => <<'EOF',
$DateTimeObject->ZnunyTimeZoneGet();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSTimeZoneGet function call',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
$DateTimeObject->OTRSTimeZoneGet(
);
EOF
        ExpectedSource => <<'EOF',
$DateTimeObject->ZnunyTimeZoneGet(
);
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'ZnunyTimeZoneGet is allowed',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet)],
        Source   => <<'EOF',
$DateTimeObject->ZnunyTimeZoneGet();
EOF
        ExpectedSource => <<'EOF',
$DateTimeObject->ZnunyTimeZoneGet();
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
