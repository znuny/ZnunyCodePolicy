# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
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
        Name     => "Don't use LOOP suffix for labels",
        Filename => 'Znuny4OTRS.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::LabelCheck)],
        Source   => <<'EOF',
    MYLOOP:
    for my $Needed ( qw() ) {
        next MYLOOP if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Don't use LOOP suffix for labels",
    },
    {
        Name     => "Unknown labels",
        Filename => 'Znuny4OTRS.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::LabelCheck)],
        Source   => <<'EOF',
    NEEDED:
    for my $Needed ( qw() ) {
        next UNKNOWN if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'These statements reference unknown labels',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
