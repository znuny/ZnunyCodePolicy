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

my $SettingTemplate = <<'EOF';
        <Description Translatable="1">Test config setting definition for purposes of the unit testing.</Description>
        <Value>
            <Hash>
                <Item Key="Key">Value</Item>
            </Hash>
        </Value>
EOF

my @Tests = (
    {
        Name     => 'Top level entry - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Stats::StatsHook" Required="1" Valid="1">
        <Navigation>Core::Stats</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Top level entry - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Stats::StatsHook" Required="1" Valid="1">
        <Navigation>Stats::Core</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Event handler entry - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Package::EventModulePost###9000-SupportDataSend" Required="1" Valid="1">
        <Navigation>Core::Event::Package</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Event handler entry - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Package::EventModulePost###9000-SupportDataSend" Required="1" Valid="1">
        <Navigation>Package::Core::Events</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Valid frontend subgroup',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::NotifyModule###9-CustomerNotificationModule" Required="1" Valid="1">
        <Navigation>Frontend::Customer::FrontendNotification</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Frontend subgroup - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::NotifyModule###9-CustomerNotificationModule" Required="1" Valid="1">
        <Navigation>Frontend::Customer::FrontendNotification</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Main loader entry - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Agent::CommonCSS###000-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Main loader entry - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Agent::CommonCSS###000-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Agent::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Loader config for Admin interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AdminSystemConfiguration###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Loader config for Admin interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AdminSystemConfiguration###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Loader config for Agent interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AgentDashboard###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Agent::ModuleRegistration::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Loader config for Agent interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AgentDashboard###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Loader config for Customer interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
        <Navigation>Frontend::Customer::ModuleRegistration::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Loader config for Customer interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Loader config for Public interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::PublicFAQExplorer###002-FAQ" Required="1" Valid="1">
        <Navigation>Frontend::Public::ModuleRegistration</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Loader config for Customer interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::PublicFAQExplorer###002-FAQ" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Frontend navigation config for Admin interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Admin###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Frontend navigation config for Admin interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Admin###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Frontend navigation config for Agent interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Agent###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Agent::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Frontend navigation config for Agent interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Agent###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Frontend navigation config for Customer interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::Navigation###Customer###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Customer::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Frontend navigation config for Customer interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::Navigation###Customer###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Frontend navigation config for Public interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Navigation###Public###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Public::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Frontend navigation config for Public interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Navigation###Public###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Navigation module config - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::NavigationModule###Admin" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::AdminOverview</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Navigation module config - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::NavigationModule###Admin" Required="1" Valid="1">
        <Navigation>Frontend::Admin</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Search router config for Admin interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AdminSystemConfiguration" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::MainMenu::Search</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Search router config for Admin interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AdminSystemConfiguration" Required="1" Valid="1">
        <Navigation>Frontend::Admin</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Search router config for Agent interface - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AgentCustomerInformationCenter" Required="1" Valid="1">
        <Navigation>Frontend::Agent::ModuleRegistration::MainMenu::Search</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Search router config for Agent interface - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AgentCustomerInformationCenter" Required="1" Valid="1">
        <Navigation>Frontend::Agent</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Output filters - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Output::FilterText###AAAURL" Required="1" Valid="1">
        <Navigation>Frontend::Base::OutputFilter</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Output filters - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Frontend::Output::FilterText###AAAURL" Required="1" Valid="1">
        <Navigation>Frontend::Base</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Frontend views - Valid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Ticket::Frontend::ZoomRichTextForce" Required="1" Valid="1">
        <Navigation>Frontend::Agent::View::TicketZoom</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'Frontend views - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Ticket::Frontend::ZoomRichTextForce" Required="1" Valid="1">
        <Navigation>Frontend::Agent::TicketZoom::View::RichText</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
    {
        Name     => 'Frontend views (OTRS 7+) - Invalid',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::Navigation)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="Ticket::Frontend::CustomerTicketMessage###DynamicField" Required="1" Valid="1">
        <Navigation>Frontend::Customer::Ticket::View::Message</Navigation>
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'Problems were found in the navigation structure of the XML configuration',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
