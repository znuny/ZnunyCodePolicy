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

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Plugin disabled - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::SetData)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::SetData)
Core.UI.RichTextEditor.GetInstance('Body').setData();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::SetData)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
Core.UI.RichTextEditor.GetInstance('Body').setData();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate setData() without parameters - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::SetData)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
Core.UI.RichTextEditor.GetInstance('Body').setData();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The setData() method requires a parameter in the new CKEditor API.",
    },
    {
        Name     => 'Do not validate setData() with parameters',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::SetData)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
Core.UI.RichTextEditor.GetInstance('Body').setData('Test');
Core.UI.RichTextEditor.GetInstance('Body').setData('');
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
