# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
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
        Name      => "6.0 - Don't use LOOP suffix for labels:",
        Filename  => 'Znuny4OTRS.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::LabelCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
    LOOP:
    for my $Needed ( qw() ) {

        next LOOP if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }
EOF
        Exception => 1,
    },
    {
        Name      => "6.0 - These statements reference unknown labels:",
        Filename  => 'Znuny4OTRS.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::LabelCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
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
        Exception => 1,
    },
    {
        Name      => "6.0 - duplicate labels:",
        Filename  => 'Znuny4OTRS.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::LabelCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
    NEEDED:
    for my $Needed ( qw() ) {

        next NEEDED if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    NEEDED:
    for my $Needed ( qw() ) {

        next NEEDED if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - duplicate labels (todo - Exception should be 1):",
        Filename  => 'Znuny4OTRS.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::LabelCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
    NEEDED:
    for my $Needed ( qw() ) {

        next NEEDED if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    OTHER:
    for my $Needed ( qw() ) {

        next NEEDED if defined $Param{ $Needed };

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }
EOF
        Exception => 0,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
