# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (RequireExplicitPackage)
## nofilter(TidyAll::Plugin::Znuny::Perl::UUID)
## nofilter(TidyAll::Plugin::Znuny::Perl::ObjectManagerDirectCall)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'UUID - valid usage with Util::CreateUUID',
        Filename => 'Kernel/System/Valid.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
# Good: Using the recommended Util::CreateUUID method
my $UUID = $Kernel::OM->Get('Kernel::System::Util')->CreateUUID();

my $AnotherUUID = $UtilObject->CreateUUID();

# This should be fine
my $SomeVariable = 'not-uuid-related';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'UUID - invalid usage with Data::UUID->new()->create_str()',
        Filename => 'Kernel/System/Invalid.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
use Data::UUID;

my $UUID = Data::UUID->new()->create_str();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found direct usage of Data::UUID methods',
    },
    {
        Name     => 'UUID - invalid usage with use Data::UUID',
        Filename => 'Kernel/System/Invalid.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
use Data::UUID;

my $UUIDObject = Data::UUID->new();
my $UUID = $UUIDObject->create_str();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Please use Util::CreateUUIDString()',
    },
    {
        Name     => 'UUID - invalid usage with object->create_str()',
        Filename => 'Kernel/System/Invalid.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
my $UUIDObject = Data::UUID->new();
my $UUID = $UUIDObject->create_str();
my $AnotherUUID = $SomeUUIDGenerator->create_str();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found direct usage of Data::UUID methods',
    },
    {
        Name     => 'UUID - invalid usage with Data::UUID::create_str',
        Filename => 'Kernel/System/Invalid.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
my $UUID = Data::UUID::create_str();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found direct usage of Data::UUID methods',
    },
    {
        Name     => 'UUID - comments should be ignored',
        Filename => 'Kernel/System/Comments.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
# This is just a comment about Data::UUID->new()->create_str()
# Another comment with ->create_str()

my $ValidCode = 'something else';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'UUID - multiple violations in one file',
        Filename => 'Kernel/System/Multiple.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UUID)],
        Source   => <<'EOF',
use Data::UUID;

my $UUID1 = Data::UUID->new()->create_str();
my $UUID2 = $UUIDObject->create_str();
my $UUID3 = Data::UUID::create_str();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Line 1:',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
