# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
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
        Name      => "6.0 - Using Kernel::System::UnitTest::Helper with option RestoreDatabase within Selenium tests is most likely a mistake because data will get lost between requests.",
        Filename  => 'scripts/test/Condensed-PackageName/Selenium/Modules/Znuny.t',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SeleniumTest::RestoreDatabase)],
        Framework => '6.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreSystemConfiguration => 1,
        RestoreDatabase            => 1,
    },
);

my $SeleniumObject = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

EOF
        Exception => 0,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
