# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
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

use scripts::test::ZnunyCodePolicyPlugins;

my @Tests = (
    {
        Name      => '5.0 - Found frontend module registration but no ACLKeysLevel3::Actions registration',
        Filename  => 'Kernel/Config/Files/Coffee.xml',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Config::ACLKeysLevel3Actions)],
        Framework => '5.0',
        Source    => <<'EOF',
    <ConfigItem Name="Frontend::Module###ModuleName" Required="0" Valid="1">
        <Description Translatable="1">Convert Module Registration with NavBar and Loader.</Description>
        <Group>TestGroup</Group>
        <SubGroup>SubGroup</SubGroup>

EOF
        Exception => 0,
        STDOUT    => "[notice] for the next file:
TidyAll::Plugin::Znuny::Config::ACLKeysLevel3Actions

NOTICE: ACLKeysLevel3Actions - Found frontend module registration but no ACLKeysLevel3::Actions registration for the following.
Maybe you wanna do this with yeahman.
\tLine 1:     <ConfigItem Name=\"Frontend::Module###ModuleName\" Required=\"0\" Valid=\"1\">

",
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
