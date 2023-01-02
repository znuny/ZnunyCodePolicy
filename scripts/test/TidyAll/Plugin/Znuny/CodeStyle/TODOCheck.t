# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)
## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'No TODO found',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'TODO',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# todo
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Pay attention to tasks that may not have been completed',
    },
    {
        Name     => 'TODOs',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# todos
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Pay attention to tasks that may not have been completed',
    },
    {
        Name     => 'Some text containing "todo" but is not "todo" or "todos"',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Source   => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# this_is_no_todo
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
