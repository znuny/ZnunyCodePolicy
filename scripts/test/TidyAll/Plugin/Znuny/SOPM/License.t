# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
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
        Name     => 'Valid license for vendor',
        Filename => 'Znuny-Playground.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::License)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_package version="1.0">
    <Name>Znuny-Playground</Name>
    <Version>6.0.5</Version>
    <ChangeLog Version="6.0.5" Date="2020-01-29 16:13:46 +0100">Test release.</ChangeLog>
    <ChangeLog Version="1.0.0" Date="2014-04-30 11:16:21 +0200">Initial test.</ChangeLog>
    <Framework>6.9.x</Framework>
    <Framework>6.3.x</Framework>
    <PackageRequired Version="6.9.1">Test</PackageRequired>
    <Vendor>Znuny GmbH</Vendor>
    <URL>http://znuny.com/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">This package contains no functionality, it's just a playground.</Description>
    <Description Lang="de">Dieses Paket enthält keine Funktionalität, es ist nur ein Spielplatz.</Description>
    <Filelist>
        <File Permission="660" Location="Kernel/Config/Files/XML/ZnunyPlayground.xml"/>
        <File Permission="660" Location="Kernel/Language/de_ZnunyPlayground.pm"/>
        <File Permission="660" Location="Kernel/Modules/AgentTicketPlayground.pm"/>
        <File Permission="660" Location="Kernel/Output/HTML/OutputFilterZnunyPlayground.pm"/>
    </Filelist>
    <PackageMerge Name="Znuny-Playground" TargetVersion="6.0.5"></PackageMerge>
</otrs_package>
EOF
    },
    {
        Name     => 'Auto-corrected invalid license for vendor',
        Filename => 'Znuny-Playground.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::License)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_package version="1.0">
    <Name>Znuny-Playground</Name>
    <Version>6.0.5</Version>
    <ChangeLog Version="6.0.5" Date="2020-01-29 16:13:46 +0100">Test release.</ChangeLog>
    <ChangeLog Version="1.0.0" Date="2014-04-30 11:16:21 +0200">Initial test.</ChangeLog>
    <Framework>6.9.x</Framework>
    <Framework>6.3.x</Framework>
    <PackageRequired Version="6.9.1">Test</PackageRequired>
    <Vendor>Znuny GmbH</Vendor>
    <URL>http://znuny.com/</URL>
    <License>INVALID GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">This package contains no functionality, it's just a playground.</Description>
    <Description Lang="de">Dieses Paket enthält keine Funktionalität, es ist nur ein Spielplatz.</Description>
    <Filelist>
        <File Permission="660" Location="Kernel/Config/Files/XML/ZnunyPlayground.xml"/>
        <File Permission="660" Location="Kernel/Language/de_ZnunyPlayground.pm"/>
        <File Permission="660" Location="Kernel/Modules/AgentTicketPlayground.pm"/>
        <File Permission="660" Location="Kernel/Output/HTML/OutputFilterZnunyPlayground.pm"/>
    </Filelist>
    <PackageMerge Name="Znuny-Playground" TargetVersion="6.0.5"></PackageMerge>
</otrs_package>
EOF
        ExpectedSource => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_package version="1.0">
    <Name>Znuny-Playground</Name>
    <Version>6.0.5</Version>
    <ChangeLog Version="6.0.5" Date="2020-01-29 16:13:46 +0100">Test release.</ChangeLog>
    <ChangeLog Version="1.0.0" Date="2014-04-30 11:16:21 +0200">Initial test.</ChangeLog>
    <Framework>6.9.x</Framework>
    <Framework>6.3.x</Framework>
    <PackageRequired Version="6.9.1">Test</PackageRequired>
    <Vendor>Znuny GmbH</Vendor>
    <URL>http://znuny.com/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">This package contains no functionality, it's just a playground.</Description>
    <Description Lang="de">Dieses Paket enthält keine Funktionalität, es ist nur ein Spielplatz.</Description>
    <Filelist>
        <File Permission="660" Location="Kernel/Config/Files/XML/ZnunyPlayground.xml"/>
        <File Permission="660" Location="Kernel/Language/de_ZnunyPlayground.pm"/>
        <File Permission="660" Location="Kernel/Modules/AgentTicketPlayground.pm"/>
        <File Permission="660" Location="Kernel/Output/HTML/OutputFilterZnunyPlayground.pm"/>
    </Filelist>
    <PackageMerge Name="Znuny-Playground" TargetVersion="6.0.5"></PackageMerge>
</otrs_package>
EOF
    },
    {
        Name     => 'Custom license for third-party vendor',
        Filename => 'Znuny-Playground.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::License)],
        Settings => {
            IsThirdPartyProduct => 1,
        },
        Source => <<'EOF',
<?xml version="1.0" encoding="utf-8"?>
<otrs_package version="1.0">
    <Name>Znuny-Playground</Name>
    <Version>6.0.5</Version>
    <ChangeLog Version="6.0.5" Date="2020-01-29 16:13:46 +0100">Test release.</ChangeLog>
    <ChangeLog Version="1.0.0" Date="2014-04-30 11:16:21 +0200">Initial test.</ChangeLog>
    <Framework>6.9.x</Framework>
    <Framework>6.3.x</Framework>
    <PackageRequired Version="6.9.1">Test</PackageRequired>
    <Vendor>Some company</Vendor>
    <URL>http://znuny.com/</URL>
    <License>Some company's custom license</License>
    <Description Lang="en">This package contains no functionality, it's just a playground.</Description>
    <Description Lang="de">Dieses Paket enthält keine Funktionalität, es ist nur ein Spielplatz.</Description>
    <Filelist>
        <File Permission="660" Location="Kernel/Config/Files/XML/ZnunyPlayground.xml"/>
        <File Permission="660" Location="Kernel/Language/de_ZnunyPlayground.pm"/>
        <File Permission="660" Location="Kernel/Modules/AgentTicketPlayground.pm"/>
        <File Permission="660" Location="Kernel/Output/HTML/OutputFilterZnunyPlayground.pm"/>
    </Filelist>
    <PackageMerge Name="Znuny-Playground" TargetVersion="6.0.5"></PackageMerge>
</otrs_package>
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
