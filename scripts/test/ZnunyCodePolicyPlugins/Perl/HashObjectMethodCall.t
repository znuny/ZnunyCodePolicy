# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
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
        Name      => "6.0 - Object method calls in hash assignment found",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::HashObjectMethodCall)],
        Framework => '6.0',
        Source    => <<'EOF',
$Object->Drink(
    Coffee => $CoffeObject->Get()
);
EOF
        Exception => 0,
    },

);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
