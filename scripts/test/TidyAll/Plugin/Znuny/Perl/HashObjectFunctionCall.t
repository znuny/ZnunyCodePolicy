# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
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

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Don't use object function calls in hash assignment",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::HashObjectFunctionCall)],
        Source   => <<'EOF',
$Object->Drink(
    Coffee => $CoffeObject->Get()
);
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Don't use object function calls in hash assignments",
    },

);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
