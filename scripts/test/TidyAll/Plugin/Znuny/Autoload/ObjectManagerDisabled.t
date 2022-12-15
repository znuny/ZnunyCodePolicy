# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Object manager in autoload is disabled.",
        Filename => 'Kernel/Autoload/ObjectManagerDisabled.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Autoload::ObjectManagerDisabled)],
        Source   => <<'EOF',
our $ObjectManagerDisabled = 1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Don't disable object manager in autoload modules.",
    },
    {
        Name     => "Object manager in autoload is not disabled.",
        Filename => 'Kernel/Autoload/ObjectManagerDisabled.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Autoload::ObjectManagerDisabled)],
        Source   => <<'EOF',
our $ObjectManagerDisabled = 0;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => "ObjectManagerDisabled flag not present.",
        Filename => 'Kernel/Autoload/ObjectManagerDisabled.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Autoload::ObjectManagerDisabled)],
        Source   => <<'EOF',
our $NoObjectManagerDisabledFlagPresent = 1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
