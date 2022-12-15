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
        Name     => 'Invalid image path in documentation file',
        Filename => 'doc/de/feature.md',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Documentation::ImagePath)],
        Source   => <<'EOF',
![Coffee](doc/de/images/Coffee.png)
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Please pay attention to the correct image',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
