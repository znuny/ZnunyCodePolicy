# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
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
        Name      => "6.0 - Found valid license header!",
        Filename  => 'Kernel/System/Coffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::LicenseValidator)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - Found invalid license header!",
        Filename  => 'Kernel/System/Coffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::LicenseValidator)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Coffee;
EOF
        STDOUT    => 'TidyAll::Plugin::Znuny::Legal::LicenseValidator

No valid license header found. Remove any license text and add the following text to the header:

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

',
        Exception => 1,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
