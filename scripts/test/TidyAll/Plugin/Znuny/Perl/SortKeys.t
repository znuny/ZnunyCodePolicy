# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;

## nofilter(TidyAll::Plugin::Znuny::Perl::SortKeys)

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'for Sort Keys Reference, forbidden',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        ExpectedMessageSubstring => "Don't use hash references while accessing its keys",
    },
    {
        Name     => 'for Keys Reference, forbidden',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        ExpectedSource => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        ExpectedMessageSubstring => "Don't use hash references while accessing its keys",
    },
    {
        Name     => 'for Sort Keys Hash as reference, forbidden',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys \%Hash ) {
EOF
        ExpectedMessageSubstring => "Don't use hash references while accessing its keys",
    },
    {
        Name     => 'for Keys Hash as reference, forbidden',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys \%Hash ) {
EOF
        ExpectedSource => <<'EOF',
for my $Variable ( sort keys \%Hash ) {
EOF
        ExpectedMessageSubstring => "Don't use hash references while accessing its keys",
    },
    {
        Name     => 'for Sort Keys unreferenced Hash, OK',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
    },
    {
        Name     => 'for Keys unreferenced Hash, forbidden',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
        ExpectedSource => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
    },
    {
        Name     => 'for Keys  Hash, OK',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::SortKeys)],
        Source   => <<'EOF',
for my $Variable ( sort keys %Hash ) {
EOF
        ExpectedSource => <<'EOF',
for my $Variable ( sort keys %Hash ) {
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
