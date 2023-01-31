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
        Name     => 'Minimal valid SOPM.',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::XSDValidator)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
</otrs_package>
EOF
    },
    {
        Name     => 'Simple PackageMerge',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::XSDValidator)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0"></PackageMerge>
</otrs_package>
EOF
    },
    {
        Name     => 'PackageMerge without TargetVersion',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::XSDValidator)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne"></PackageMerge>
</otrs_package>
EOF
        ExpectedMessageSubstring => "Element 'PackageMerge': The attribute 'TargetVersion' is required but missing",
    },
    {
        Name     => 'PackageMerge without Name',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::XSDValidator)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge TargetVersion="2.0.0"></PackageMerge>
</otrs_package>
EOF
        ExpectedMessageSubstring => "Element 'PackageMerge': The attribute 'Name' is required but missing",
    },
    {
        Name     => 'PackageMerge with DatabaseUpgrade',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::XSDValidator)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <DatabaseUpgrade Type="post">
        <TableCreate Name="merge_package">
            <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
            <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
        </TableCreate>
    </DatabaseUpgrade>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
      <DatabaseUpgrade Type="merge" IfPackage="OtherPackage" IfNotPackage="OtherPackage2">
          <TableCreate Name="merge_package">
              <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
              <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseUpgrade>
    </PackageMerge>
</otrs_package>
EOF
    },
    {
        Name     => 'PackageMerge with invalid CodeInstall',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SOPM::XSDValidator)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>OTRS AG</Vendor>
    <URL>https://otrs.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
      <DatabaseInstall Type="merge">
          <TableCreate Name="merge_package">
              <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
              <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseInstall>
    </PackageMerge>
</otrs_package>
EOF
        ExpectedMessageSubstring => "Element 'DatabaseInstall': This element is not expected.",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
