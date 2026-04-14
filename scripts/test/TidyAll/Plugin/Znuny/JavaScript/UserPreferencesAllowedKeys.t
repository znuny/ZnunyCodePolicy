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
        Name     => 'No PreferencesUpdate usage',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys)],
        Source   => <<'EOF',
Core.UI.Dialog.ShowAlert('Title', 'Body');
EOF
    },
    {
        Name     => 'PreferencesUpdate in single-line comment is ignored',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys)],
        Source   => <<'EOF',
// Core.Agent.PreferencesUpdate('UserSystemConfigurationCategory', SelectedCategory);
EOF
    },
    {
        Name     => 'PreferencesUpdate in block-comment-start line is ignored',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys)],
        Source   => <<'EOF',
/* Core.Agent.PreferencesUpdate('UserSystemConfigurationCategory', SelectedCategory); */
EOF
    },
    {
        Name     => 'Single PreferencesUpdate call shows notice',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys)],
        Source   => <<'EOF',
Core.Agent.PreferencesUpdate('UserSystemConfigurationCategory', SelectedCategory);
EOF
        ExpectedMessageSubstring => [
            'Found Core.Agent.PreferencesUpdate call(s).',
            'UserPreferencesUpdate###<Context>',
            q{Line 1: Core.Agent.PreferencesUpdate('UserSystemConfigurationCategory', SelectedCategory);},
        ],
    },
    {
        Name     => 'Multiple PreferencesUpdate calls report all affected lines',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys)],
        Source   => <<'EOF',
if (Condition) {
    Core.Agent.PreferencesUpdate('A', ValueA);
}
Core.Agent.PreferencesUpdate('B', ValueB);
EOF
        ExpectedMessageSubstring => [
            'Line 2:     Core.Agent.PreferencesUpdate(\'A\', ValueA);',
            'Line 4: Core.Agent.PreferencesUpdate(\'B\', ValueB);',
        ],
    },
    {
        Name     => 'Notice still shown with unrelated config settings',
        Filename => 'Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::JavaScript::UserPreferencesAllowedKeys)],
        Settings => {
            'TidyAll::RootDir'     => '/tmp',
            'FilePaths::Directory' => ['Kernel/Config/Files/ZZZ.xml'],
        },
        Source => <<'EOF',
Core.Agent.PreferencesUpdate('AnotherKey', AnotherValue);
EOF
        ExpectedMessageSubstring => 'Found Core.Agent.PreferencesUpdate call(s).',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
