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
        Name      => "6.0 - Avoid looks_like_number since the result is not consistent on different systems.",
        Filename  => 'Kernel/System/Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::IsIntegerVariableCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
return if looks_like_number($Test);
EOF
        Exception => 0,
        STDOUT    =>'[notice] for the next file:
TidyAll::Plugin::Znuny::Perl::IsIntegerVariableCheck

NOTICE: Avoid looks_like_number since the result is not consistent on different systems.
Use IsInteger() and IsPositiveInteger().

Line 1: return if looks_like_number($Test);


',
    },

);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
