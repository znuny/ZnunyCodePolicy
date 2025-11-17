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
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Focus)
CKEditorInstances[EditorID].focus();
EOF
        ExpectedSource => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Focus)
CKEditorInstances[EditorID].focus();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no transformation',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
CKEditorInstances[EditorID].focus();
EOF
        ExpectedSource => <<'EOF',
CKEditorInstances[EditorID].focus();
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate CKEditorInstances focus with variable - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEditorInstances[EditorID].focus();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found CKEditorInstances[].focus() pattern. Use Core.UI.RichTextEditor.Focus() instead.",
    },
    {
        Name     => 'Validate CKEditorInstances focus with string - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEditorInstances['RichText'].focus();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found CKEditorInstances[].focus() pattern. Use Core.UI.RichTextEditor.Focus() instead.",
    },
    {
        Name     => 'Validate CKEditorInstances focus with double quotes - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEditorInstances["RichText"].focus();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found CKEditorInstances[].focus() pattern. Use Core.UI.RichTextEditor.Focus() instead.",
    },
    {
        Name     => 'Validate multiple CKEditorInstances focus calls - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEditorInstances[Editor1].focus();
CKEditorInstances[Editor2].focus();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Found CKEditorInstances focus usage. Use Core.UI.RichTextEditor.Focus() instead.",
    },
    {
        Name     => 'Validate CKEditorInstances focus in if statement - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (SomeCondition) {
    CKEditorInstances[EditorID].focus();
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "Found CKEditorInstances focus usage. Use Core.UI.RichTextEditor.Focus() instead.",
    },
    {
        Name     => 'Do not validate new API usage',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
Core.UI.RichTextEditor.Focus($('#' + EditorID.sourceElement.id))
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Do not validate other CKEditor methods',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEditorInstances[EditorID].getData();
CKEditorInstances[EditorID].setData('content');
CKEditorInstances[EditorID].destroy();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Do not validate unrelated focus calls',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Focus)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
$('#SomeElement').focus();
SomeObject.focus();
MyEditor.focus();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
