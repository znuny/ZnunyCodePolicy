# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep legacy session names below Znuny 7.5',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
my $SessionID = $ParamObject->GetCookie( Key => 'OTRSAgentInterface' );
EOF
        ExpectedSource => <<'EOF',
my $SessionID = $ParamObject->GetCookie( Key => 'OTRSAgentInterface' );
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename agent and customer session names in Perl',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
my $AgentSessionID    = $ParamObject->GetCookie( Key => 'OTRSAgentInterface' );
my $CustomerSessionID = $ParamObject->GetCookie( Key => "OTRSCustomerInterface" );
EOF
        ExpectedSource => <<'EOF',
my $AgentSessionID    = $ParamObject->GetCookie( Key => 'ZnunyAgentInterface' );
my $CustomerSessionID = $ParamObject->GetCookie( Key => "ZnunyCustomerInterface" );
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename session name in Selenium test URL',
        Filename => 'scripts/test/Selenium/Agent/Example.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
$Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTest;OTRSAgentInterface=$SessionID");
EOF
        ExpectedSource => <<'EOF',
$Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AgentTest;ZnunyAgentInterface=$SessionID");
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename session name in JavaScript',
        Filename => 'var/httpd/htdocs/js/Core.Agent.Example.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
var URL = 'index.pl?Action=AgentTest;OTRSAgentInterface=' + SessionID;
EOF
        ExpectedSource => <<'EOF',
var URL = 'index.pl?Action=AgentTest;ZnunyAgentInterface=' + SessionID;
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename session name in config',
        Filename => 'Kernel/Config.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
$Self->{SessionName}              = 'OTRSAgentInterface';
$Self->{CustomerPanelSessionName} = 'OTRSCustomerInterface';
EOF
        ExpectedSource => <<'EOF',
$Self->{SessionName}              = 'ZnunyAgentInterface';
$Self->{CustomerPanelSessionName} = 'ZnunyCustomerInterface';
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Keep names that only contain the legacy name',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSSessionName)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
my $MyOTRSAgentInterfaceName = 'OTRSAgentInterfaceLegacy';
EOF
        ExpectedSource => <<'EOF',
my $MyOTRSAgentInterfaceName = 'OTRSAgentInterfaceLegacy';
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
