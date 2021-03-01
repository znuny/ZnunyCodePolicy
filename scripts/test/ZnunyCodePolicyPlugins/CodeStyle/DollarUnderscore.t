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
        Name      => '6.0 - Don\'t (implicitly) use the default variable $_. Variables should have meaningful names.',
        Filename  => 'Znuny4OTRS.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::DollarUnderscore)],
        Framework => '6.0',
        Source    => <<'EOF',
    for ( qw(1 2 3) ) {
        if ($Param{ $_ }){
            # todo
        }
    }
EOF
        STDOUT    => "TidyAll::Plugin::Znuny::CodeStyle::DollarUnderscore

Don't (implicitly) use the default variable \$_. Variables should have meaningful names.\n\tLine 1:     for ( qw(1 2 3) ) {
",
        Exception => 1,
    },
    {
        Name      => '6.0 - Ignore variable $_ when commented out',
        Filename  => 'Znuny4OTRS.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::DollarUnderscore)],
        Framework => '6.0',
        Source    => <<'EOF',
#     for ( qw(1 2 3) ) {
#         if ($Param{ $_ }){
#             # todo
#         }
#     }
    for $Needed ( qw(1 2 3) ) {
        if ($Param{ $Needed }){
            # todo
        }
    }
EOF
        Exception => 0,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
