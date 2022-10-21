# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Perl::ObjectManagerDirectCall)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Direct ObjectManager call found",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectManagerDirectCall)],
        Source   => <<'EOF',
$Kernel::OM->Get('Kernel::System::Coffee')->Get();
EOF
        ExpectedMessageSubstring =>
            "Don't use direct object manager calls. Fetch the object in a separate variable first",
    },

);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
