# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Perl::ForMy)
## nofilter(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Avoid use of default variable $_',
        Filename => 'Znuny4OTRS.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::DollarUnderscore)],
        Source   => <<'EOF',
    for ( qw(1 2 3) ) {
        if ($Param{ $_ }){
            # todo
        }
    }
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Don't (implicitly) use the default variable \$_.",
    },
    {
        Name     => 'Ignore variable $_ when commented out',
        Filename => 'Znuny4OTRS.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::DollarUnderscore)],
        Source   => <<'EOF',
#     for ( qw(1 2 3) ) {
#         if ($Param{ $_ }){
#             # todo
#         }
#     }
    for my $Needed ( qw(1 2 3) ) {
        if ($Param{ $Needed }){
            # todo
        }
    }
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
