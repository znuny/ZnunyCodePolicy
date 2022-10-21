# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'CodeTags, valid',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::CodeTags)],
        Source   => <<'EOF',
    <CodeInstall Type="post"><![CDATA[
        $Kernel::OM->Get('var::packagesetup::MyPackge')->CodeInstall();
    ]]></CodeInstall>
EOF
    },
    {
        Name     => 'CodeTags, $Self used',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::CodeTags)],
        Source   => <<'EOF',
    <CodeInstall Type="post"><![CDATA[
        $Self->{LogObject}->Log(...)
    ]]></CodeInstall>
EOF
        ExpectedMessageSubstring => 'Don\'t use $Self in <Code*> tags',
    },
    {
        Name     => 'CodeTags, no cdata',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::CodeTags)],
        Source   => <<'EOF',
    <CodeInstall Type="post">
        $Kernel::OM->Get('var::packagesetup::MyPackge')->CodeInstall();
    </CodeInstall>
EOF
        ExpectedMessageSubstring => '<Code*> tags should always be wrapped in CDATA sections',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
