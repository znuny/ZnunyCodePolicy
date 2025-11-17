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
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Plugin disabled - no transformation',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)
if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
    $.each(CKEDITOR.instances, function (Key) {
        CKEDITOR.instances[Key].destroy();
    });
}
EOF
        ExpectedSource => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)
if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
    $.each(CKEDITOR.instances, function (Key) {
        CKEDITOR.instances[Key].destroy();
    });
}
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no transformation',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
    $.each(CKEDITOR.instances, function (Key) {
        CKEDITOR.instances[Key].destroy();
    });
}
EOF
        ExpectedSource => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
    $.each(CKEDITOR.instances, function (Key) {
        CKEDITOR.instances[Key].destroy();
    });
}
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate destroy all instances pattern - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
    $.each(CKEDITOR.instances, function (Key) {
        CKEDITOR.instances[Key].destroy();
    });
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found CKEDITOR destroy all instances pattern. Use Core.UI.RichTextEditor.DestroyAllInstances() instead.",
    },
    {
        Name     => 'Validate destroy single instance pattern - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var EditorID = $(this).attr('id');
var Editor   = CKEDITOR.instances[EditorID];
if (!Editor) return true;
$(this).removeClass('HasCKEInstance');
Editor.destroy(true);
Core.UI.RichTextEditor.DestroyInstance(EditorID)
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found CKEDITOR destroy single instance pattern. Use Core.UI.RichTextEditor.DestroyInstance(EditorID) instead.",
    },
    {
        Name     => 'Validate direct CKEDITOR.instances access - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Editor = CKEDITOR.instances[EditorID];
Editor.focus();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found direct CKEDITOR.instances access. Consider using Core.UI.RichTextEditor methods.",
    },
    {
        Name     => 'Validate alternative destroy all instances pattern - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances) {
    $.each(CKEDITOR.instances, function (Key) {
        CKEDITOR.instances[Key].destroy();
    });
}
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found CKEDITOR destroy all instances pattern. Use Core.UI.RichTextEditor.DestroyAllInstances() instead.",
    },
    {
        Name     => 'Multiple direct CKEDITOR.instances usage - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Editor1 = CKEDITOR.instances['Editor1'];
var Editor2 = CKEDITOR.instances['Editor2'];
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring =>
            "Found direct CKEDITOR.instances access. Consider using Core.UI.RichTextEditor methods.",
    },
    {
        Name     => 'Do not validate new API usage',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
Core.UI.RichTextEditor.DestroyAllInstances().then(function(){
    // some code after destroy...
}
.catch(function(error){
    console.error('Error while destroying CKEditor instances:', error);
}));
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Do not validate new single instance API usage',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Destroy)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var EditorID = $(this).attr('id');
Core.UI.RichTextEditor.DestroyInstance(EditorID).then(function(){
    // some code after destroy...
}.catch(function(error){
    console.error('Error while destroying CKEditor instance:', error);
}));
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
