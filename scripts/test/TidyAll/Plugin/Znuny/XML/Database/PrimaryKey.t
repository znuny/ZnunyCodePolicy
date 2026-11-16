# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Framework 7.0, table without primary key',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.0',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="calendar_appointment_ticket">
        <Column Name="calendar_id" Required="true" Type="BIGINT"/>
        <Column Name="ticket_id" Required="true" Type="BIGINT"/>
        <Unique Name="calendar_appointment_ticket_ids">
            <UniqueColumn Name="calendar_id"/>
            <UniqueColumn Name="ticket_id"/>
        </Unique>
    </TableCreate>
</DatabaseInstall>
EOF
    },
    {
        Name     => 'Framework 7.1, column with primary key',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="calendar_appointment_ticket">
        <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="BIGINT"/>
        <Column Name="calendar_id" Required="true" Type="BIGINT"/>
        <Column Name="ticket_id" Required="true" Type="BIGINT"/>
    </TableCreate>
</DatabaseInstall>
EOF
    },
    {
        Name     => 'Framework 7.1, unique index is not a primary key',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="calendar_appointment_ticket">
        <Column Name="calendar_id" Required="true" Type="BIGINT"/>
        <Column Name="ticket_id" Required="true" Type="BIGINT"/>
        <Unique Name="calendar_appointment_ticket_ids">
            <UniqueColumn Name="calendar_id"/>
            <UniqueColumn Name="ticket_id"/>
        </Unique>
    </TableCreate>
</DatabaseInstall>
EOF
        ExpectedMessageSubstring => "Line 2, table 'calendar_appointment_ticket': no column with PrimaryKey=\"true\".",
    },
    {
        Name     => 'Framework 7.5, PrimaryKey false does not count',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="article_note">
        <Column Name="id" Required="true" PrimaryKey="false" AutoIncrement="true" Type="BIGINT"/>
        <Column Name="note" Required="true" Size="200" Type="VARCHAR"/>
    </TableCreate>
</DatabaseInstall>
EOF
        ExpectedMessageSubstring => "table 'article_note': no column with PrimaryKey=\"true\".",
    },
    {
        Name     => 'Framework 7.5, primary key on a business column',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="article_note">
        <Column Name="article_id" Required="true" Type="BIGINT"/>
        <Column Name="note_key" Required="true" Size="50" Type="VARCHAR" PrimaryKey="true"/>
    </TableCreate>
</DatabaseInstall>
EOF
    },
    {
        Name     => 'Framework 7.5, primary key on a following line',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate
        Name="article_note">
        <Column
            Name="id"
            Required="true"
            PrimaryKey="true"
            AutoIncrement="true"
            Type="BIGINT"/>
    </TableCreate>
</DatabaseInstall>
EOF
    },
    {
        Name     => 'Framework 7.5, only the table without a primary key is reported',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="article_note">
        <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="BIGINT"/>
    </TableCreate>
    <TableCreate Name="article_flag">
        <Column Name="article_id" Required="true" Type="BIGINT"/>
        <Column Name="article_key" Required="true" Size="50" Type="VARCHAR"/>
    </TableCreate>
</DatabaseInstall>
EOF
        ExpectedMessageSubstring => "table 'article_flag': no column with PrimaryKey=\"true\".",
    },
    {
        Name     => 'Framework 7.5, DatabaseUpgrade TableCreate',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
<DatabaseUpgrade>
    <TableCreate Name="pm_process_preferences" Version="2.0.0">
        <Column Name="process_entity_id" Required="true" Size="50" Type="VARCHAR"/>
        <Column Name="preferences_key" Required="true" Size="150" Type="VARCHAR"/>
    </TableCreate>
</DatabaseUpgrade>
EOF
        ExpectedMessageSubstring => "table 'pm_process_preferences': no column with PrimaryKey=\"true\".",
    },
    {
        Name     => 'Framework 7.5, comment does not count as primary key',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
<DatabaseInstall>
    <TableCreate Name="article_note">
        <!-- <Column Name="id" PrimaryKey="true" Type="BIGINT"/> -->
        <Column Name="note" Required="true" Size="200" Type="VARCHAR"/>
    </TableCreate>
</DatabaseInstall>
EOF
        ExpectedMessageSubstring => "table 'article_note': no column with PrimaryKey=\"true\".",
    },
    {
        Name     => 'nofilter disables the plugin',
        Filename => 'TestPackage.sopm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)],
        Settings => {
            'Framework::Version' => '7.5',
        },
        Source => <<"EOF",
## nofilter(TidyAll::Plugin::Znuny::XML::Database::PrimaryKey)
<DatabaseInstall>
    <TableCreate Name="article_note">
        <Column Name="note" Required="true" Size="200" Type="VARCHAR"/>
    </TableCreate>
</DatabaseInstall>
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
