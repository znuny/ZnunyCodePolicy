# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'No HTMLUtils DocumentComplete call',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::HTMLUtils)],
        Source   => <<'EOF',
    my $HTMLContent = $HTMLUtilsObject->ToAscii(
        String   => $String,  # required
        Charset  => $Charset, # required
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Direct HTMLUtils DocumentComplete call',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::HTMLUtils)],
        Source   => <<'EOF',
    my $CompleteHTML = $HTMLUtilsObject->DocumentComplete(
        String   => $String,  # required
        Charset  => $Charset, # required
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found calls to Kernel::System::HTMLUtils::DocumentComplete',
    },
    {
        Name     => 'Kernel::System::HTMLUtils DocumentComplete call',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::HTMLUtils)],
        Source   => <<'EOF',
    my $CompleteHTML = Kernel::System::HTMLUtils->DocumentComplete(
        String   => $String,  # required
        Charset  => $Charset, # required
    );
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'This function requires the \'UserType\' parameter',
    },
    {
        Name     => 'DocumentComplete in comment (should be ignored)',
        Filename => 'Kernel/System/Example.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::HTMLUtils)],
        Source   => <<'EOF',
    # This calls DocumentComplete function
    # $HTMLUtilsObject->DocumentComplete();
    my $Other = $HTMLUtilsObject->ToAscii();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
