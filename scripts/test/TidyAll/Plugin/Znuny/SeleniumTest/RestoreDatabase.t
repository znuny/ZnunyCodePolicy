# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::SeleniumTest::RestoreDatabase)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Using Kernel::System::UnitTest::Helper with option RestoreDatabase",
        Filename => 'scripts/test/Condensed-PackageName/Selenium/Modules/Znuny4OTRS.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SeleniumTest::RestoreDatabase)],
        Source   => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $SeleniumObject = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

EOF
        ExpectedSource => undef,
        ExpectedMessageSubstring =>
            'Using Kernel::System::UnitTest::Helper with option RestoreDatabase within Selenium tests is most likely a mistake',
    },
    {
        Name     => "Using Kernel::System::UnitTest::Helper without option RestoreDatabase",
        Filename => 'scripts/test/Condensed-PackageName/Selenium/Modules/Znuny4OTRS.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SeleniumTest::RestoreDatabase)],
        Source   => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        SomeOtherOption => 1,
    },
);

my $SeleniumObject = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
