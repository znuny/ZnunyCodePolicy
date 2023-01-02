# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)
## nofilter(TidyAll::Plugin::Znuny::Common::TidyAll::Plugin::Znuny::Common::CustomizationMarkers)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

use TidyAll::Znuny;

my $ZnunyCopyrightString = "Copyright (C) 2021 Znuny GmbH, https://znuny.org/";

my @Tests = (
    {
        Name     => "Found OTRS copyright in unchanged file",
        Filename => 'Kernel/System/UNCHANGEDCoffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Source   => <<'EOF',
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::UNCHANGEDCoffee;
EOF
        ExpectedSource => <<"EOF",
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
        Name     => "Found OTRS copyright in changed file",
        Filename => 'Kernel/System/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Source   => <<'EOF',
# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::Coffee;
EOF
        ExpectedSource => <<"EOF",
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
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => "Found no OTRS copyright",
        Filename => 'Kernel/System/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Source   => <<'EOF',
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        ExpectedMessageSubstring => 'File is missing copyright in header section',
    },
    {
        Name     => "Found Znuny copyright",
        Filename => 'Kernel/System/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)],
        Source   => <<'EOF',
# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        ExpectedSource => <<"EOF",
# --
# $ZnunyCopyrightString
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Coffee;
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
