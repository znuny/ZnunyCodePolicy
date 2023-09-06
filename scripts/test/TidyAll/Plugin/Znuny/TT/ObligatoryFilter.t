# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use vars '$Self';
use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name   => 'Find unfiltered expansions',
        Source => <<'EOF',
foo [% Data.foo | html %] bar
[% Data.bar %]
[% Data.bar

| html
%]

x[% Data.bar
%]x
[% Quux.x %]
xx [% Foo.x | html %]
[% Data.bar | html %] yy
[% Data. %] yy
EOF
        ExpectedMessageSubstring => 'Found 3 unfiltered in-template tags',
        ExpectedSource           => <<'EOF',
foo [% Data.foo | html %] bar
[% Data.bar | html %]
[% Data.bar

| html
%]

x[% Data.bar
| html %]x
[% Quux.x %]
xx [% Foo.x | html %]
[% Data.bar | html %] yy
[% Data. | html %] yy
EOF
        Filename => 'Template.tt',
        Plugins  => ['TidyAll::Plugin::Znuny::TT::ObligatoryFilter'],
    },
    {
        Name     => 'Everything is fine',
        Source   => '[% Data.foo | html %]',
        Filename => 'Template.tt',
        Plugins  => ['TidyAll::Plugin::Znuny::TT::ObligatoryFilter'],
    },
    {
        Name     => 'Everything is fine',
        Source   => '[% Data.foo | html %]',
        Filename => 'Template.tt',
        Plugins  => ['TidyAll::Plugin::Znuny::TT::ObligatoryFilter'],
    },
    {
        Name                     => 'Malformed template: no filter name',
        Source                   => '[% Data.foo |%]',
        ExpectedMessageSubstring => 'Found 1 unfiltered in-template tags',
        ExpectedSource           => '[% Data.foo || html %]',                # still malformed, just differently!
        Filename                 => 'Template.tt',
        Plugins => ['TidyAll::Plugin::Znuny::TT::ObligatoryFilter'],
    },
    {
        Name     => 'Malformed template: no end tag',
        Source   => '[% Data.foo',
        Filename => 'Template.tt',
        Plugins  => ['TidyAll::Plugin::Znuny::TT::ObligatoryFilter'],
    },
);
$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
