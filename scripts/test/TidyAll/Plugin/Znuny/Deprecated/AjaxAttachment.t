# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::AjaxAttachment)
## no critic (Modules::RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep AjaxAttachment',
        Filename => '/var/httpd/htdocs/js/Core.Agent.Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::AjaxAttachment)],
        Settings => {
            'Framework::Version' => '7.1',
        },
        Source => <<'EOF',
var Data,
    URL = Core.Config.Get('CGIHandle') + '?Action=AjaxAttachment;';

EOF
        ExpectedSource => <<'EOF',
var Data,
    URL = Core.Config.Get('CGIHandle') + '?Action=AjaxAttachment;';

EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Renamed AjaxAttachment to AJAXAttachment',
        Filename => '/var/httpd/htdocs/js/Core.Agent.Test.js',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::AjaxAttachment)],
        Settings => {
            'Framework::Version' => '7.2',
        },
        Source => <<'EOF',
var Data,
    URL = Core.Config.Get('CGIHandle') + '?Action=AjaxAttachment;';

EOF
        ExpectedSource => <<'EOF',
var Data,
    URL = Core.Config.Get('CGIHandle') + '?Action=AJAXAttachment;';

EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
