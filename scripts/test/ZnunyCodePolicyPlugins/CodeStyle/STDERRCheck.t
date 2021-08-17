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
        Name      => "4.0 - Don't forget to remove debug code like `print STDERR (...)",
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Framework => '4.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n";
EOF
        Exception => 0,
    },
    {
        Name      => "5.0 - Don't forget to remove debug code like `print STDERR (...)",
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Framework => '5.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n";
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - Don't forget to remove debug code like `print STDERR (...)",
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n";
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - print STDERR (...) as comment",
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
# print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n";
EOF
        Exception => 0,
        Result =>
            '# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
# print STDERR \'Debug Dump - ModuleName - VariableName = \' . Dumper(\VariableName) . "\n";
',
    },
    {
        Name      => "6.0 - print STDERR (...) with print STDERR comment at end of line",
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
print STDERR 'Debug Dump - ModuleName - VariableName = ' . Dumper(\VariableName) . "\n"; # and a comment with print STDERR in it
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - code with print STDERR (...) as comment at end of line",
        Filename  => 'Znuny.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
my $Test = 2; # and a comment with print STDERR in it
EOF
        Exception => 0,
        Result =>
            '# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
use Data::Dumper;
my $Test = 2; # and a comment with print STDERR in it
',
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
