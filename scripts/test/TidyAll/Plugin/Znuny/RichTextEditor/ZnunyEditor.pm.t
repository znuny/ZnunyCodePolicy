# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## no critic (RequireExplicitPackage)
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::ListAllInstances)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Plugin disabled - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::ZnunyEditor)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::ZnunyEditor)
CKEDITOR
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::ZnunyEditor)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
CKEDITOR
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate CKEDITOR - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::ZnunyEditor)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The global CKEDITOR object is no longer used in the new CKEditor API.",
    },
    {
        Name     => 'Do not validate CKEDITOR.instances (handled by GetInstance plugin)',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::ZnunyEditor)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances['RichText']
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
