# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSStats)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep otrs_stats root below Znuny 7.5',
        Filename => 'var/stats/Stats.Example.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSStats)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_stats>
<Title>Example</Title>
</otrs_stats>
EOF
        ExpectedSource => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_stats>
<Title>Example</Title>
</otrs_stats>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename otrs_stats root to znuny_stats',
        Filename => 'var/stats/Stats.Example.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSStats)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_stats>
<Title>Example</Title>
</otrs_stats>
EOF
        ExpectedSource => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<znuny_stats>
<Title>Example</Title>
</znuny_stats>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename self-closing otrs_stats root',
        Filename => 'var/stats/Stats.Example.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSStats)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<'EOF',
<otrs_stats/>
EOF
        ExpectedSource => <<'EOF',
<znuny_stats/>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Keep znuny_stats root',
        Filename => 'var/stats/Stats.Example.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSStats)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
<znuny_stats>
<Title>Example</Title>
</znuny_stats>
EOF
        ExpectedSource => <<'EOF',
<znuny_stats>
<Title>Example</Title>
</znuny_stats>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Keep otrs_stats text that is not a tag',
        Filename => 'var/stats/Stats.Example.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSStats)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
<znuny_stats>
<Description>Legacy name otrs_stats stays in text.</Description>
</znuny_stats>
EOF
        ExpectedSource => <<'EOF',
<znuny_stats>
<Description>Legacy name otrs_stats stays in text.</Description>
</znuny_stats>
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
