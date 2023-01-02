# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
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
        Name     => "LogObject found without ObjectDependencies",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following objects are used in the code, but not declared as dependencies',
    },
    {
        Name      => 'ObjectDependencies, no OM used.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Framework => '6.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'ObjectDependencies, undeclared dependency used (former default dependency)',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
$Kernel::OM->Get('Kernel::System::Encode');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following objects are used in the code, but not declared as dependencies',
    },
    {
        Name      => 'ObjectDependencies, default dependencies used with invalid short form in Get()',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Framework => '6.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Encode');
$Kernel::OM->Get('EncodeObject');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The following objects are used in the code, but not declared as dependencies',
            'The following objects are not longer used in the code, but declared as dependencies',
        ],
    },
    {
        Name     => 'ObjectDependencies, undeclared dependency used',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'The following objects are used in the code, but not declared as dependencies',
    },
    {
        Name     => 'ObjectDependencies, dependency declared',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        ExpectedSource => undef,
    },
    {
        Name     => 'ObjectDependencies, dependency declared, invalid short form',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
for my $Needed (qw(TicketObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The following objects are used in the code, but not declared as dependencies',
            'The following objects are not longer used in the code, but declared as dependencies',
        ],
    },
    {
        Name     => 'ObjectDependencies, undeclared dependency in loop',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
for my $Needed (qw(Kernel::System::Ticket)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The following objects are used in the code, but not declared as dependencies',
        ],
    },
    {
        Name     => 'ObjectDependencies, Get called in for loop',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
for my $Needed (qw(Kernel::System::CustomObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The following objects are used in the code, but not declared as dependencies',
        ],
    },
    {
        Name     => 'without ObjectDependencies, complex code, undeclared dependency',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::System::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( LogObject EncodeObject SessionObject MainObject TimeObject ParamObject UserObject GroupObject )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The following objects are used in the code, but not declared as dependencies',
        ],
    },
    {
        Name     => 'ObjectDependencies, complex code, undeclared dependency',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::User',
    'Kernel::System::Group',
    'Kernel::System::AuthSession',
    'Kernel::System::Web::Request',
);

$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( Kernel::System::User Kernel::System::Group )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'The following objects are not longer used in the code, but declared as dependencies',
        ],
    },
    {
        Name     => 'ObjectDependencies, object manager disabled',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
our $ObjectManagerDisabled = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        ExpectedSource => undef,
    },
    {
        Name     => 'ObjectDependencies, deprecated ObjectManagerAware flag',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::ObjectDependencies)],
        Source   => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
our $ObjectManagerAware = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => [
            'Don\'t use the deprecated flag $ObjectManagerAware',
        ],
    },

);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
