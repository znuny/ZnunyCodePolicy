# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Possible guard clause before end of loop",
        Filename => 'Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::GuardClause)],
        Source   => <<'EOF',
    for my $Needed ( qw(1 2 3) ) {
        if ( $Param{$Needed} ) {
            # todo
        }
    }
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Possible guard clause before end of loop.',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
