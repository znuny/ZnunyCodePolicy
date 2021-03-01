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

my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );
$Year += 1900;

$TidyAll::Znuny::ChangedFiles = [
    'Kernel/System/Coffee.pm',
];

my @Tests = (
    {
        Name      => "6.0 - Changed nothing in copyright!",
        Filename  => 'Kernel/System/CoffeeNotChanged.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::ReplaceOTRSCopyright)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::CoffeeNotChanged;
EOF
        Result    => <<"EOF",
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::CoffeeNotChanged;
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - Changed year in copyright!",
        Filename  => 'Kernel/System/Coffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::ReplaceOTRSCopyright)],
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
        Result    => <<"EOF",
# --
# Copyright (C) 2001-$Year OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        Exception => 0,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
