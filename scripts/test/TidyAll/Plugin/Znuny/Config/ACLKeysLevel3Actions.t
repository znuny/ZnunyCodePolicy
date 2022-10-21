# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Frontend module registration without ACLKeysLevel3::Actions registration',
        Filename => 'Kernel/Config/Files/Coffee.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Config::ACLKeysLevel3Actions)],
        Source   => <<'EOF',
    <Setting Name="Frontend::Module###ModuleName" Required="0" Valid="1">
        <Description Translatable="1">Convert Module Registration with NavBar and Loader.</Description>
        <Navigation>Frontend::Admin::ModuleRegistration</Navigation>
    </Setting>
EOF
        ExpectedSource => undef,
        ExpectedMessageSubstring =>
            'Found frontend module registration but no ACLKeysLevel3::Actions registration for the following',
    },
    {
        Name     => 'Frontend module registration with ACLKeysLevel3::Actions registration',
        Filename => 'Kernel/Config/Files/Coffee.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Config::ACLKeysLevel3Actions)],
        Source   => <<'EOF',
    <Setting Name="Frontend::Module###ModuleName" Required="0" Valid="1">
        <Description Translatable="1">Convert Module Registration with NavBar and Loader.</Description>
        <Navigation>Frontend::Admin::ModuleRegistration</Navigation>
    </Setting>
    <Setting Name="ACLKeysLevel3::Actions###ModuleName" Required="0" Valid="1">
        <Description Translatable="1">Convert Module Registration with NavBar and Loader.</Description>
        <Navigation>Frontend::Admin::ModuleRegistration</Navigation>
    </Setting>
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
