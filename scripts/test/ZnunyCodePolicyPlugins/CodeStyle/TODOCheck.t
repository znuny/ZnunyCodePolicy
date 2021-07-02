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
        Name      => 'Found nothing.',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        Exception => 0,
        STDOUT    => "",
    },
    {
        Name      => 'Check todo.',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# todo
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        Exception => 0,
        STDOUT    => "[notice] Template.tt
TidyAll::Plugin::Znuny::CodeStyle::TODOCheck

NOTICE: Please pay attention to maybe not completed tasks:

\tLine 2: # todo


",
    },
    {
        Name      => 'Check todos.',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::Znuny::CodeStyle::TODOCheck)],
        Framework => '6.0',
        Source    => <<'EOF',
# Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
# todos
# At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
EOF
        Exception => 0,
        STDOUT    => "[notice] Template.tt
TidyAll::Plugin::Znuny::CodeStyle::TODOCheck

NOTICE: Please pay attention to maybe not completed tasks:

\tLine 2: # todos


",
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
