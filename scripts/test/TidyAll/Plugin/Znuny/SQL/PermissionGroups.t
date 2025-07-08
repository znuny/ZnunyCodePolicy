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
        Name     => 'PermissionGroups, IsPluginDisabled true',
        Filename => 'ZnunyCodePolicy.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SQL::PermissionGroups)],
        Source   => <<'EOF',
<!-- nofilter(TidyAll::Plugin::Znuny::SQL::PermissionGroups) -->
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ZnunyCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>6.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">Znuny code policy checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/znuny.CodePolicy.pl"/>
    </Filelist>
    <DatabaseInstall Type="post">
        <TableCreate Name="test">
            <Column AutoIncrement="true" Name="id" PrimaryKey="true" Required="true" Type="BIGINT"/>
            <Column Name="name" Required="true" Size="200" Type="VARCHAR"/>
            <Column Name="group_id" Required="true" Type="INTEGER"/>
            <Column Name="comments" Required="false" Size="250" Type="VARCHAR"/>
            <Column Name="valid_id" Required="true" Type="SMALLINT"/>
            <Column Name="create_time" Required="true" Type="DATE"/>
            <Column Name="create_by" Required="true" Type="INTEGER"/>
            <Column Name="change_time" Required="true" Type="DATE"/>
            <Column Name="change_by" Required="true" Type="INTEGER"/>
            <ForeignKey ForeignTable="valid">
                <Reference Foreign="id" Local="valid_id">
                </Reference>
            </ForeignKey>
            <ForeignKey ForeignTable="groups">
                <Reference Foreign="id" Local="group_id">
                </Reference>
            </ForeignKey>
            <ForeignKey ForeignTable="users">
                <Reference Foreign="id" Local="create_by">
                </Reference>
                <Reference Foreign="id" Local="change_by">
                </Reference>
            </ForeignKey>
        </TableCreate>
    </DatabaseInstall>
</otrs_package>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'PermissionGroups, valid',
        Filename => 'ZnunyCodePolicy.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SQL::PermissionGroups)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ZnunyCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>6.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">Znuny code policy checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/znuny.CodePolicy.pl"/>
    </Filelist>
    <DatabaseInstall Type="post">
        <TableCreate Name="test">
            <Column AutoIncrement="true" Name="id" PrimaryKey="true" Required="true" Type="BIGINT"/>
            <Column Name="name" Required="true" Size="200" Type="VARCHAR"/>
            <Column Name="group_id" Required="true" Type="INTEGER"/>
            <Column Name="comments" Required="false" Size="250" Type="VARCHAR"/>
            <Column Name="valid_id" Required="true" Type="SMALLINT"/>
            <Column Name="create_time" Required="true" Type="DATE"/>
            <Column Name="create_by" Required="true" Type="INTEGER"/>
            <Column Name="change_time" Required="true" Type="DATE"/>
            <Column Name="change_by" Required="true" Type="INTEGER"/>
            <ForeignKey ForeignTable="valid">
                <Reference Foreign="id" Local="valid_id">
                </Reference>
            </ForeignKey>
            <ForeignKey ForeignTable="permission_groups">
                <Reference Foreign="id" Local="group_id">
                </Reference>
            </ForeignKey>
            <ForeignKey ForeignTable="users">
                <Reference Foreign="id" Local="create_by">
                </Reference>
                <Reference Foreign="id" Local="change_by">
                </Reference>
            </ForeignKey>
        </TableCreate>
    </DatabaseInstall>
</otrs_package>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'PermissionGroups, invalid',
        Filename => 'ZnunyCodePolicy.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::SQL::PermissionGroups)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ZnunyCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>6.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU AFFERO GENERAL PUBLIC LICENSE Version 3, November 2007</License>
    <Description Lang="en">Znuny code policy checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/znuny.CodePolicy.pl"/>
    </Filelist>
    <DatabaseInstall Type="post">
        <TableCreate Name="test">
            <Column AutoIncrement="true" Name="id" PrimaryKey="true" Required="true" Type="BIGINT"/>
            <Column Name="name" Required="true" Size="200" Type="VARCHAR"/>
            <Column Name="group_id" Required="true" Type="INTEGER"/>
            <Column Name="comments" Required="false" Size="250" Type="VARCHAR"/>
            <Column Name="valid_id" Required="true" Type="SMALLINT"/>
            <Column Name="create_time" Required="true" Type="DATE"/>
            <Column Name="create_by" Required="true" Type="INTEGER"/>
            <Column Name="change_time" Required="true" Type="DATE"/>
            <Column Name="change_by" Required="true" Type="INTEGER"/>
            <ForeignKey ForeignTable="valid">
                <Reference Foreign="id" Local="valid_id">
                </Reference>
            </ForeignKey>
            <ForeignKey ForeignTable="groups">
                <Reference Foreign="id" Local="group_id">
                </Reference>
            </ForeignKey>
            <ForeignKey ForeignTable="users">
                <Reference Foreign="id" Local="create_by">
                </Reference>
                <Reference Foreign="id" Local="change_by">
                </Reference>
            </ForeignKey>
        </TableCreate>
    </DatabaseInstall>
</otrs_package>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Using table \'groups\' as ForeignTable is no longer supported since 6.1.1.',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
