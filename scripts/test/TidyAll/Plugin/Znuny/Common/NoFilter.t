# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
## nofilter(TidyAll::Plugin::Znuny::Common::NoFilter)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Replace nofilter lines in PM files',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Common::NoFilter)],
        Source   => <<'EOF',
# nofilter(TidyAll::Plugin::Znuny::Perl::PerlCritic)
EOF
        ExpectedSource => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::Perl::PerlCritic)
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Replace nofilter lines in JS files',
        Filename => 'var/httpd/htdocs/js/Core.Config.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Common::NoFilter)],
        Source   => <<'EOF',
/ nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
EOF
        ExpectedSource => <<'EOF',
// nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Replace nofilter lines in CSS files',
        Filename => 'var/httpd/htdocs/skins/Agent/default/css/Core.Default.css',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Common::NoFilter)],
        Source   => <<'EOF',
/* no filter (TidyAll::Plugin::Znuny::Legal::LicenseValidator) */
EOF
        ExpectedSource => <<'EOF',
/* nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) */
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Replace nofilter lines in XML files',
        Filename => 'Kernel/Config/Files/XML/Framework.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Common::NoFilter)],
        Source   => <<'EOF',
<!--  nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) -->
EOF
        ExpectedSource => <<'EOF',
<!-- nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) -->
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Replace old product name with new one',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Common::NoFilter)],
        Source   => <<'EOF',
## nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)
EOF
        ExpectedSource => <<'EOF',
## nofilter(TidyAll::Plugin::Znuny::Perl::PerlCritic)
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Remove invalid nofilter tag',
        Filename => 'Kernel/System/Znuny.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Common::NoFilter)],
        Source   => <<'EOF',
## nofilter(TidyAll::Plugin::OTRS::Invalid)
EOF
        ExpectedSource => <<'EOF',

EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
