# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
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
        Name     => 'Unit test in correct directory',
        Filename => 'scripts/test/ZnunySomePackage/UnitTest.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::UnitTest::Path)],
        Source   => <<'EOF',
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::Selenium');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
        Settings                 => {
            ProductName => 'Znuny-SomePackage',
        },
    },
    {
        Name     => 'Unit test in wrong directory',
        Filename => 'scripts/test/ZnunyCodePolicy/UnitTest.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::UnitTest::Path)],
        Source   => <<'EOF',
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::Selenium');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following directory is expected',
        Settings                 => {
            ProductName => 'Znuny-SomePackage',
        },
    },
    {
        Name     => 'Unit test in wrong directory',
        Filename => 'scripts/test/ZnunySomePackage.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::UnitTest::Path)],
        Source   => <<'EOF',
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::Selenium');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following directory is expected',
        Settings                 => {
            ProductName => 'Znuny-SomePackage',
        },
    },
    {
        Name     => 'Unit test in wrong directory',
        Filename => 'scripts/ZnunySomePackage.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::UnitTest::Path)],
        Source   => <<'EOF',
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::Selenium');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following directory is expected',
        Settings                 => {
            ProductName => 'Znuny-SomePackage',
        },
    },
    {
        Name     => 'Unit test in wrong directory',
        Filename => 'ZnunySomePackage.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::UnitTest::Path)],
        Source   => <<'EOF',
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::Selenium');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following directory is expected',
        Settings                 => {
            ProductName => 'Znuny-SomePackage',
        },
    },
    {
        Name     => 'Unit test in wrong directory',
        Filename => 'Kernel/System/ZnunySomePackage.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::UnitTest::Path)],
        Source   => <<'EOF',
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::Selenium');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following directory is expected',
        Settings                 => {
            ProductName => 'Znuny-SomePackage',
        },
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
