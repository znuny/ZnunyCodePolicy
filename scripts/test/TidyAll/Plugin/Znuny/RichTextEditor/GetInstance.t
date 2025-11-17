# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## no critic (RequireExplicitPackage)
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
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)
var Instance = CKEDITOR.instances.RichTextEditor1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
var Instance = CKEDITOR.instances.RichTextEditor1;
var Instance2 = CKEDITOR.instances['RichTextEditor2'];
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate CKEDITOR.instances.InstanceName - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Instance = CKEDITOR.instances.RichTextEditor1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API no longer uses CKEDITOR.instances.",
    },
    {
        Name     => 'Validate CKEDITOR.instances[\'InstanceName\'] - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Instance = CKEDITOR.instances['RichTextEditor2'];
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API no longer uses CKEDITOR.instances.",
    },
    {
        Name     => 'Validate CKEDITOR.instances[InstanceName] (without quotes) - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Instance = CKEDITOR.instances[RichTextEditor3];
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API no longer uses CKEDITOR.instances.",
    },
    {
        Name     => 'Do not validate similar but different patterns',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var SomethingElse = CKEDITOR.config.toolbar;
var AnotherThing = SomeOtherObject.instances.Editor1;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate multiple instances - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::GetInstance)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Instance1 = CKEDITOR.instances.Editor1;
var Instance2 = CKEDITOR.instances['Editor2'];
var Instance2 = CKEDITOR.instances[Editor3];
var Instance3 = CKEDITOR.instances.AnotherEditor;
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API no longer uses CKEDITOR.instances.",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
