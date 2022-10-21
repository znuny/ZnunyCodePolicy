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
        Name     => 'Remove debug code',
        Filename => 'Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n";
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Remove debug code',
    },
    {
        Name     => "print STDERR (...) as comment",
        Filename => 'Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
# print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n";
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => "print STDERR (...) with print STDERR comment at end of line",
        Filename => 'Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n"; # and a comment with print STDERR in it
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Remove debug code',
    },
    {
        Name     => "print STDERR (...) as comment at end of line",
        Filename => 'Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
my $Test = 2; # and a comment with print STDERR in it
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
