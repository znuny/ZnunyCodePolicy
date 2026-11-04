# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneGet)
## nofilter(TidyAll::Plugin::Znuny::Deprecated::ToOTRSTimeZone)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep OTRSTimeZone setting below Znuny 7.5',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
my $TimeZone = $ConfigObject->Get('OTRSTimeZone');
EOF
        ExpectedSource => <<'EOF',
my $TimeZone = $ConfigObject->Get('OTRSTimeZone');
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSTimeZone in ConfigObject->Get()',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
my $TimeZone  = $ConfigObject->Get('OTRSTimeZone');
my $TimeZone2 = $ConfigObject->Get("OTRSTimeZone");
EOF
        ExpectedSource => <<'EOF',
my $TimeZone  = $ConfigObject->Get('ZnunyTimeZone');
my $TimeZone2 = $ConfigObject->Get("ZnunyTimeZone");
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSTimeZone in ConfigSettingChange()',
        Filename => 'scripts/test/Example.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
$HelperObject->ConfigSettingChange(
    Valid => 1,
    Key   => 'OTRSTimeZone',
    Value => 'Europe/Berlin',
);
EOF
        ExpectedSource => <<'EOF',
$HelperObject->ConfigSettingChange(
    Valid => 1,
    Key   => 'ZnunyTimeZone',
    Value => 'Europe/Berlin',
);
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSTimeZone hash key',
        Filename => 'Kernel/Config.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
$Self->{OTRSTimeZone}   = 'Europe/Berlin';
$Self->{'OTRSTimeZone'} = 'Europe/Berlin';
EOF
        ExpectedSource => <<'EOF',
$Self->{ZnunyTimeZone}   = 'Europe/Berlin';
$Self->{'ZnunyTimeZone'} = 'Europe/Berlin';
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename OTRSTimeZone setting in XML',
        Filename => 'Kernel/Config/Files/XML/Example.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
<Setting Name="OTRSTimeZone" Required="1" Valid="1">
EOF
        ExpectedSource => <<'EOF',
<Setting Name="ZnunyTimeZone" Required="1" Valid="1">
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Keep OTRSTimeZoneGet, ToOTRSTimeZone and plain text',
        Filename => 'Kernel/System/User.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSTimeZoneSetting)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
my $TimeZone = $DateTimeObject->OTRSTimeZoneGet();
$DateTimeObject->ToOTRSTimeZone();
my $OTRSTimeZone = 'UTC';
# Set OTRSTimeZone instead.
EOF
        ExpectedSource => <<'EOF',
my $TimeZone = $DateTimeObject->OTRSTimeZoneGet();
$DateTimeObject->ToOTRSTimeZone();
my $OTRSTimeZone = 'UTC';
# Set OTRSTimeZone instead.
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
