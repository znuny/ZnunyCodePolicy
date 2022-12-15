# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Common::CustomizationMarkers)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => "Use of JavaScriptStrings",
        Filename => 'Kernel/Language/de_Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Translation::JavaScriptStrings)],
        Source   => <<'EOF',
# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_Znuny;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    $Self->{JavaScriptStrings} = [
        'test'
    ];

    return 1;
}
1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'make sure that the original values are not overwritten',
    },
    {
        Name     => "No use of JavaScriptStrings",
        Filename => 'Kernel/Language/de_Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Translation::JavaScriptStrings)],
        Source   => <<'EOF',
# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_Znuny;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Test'} = 'Test2';

    return 1;
}
1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
