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
        Name     => 'Daemon setting with deprecated Kernel::System::Cache module',
        Filename => 'Kernel/Config/Files/XML/MyPackage.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::DaemonModuleCheck)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_config version="2.0" init="Application">
    <Setting Name="Daemon::SchedulerCronTaskManager::Task###CoreCacheCleanup" Required="0" Valid="1" ConfigLevel="100">
        <Description Translatable="1">Delete expired cache from core modules.</Description>
        <Navigation>Daemon::SchedulerCronTaskManager::Task</Navigation>
        <Value>
            <Hash>
                <Item Key="Module">Kernel::System::Cache</Item>
            </Hash>
        </Value>
    </Setting>
</otrs_config>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated module usage',
    },
    {
        Name     => 'Daemon setting with correct console command module',
        Filename => 'Kernel/Config/Files/XML/MyPackage.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::DaemonModuleCheck)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_config version="2.0" init="Application">
    <Setting Name="Daemon::SchedulerCronTaskManager::Task###ValidTask" Required="0" Valid="1" ConfigLevel="100">
        <Description Translatable="1">Valid console command task.</Description>
        <Navigation>Daemon::SchedulerCronTaskManager::Task</Navigation>
        <Value>
            <Hash>
                <Item Key="Module">Kernel::System::Console::Command::Maint::Cache::Delete</Item>
            </Hash>
        </Value>
    </Setting>
</otrs_config>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Non-daemon setting with Kernel::System::Cache (should be ignored)',
        Filename => 'Kernel/Config/Files/XML/MyPackage.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::DaemonModuleCheck)],
        Source   => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_config version="2.0" init="Application">
    <Setting Name="Some::Other::Setting" Required="0" Valid="1" ConfigLevel="100">
        <Description Translatable="1">This should be ignored.</Description>
        <Navigation>Some::Other::Setting</Navigation>
        <Value>
            <Hash>
                <Item Key="Module">Kernel::System::Cache</Item>
            </Hash>
        </Value>
    </Setting>
</otrs_config>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework context (should be ignored)',
        Filename => 'Kernel/Config/Files/XML/Framework.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::DaemonModuleCheck)],
        Settings => {
            'Context::Framework' => 'Framework',
        },
        Source => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_config version="2.0" init="Application">
    <Setting Name="Daemon::SchedulerCronTaskManager::Task###CoreCacheCleanup" Required="0" Valid="1" ConfigLevel="100">
        <Description Translatable="1">Delete expired cache from core modules.</Description>
        <Navigation>Daemon::SchedulerCronTaskManager::Task</Navigation>
        <Value>
            <Hash>
                <Item Key="Module">Kernel::System::Cache</Item>
            </Hash>
        </Value>
    </Setting>
</otrs_config>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
