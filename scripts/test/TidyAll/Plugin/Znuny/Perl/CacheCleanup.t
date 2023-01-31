# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Perl::ObjectManagerDirectCall)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Kernel::System::Cache::CleanUp() must be called with arguments",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::CacheCleanup)],
        Source   => <<'EOF',
$CacheObject->CleanUp();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Kernel::System::Cache::CleanUp() must be called with arguments',
    },
    {
        Name     => "Kernel::System::Cache::CleanUp() must be called with arguments",
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::CacheCleanup)],
        Source   => <<'EOF',
$Kernel::OM->Get('Kernel::System::Cache')->CleanUp();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Kernel::System::Cache::CleanUp() must be called with arguments',
    },

);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
