# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'alert() is not given',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::AlertFunction)],
        Source   => <<'EOF',
// no content
EOF
    },
    {
        Name     => 'alert() is given',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::AlertFunction)],
        Source   => <<'EOF',
alert('Debug');
EOF
        ExpectedMessageSubstring => "Found alert() in line 1: alert('Debug');
        Use Core.UI.Dialog.ShowAlert('<Insert your alert title here>', 'Debug') instead of alert().",
    },
    {
        Name     => 'alert() is given',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::AlertFunction)],
        Source   => <<'EOF',
console.log('Hi'); alert('Debug'); console.log('Hi');
EOF
        ExpectedMessageSubstring => "Found alert() in line 1: console.log('Hi'); alert('Debug'); console.log('Hi');
        Use Core.UI.Dialog.ShowAlert('<Insert your alert title here>', 'Debug') instead of alert().",
    },
    {
        Name     => 'alert() is not given',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::AlertFunction)],
        Source   => <<'EOF',
// no content
thisisnoalert('Test');
EOF
    },
    {
        Name     => 'alert() is not given',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::AlertFunction)],
        Source   => <<'EOF',
// no content
// alert('Test');
EOF
    },
    {
        Name     => 'alert() is not given',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::AlertFunction)],
        Source   => <<'EOF',
// no content
/* alert('Test');
...
*/
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
