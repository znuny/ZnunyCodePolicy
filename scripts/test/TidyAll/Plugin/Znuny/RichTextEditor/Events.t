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
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::Events)
CKEDITOR.instances['RichText'].on('key', function (Event) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
CKEDITOR.instances['RichText'].on('key', function (Event) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate key event with quoted instance name - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances['RichText'].on('key', function (Event) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
    {
        Name     => 'Validate key event with unquoted instance name - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances[Editor1].on('key', function (Event) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
    {
        Name     => 'Validate key event without Event parameter - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances['Body'].on('key', function () {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
    {
        Name     => 'Validate keyup event from document - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances[InstanceName].document.on('keyup', function () {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
    {
        Name     => 'Validate blur event - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances['RichText'].on('blur', function (Event) {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
    {
        Name     => 'Validate paste event - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
CKEDITOR.instances['Editor'].on('paste', function () {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
    {
        Name     => 'Validate focus event - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::Events)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
Core.UI.RichTextEditor.GetInstance(InstanceName).on('focus', function () {
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The new CKEditor API uses different event handling patterns.",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
