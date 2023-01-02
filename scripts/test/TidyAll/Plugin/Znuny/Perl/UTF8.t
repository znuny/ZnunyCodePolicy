# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Missing "use utf8;"',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UTF8)],
        Source   => <<'EOF',
print 'Some perl code';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Check if file has UTF-8 encoding',
    },
    {
        Name     => 'Missing "use utf8;"',
        Filename => 'bin/test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UTF8)],
        Source   => <<'EOF',
print 'Some perl code';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Check if file has UTF-8 encoding',
    },
    {
        Name     => 'Missing "use utf8;"',
        Filename => 'scripts/test/Test/Test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UTF8)],
        Source   => <<'EOF',
print 'Some perl code';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Check if file has UTF-8 encoding',
    },
    {
        Name     => 'Contains "use utf8;"',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UTF8)],
        Source   => <<'EOF',
use utf8;
print 'Some perl code';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Contains "use utf8;"',
        Filename => 'bin/test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UTF8)],
        Source   => <<'EOF',
        use utf8;
print 'Some perl code';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Contains "use utf8;"',
        Filename => 'scripts/test/Test/Test.t',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::UTF8)],
        Source   => <<'EOF',
        use   utf8   ;
print 'Some perl code';
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
