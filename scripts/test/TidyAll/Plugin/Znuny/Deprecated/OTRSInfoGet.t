# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSInfoGet)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep OTRSInfoGet method call (ignore Framework version).',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSInfoGet)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
$EnvObject->OTRSInfoGet();
EOF
        ExpectedSource => <<'EOF',
$EnvObject->OTRSInfoGet();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSInfoGet method call to ZnunyInfoGet',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSInfoGet)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
$EnvObject->OTRSInfoGet();
EOF
        ExpectedSource => <<'EOF',
$EnvObject->ZnunyInfoGet();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSInfoGet function call',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSInfoGet)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
$Blub->OTRSInfoGet(
);
EOF
        ExpectedSource => <<'EOF',
$Blub->ZnunyInfoGet(
);
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'ZnunyInfoGet is allowed',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSInfoGet)],
        Source   => <<'EOF',
$EnvObject->ZnunyInfoGet();
EOF
        ExpectedSource => <<'EOF',
$EnvObject->ZnunyInfoGet();
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
