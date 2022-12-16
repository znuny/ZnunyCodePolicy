# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)
## no critic (Modules::RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'ArticleGetTicketIDOfMessageID - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleGetTicketIDOfMessageID();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticleGetContentPath - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleGetContentPath();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticleTypeLookup - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleTypeLookup();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticleTypeList - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleTypeList();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticleLastCustomerArticle - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleLastCustomerArticle();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticleFirstArticle - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleFirstArticle();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticleContentIndex - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticleContentIndex();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
    {
        Name     => 'ArticlePage - Found deprecated article function call(s)',
        Filename => 'Kernel/Modules/Coffee.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions)],
        Source   => <<'EOF',
my $ArticleObject->ArticlePage();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => 'Found deprecated article function call',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
