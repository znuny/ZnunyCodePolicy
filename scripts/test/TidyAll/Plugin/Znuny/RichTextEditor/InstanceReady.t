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
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances['RichText']) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances['RichText']) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate CKEDITOR type check with quoted instance name - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances['RichText']) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses event subscriptions instead of type checks.",
    },
    {
        Name     => 'Validate CKEDITOR type check with unquoted instance name - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances[Editor]) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses event subscriptions instead of type checks.",
    },
    {
        Name     => 'Validate CKEDITOR type check with double quotes - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances["Body"]) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses event subscriptions instead of type checks.",
    },
    {
        Name     => 'Validate CKEDITOR type check with extra spaces - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if ( typeof CKEDITOR !== 'undefined'  &&  CKEDITOR  &&  CKEDITOR.instances['Editor1'] ) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses event subscriptions instead of type checks.",
    },
    {
        Name     => 'Do not validate different patterns',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
if (typeof SomeOtherObject !== 'undefined') {
if (CKEDITOR && CKEDITOR.config) {
if (Core.UI.RichTextEditor.GetInstance('RichText')) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
