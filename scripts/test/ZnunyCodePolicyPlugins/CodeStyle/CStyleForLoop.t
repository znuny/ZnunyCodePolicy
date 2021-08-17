# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
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
        Name      => '6.0 - NOTICE: Avoid C-style for-loops if possible.',
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::CStyleForLoop)],
        Framework => '6.0',
        Source    => <<'EOF',
    for (my $Test) {
    }
EOF
        Exception => 0,
        STDOUT    => "[notice] for the next file:
TidyAll::Plugin::Znuny::CodeStyle::CStyleForLoop

NOTICE: Avoid C-style for-loops if possible.

\tLine 1:     for (my \$Test) {

",
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
