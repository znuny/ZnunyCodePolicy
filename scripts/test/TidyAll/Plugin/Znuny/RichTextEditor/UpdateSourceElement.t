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
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::UpdateSourceElement)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::RichTextEditor::UpdateSourceElement)
return window.editor.updateElement();
Core.UI.RichTextEditor.GetInstance('Body').updateElement();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Framework version less than 7.2 - no warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::UpdateSourceElement)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
return window.editor.updateElement();
Core.UI.RichTextEditor.GetInstance('Body').updateElement();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Validate updateElement() - warning',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::RichTextEditor::UpdateSourceElement)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
return window.editor.updateElement();
Core.UI.RichTextEditor.GetInstance('Body').updateElement();
EOF
        ExpectedSource           => undef,
        ExpectedMessageSubstring => "The method name has changed in the new CKEditor API.",
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
