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

my $SmallName    = 'A';
my $MediumName   = 'A' x 100;
my $LongName     = 'A' x 200;
my $LimitName    = 'A' x 250;
my $OversizeName = 'A' x 251;
my $HugeName     = 'A' x 300;

my $SettingTemplate = <<'EOF';
        <Description Translatable="1">Disables the web installer (http://yourhost.example.com/otrs/installer.pl), to prevent the system from being hijacked. If set to "No", the system can be reinstalled and the current basic configuration will be used to pre-populate the questions within the installer script. If not active, it also disables the GenericAgent, PackageManager and SQL Box.</Description>
        <Navigation>Framework</Navigation>
        <Value>
            <Item ValueType="Select">
                <Item ValueType="Option" Key="0" Translatable="1">No</Item>
                <Item ValueType="Option" Key="1" Translatable="1">Yes</Item>
            </Item>
        </Value>
EOF

my $SettingTemplateOld = <<'EOF';
        <Description Translatable="1">Disables the web installer (http://yourhost.example.com/otrs/installer.pl), to prevent the system from being hijacked. If set to "No", the system can be reinstalled and the current basic configuration will be used to pre-populate the questions within the installer script. If not active, it also disables the GenericAgent, PackageManager and SQL Box.</Description>
        <Group>Framework</Group>
        <SubGroup>Core</SubGroup>
        <Setting>
            <Option SelectedID="0">
                <Item Key="0" Translatable="1">No</Item>
                <Item Key="1" Translatable="1">Yes</Item>
            </Option>
        </Setting>
EOF

my @Tests = (
    {
        Name     => 'Small Setting Name',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::XSDValidator)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="$SmallName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
    },
    {
        Name     => 'OverSize Setting Name',
        Filename => 'Kernel/Config/Files/XML/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::XSDValidator)],
        Source   => <<"EOF",
<otrs_config version="2.0" init="Framework">
    <Setting Name="$OversizeName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplate
    </Setting>
</otrs_config>
EOF
        ExpectedMessageSubstring => 'element Setting: Schemas validity error',
    },
    {
        Name     => 'Old config structure (OTRS 5)',
        Filename => 'Kernel/Config/Files/Test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Configuration::XSDValidator)],
        Source   => <<"EOF",
<otrs_config version="1.0" init="Framework">
    <ConfigItem Name="$SmallName" Required="1" Valid="1" ConfigLevel="200">
$SettingTemplateOld
    </ConfigItem>
</otrs_config>
EOF
        ExpectedMessageSubstring => [
            'does not exist in the correct directory Kernel/Config/Files/XML',
            'element ConfigItem: Schemas validity error',
        ],
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
