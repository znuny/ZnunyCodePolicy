# --
# Copyright (C) 2012-2026 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Framework audit columns',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
<Table Name="article_note">
    <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
    <Column Name="create_time" Required="true" Type="DATE"/>
    <Column Name="create_by" Required="true" Type="INTEGER"/>
    <Column Name="change_time" Required="true" Type="DATE"/>
    <Column Name="change_by" Required="true" Type="INTEGER"/>
</Table>
EOF
    },
    {
        Name     => 'created and changed column names',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
<Table Name="article_note">
    <Column Name="created" Required="true" Type="DATE"/>
    <Column Name="created_by" Required="true" Type="INTEGER"/>
    <Column Name="changed" Required="true" Type="DATE"/>
    <Column Name="changed_by" Required="true" Type="INTEGER"/>
</Table>
EOF
        ExpectedMessageSubstring => [
            "column 'created'. Use 'create_time'.",
            "column 'created_by'. Use 'create_by'.",
            "column 'changed'. Use 'change_time'.",
            "column 'changed_by'. Use 'change_by'.",
        ],
    },
    {
        Name     => 'ColumnAdd with created',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
<TableAlter Name="article_note">
    <ColumnAdd Name="created" Required="true" Type="DATE"/>
</TableAlter>
EOF
        ExpectedMessageSubstring => "table 'article_note': column 'created'. Use 'create_time'.",
    },
    {
        Name     => 'ColumnChange NameNew created',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
<TableAlter Name="article_note">
    <ColumnChange NameOld="create_time" NameNew="created" Type="DATE"/>
</TableAlter>
EOF
        ExpectedMessageSubstring => "column 'created'. Use 'create_time'.",
    },
    {
        Name     => 'ColumnChange away from created',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
<TableAlter Name="article_note">
    <ColumnChange NameOld="created" NameNew="create_time" Type="DATE"/>
    <ColumnDrop Name="changed"/>
</TableAlter>
EOF
    },
    {
        Name     => 'Similar column name created_time',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
<Table Name="article_note">
    <Column Name="created_time" Required="true" Type="DATE"/>
</Table>
EOF
    },
    {
        Name     => 'nofilter disables the plugin',
        Filename => 'schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)],
        Source   => <<"EOF",
## nofilter(TidyAll::Plugin::Znuny::XML::Database::AuditColumns)
<Table Name="article_note">
    <Column Name="created" Required="true" Type="DATE"/>
</Table>
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
