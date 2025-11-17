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
        Name     => 'Plugin disabled - no transformation',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)
EditorID.getSelection().getRanges()
EOF
        ExpectedSource => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)
EditorID.getSelection().getRanges()
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no transformation',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
EditorID.getSelection().getRanges()
EOF
        ExpectedSource => <<'EOF',
EditorID.getSelection().getRanges()
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate getSelection getRanges pattern - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
EditorID.getSelection().getRanges()
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found getSelection().getRanges() pattern. Use model.document.selection.getRanges() instead.",
    },
    {
        Name     => 'Validate getSelection getRanges with variable assignment - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var ranges = Editor.getSelection().getRanges();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found getSelection().getRanges() usage. Use model.document.selection.getRanges() instead.",
    },
    {
        Name     => 'Validate getSelection getRanges in return statement - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
return SomeEditor.getSelection().getRanges();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found getSelection().getRanges() usage. Use model.document.selection.getRanges() instead.",
    },
    {
        Name     => 'Validate getSelection getRanges in if condition - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (MyEditor.getSelection().getRanges().length > 0) {
    // do something
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found getSelection().getRanges() usage. Use model.document.selection.getRanges() instead.",
    },
    {
        Name     => 'Validate multiple getSelection getRanges calls - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var ranges1 = Editor1.getSelection().getRanges();
var ranges2 = Editor2.getSelection().getRanges();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found getSelection().getRanges() usage. Use model.document.selection.getRanges() instead.",
    },
    {
        Name     => 'Validate getSelection getRanges with method chaining - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
EditorInstance.getSelection().getRanges().forEach(function(range) {
    console.log(range);
});
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found getSelection().getRanges() usage. Use model.document.selection.getRanges() instead.",
    },
    {
        Name     => 'Do not validate new API usage',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
EditorID.model.document.selection.getRanges()
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Do not validate other selection methods',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
EditorID.getSelection();
EditorID.getSelection().getSelectedText();
document.getSelection().toString();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Do not validate unrelated getRanges calls',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Ranges)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
SomeOtherObject.getRanges();
MyDocument.getRanges();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
