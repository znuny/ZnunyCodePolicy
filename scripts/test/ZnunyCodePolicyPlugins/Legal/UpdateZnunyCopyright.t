# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::OTRS::Common::CustomizationMarkers)

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::ZnunyCodePolicyPlugins;

use TidyAll::Znuny;
use TidyAll::Plugin::Znuny::Base;

my $ZnunyCopyrightString = TidyAll::Plugin::Znuny::Base::GetZnunyCopyrightString();

my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );
$Year += 1900;

$TidyAll::Znuny::ChangedFiles = [
    'Kernel/System/Coffee.pm',
];

my @Tests = (
    {
        Name      => "6.0 - Found OTRS copyright in unchanged file!",
        Filename  => 'Kernel/System/UNCHANGEDCoffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::UNCHANGEDCoffee;
EOF
        Result => <<"EOF",
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# $ZnunyCopyrightString
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::UNCHANGEDCoffee;
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - Found OTRS copyright in changed file!",
        Filename  => 'Kernel/System/Coffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Coffee;
EOF
        Result => <<"EOF",
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# $ZnunyCopyrightString
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Coffee;
EOF
        Exception => 0,
    },
    {
        Name      => "6.0 - Found no OTRS copyright!",
        Filename  => 'Kernel/System/Coffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        Exception => 1,
    },
    {
        Name      => "6.0 - Found Znuny copyright!",
        Filename  => 'Kernel/System/Coffee.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Framework => '6.0',
        Source    => <<'EOF',
# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        Result => <<"EOF",
# --
# $ZnunyCopyrightString
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
