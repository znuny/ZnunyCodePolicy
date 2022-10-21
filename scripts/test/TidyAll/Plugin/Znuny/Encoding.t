# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright)
## nofilter(TidyAll::Plugin::Znuny::Common::TidyAll::Plugin::Znuny::Common::CustomizationMarkers)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

#
# This checks that TidyAll does not change the encoding of text within code.
#

use scripts::test::TidyAll::Plugin::Znuny;
my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );
$Year += 1900;

my $ZnunyCopyrightString = "Copyright (C) 2021-$Year Znuny GmbH, https://znuny.org/";

my @Tests = (
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

use utf8;

print "This is some text with öäÜÖÄÜ€\n";
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

use utf8;

print "This is some text with öäÜÖÄÜ€\\n";
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
