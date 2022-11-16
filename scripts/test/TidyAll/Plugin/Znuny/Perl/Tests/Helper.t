# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

## nofilter(TidyAll::Plugin::Znuny::Perl::Tests::Helper)

use vars (qw($Self));
use utf8;

## nofilter(TidyAll::Plugin::Znuny::Perl::Tests::Helper)
use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Helper not used',
        Filename => 'test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::Tests::Helper)],
        Source   => <<'EOF',
1;
EOF
    },
    {
        Name     => 'Helper used',
        Filename => 'test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::Tests::Helper)],
        Source   => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
    },
    {
        Name     => 'Helper created before Selenium object',
        Filename => 'test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::Tests::Helper)],
        Source   => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestDocumentSearchIndices => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
EOF
    },
    {
        Name     => 'Helper created after Selenium object',
        Filename => 'test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::Tests::Helper)],
        Source   => <<'EOF',
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestDocumentSearchIndices => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
        ExpectedMessageSubstring => 'Always set the Helper object params before creating the Selenium object',
    },
    {
        Name     => 'RestoreDatabase in a Selenium test',
        Filename => 'test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::Tests::Helper)],
        Source   => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
EOF
        ExpectedMessageSubstring => "Don't use the Helper flag 'RestoreDatabase' in Selenium tests",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
