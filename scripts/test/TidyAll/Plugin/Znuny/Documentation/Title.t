# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Perl::UTF8)

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Invalid title for feature.md',
        Filename => 'doc/de/feature.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Coffee
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The title for this documentation file',
            'is not correct',
        ],
    },
    {
        Name     => 'Invalid title for config.md',
        Filename => 'doc/de/config.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Coffee
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The title for this documentation file',
            'is not correct',
        ],
    },
    {
        Name     => 'Invalid title for feature.md',
        Filename => 'doc/en/feature.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Coffee
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The title for this documentation file',
            'is not correct',
        ],
    },
    {
        Name     => 'Invalid title for config.md',
        Filename => 'doc/en/config.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Coffee
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The title for this documentation file',
            'is not correct',
        ],
    },

    {
        Name     => 'Valid title for feature.md',
        Filename => 'doc/de/feature.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Funktionalität
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Valid title for config.md',
        Filename => 'doc/de/config.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Konfiguration
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Valid title for feature.md',
        Filename => 'doc/en/feature.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Functionality
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Valid title for config.md',
        Filename => 'doc/en/config.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::Title)],
        Source   => <<'EOF',
# Configuration
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
