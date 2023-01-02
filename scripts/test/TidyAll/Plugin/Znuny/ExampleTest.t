# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

#
# This is an inactive example test to show and explain all the options
# available in code policy plugin tests.
#

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Test example',
        Filename => 'Znuny-Playground.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::ExampleTest)],

        # optional
        Settings => {

            # Here you can set specific settings for the test context.
            # These are the same settings that the code policy will derive
            # from the context (e.g. SOPM, framework, vendor, etc.)
            # Have a look at TidyAll::Znuny::_InitSettings for more settings.
            IsThirdPartyProduct => 1,
            'Context::OPM'      => 1,
            'Vendor'            => 'My company',

            # more settings...
        },

        # code to test for
        Source => <<'EOF',
use strict;
use warnings;

# Some code
EOF

        # optional: expected changed code after plugin was run
        # if not given, code is expected to have not been changed by the plugin.
        ExpectedSource => <<'EOF',
use strict;
use warnings;

# Some changed code
EOF

        # optional: expected messages output by plugin
        ExpectedMessageSubstring => "Avoid using function X and use Y instead",

        # or for multiple substrings to test for:
        ExpectedMessageSubstring => [
            "Avoid using function X and use Y instead",
            "Don't use Z at all",
        ],
    },

    # more test cases here...
);

# don't execute example tests
# $Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
