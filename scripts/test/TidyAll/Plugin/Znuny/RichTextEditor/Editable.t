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
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Editable)
$('body.cke_editable', $('.cke_wysiwyg_frame').contents())
EOF
        ExpectedSource => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Editable)
$('body.cke_editable', $('.cke_wysiwyg_frame').contents())
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no transformation',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
$('body.cke_editable', $('.cke_wysiwyg_frame').contents())
EOF
        ExpectedSource => <<'EOF',
$('body.cke_editable', $('.cke_wysiwyg_frame').contents())
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate basic editable selector - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
$('body.cke_editable', $('.cke_wysiwyg_frame').contents())
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => 'Validate editable selector in variable assignment - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var EditorBody = $('body.cke_editable', $('.cke_wysiwyg_frame').contents());
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => 'Validate editable selector equality comparison - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if ($('body.cke_editable', $('.cke_wysiwyg_frame').contents()) >= 1) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => 'Validate editable selector length comparison - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if ($('body.cke_editable', $('.cke_wysiwyg_frame').contents()).length == 1) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => 'Validate in return statement - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
return $('body.cke_editable', $('.cke_wysiwyg_frame').contents()).length == 1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => 'Validate multiple instances in same code block - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var EditorBody = $('body.cke_editable', $('.cke_wysiwyg_frame').contents());
if ($('body.cke_editable', $('.cke_wysiwyg_frame').contents()).length == 1) {
    return $('body.cke_editable', $('.cke_wysiwyg_frame').contents()) == 1;
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => 'Do not validate similar but different patterns',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
$('body.other_class', $('.different_frame').contents())
$('.ck-editor__editable').contents()
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate multiple instances in same code block - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
$('body.cke_editable', $('.cke_wysiwyg_frame').contents())
$('body.cke_editable', $('.cke_wysiwyg_frame').contents()).length == 1
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => "Validate wrong selector 'body.cke_editable' - warning",
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
$('body.cke_editable')
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
    {
        Name     => "Validate wrong selector 'cke_wysiwyg_frame' - warning",
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Editable)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
$('.cke_wysiwyg_frame')
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
