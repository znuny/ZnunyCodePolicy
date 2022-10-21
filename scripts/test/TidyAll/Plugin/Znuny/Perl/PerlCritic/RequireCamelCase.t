# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

# Work around a Perl bug that is triggered in Devel::StackTrace
#   (probaly from Exception::Class and this from Perl::Critic).
#
#   See https://github.com/houseabsolute/Devel-StackTrace/issues/11 and
#   http://rt.perl.org/rt3/Public/Bug/Display.html?id=78186
no warnings 'redefine';    ## no critic
use Devel::StackTrace ();
local *Devel::StackTrace::new = sub { };    # no-op
use warnings 'redefine';

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'All fine',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
use strict;
use warnings;

sub MyFunction {}
my $CamelCaseVar = 1;

1;
EOF
    },
    {
        Name     => 'Wrong sub',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
use strict;
use warnings;

sub my_function {}

1;
EOF
        ExpectedMessageSubstring => 'Variable, subroutine, and package names have to be in CamelCase',
    },
    {
        Name     => 'Wrong var',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
use strict;
use warnings;

my $_wrong_variable = 1;

1;
EOF
        ExpectedMessageSubstring => 'Variable, subroutine, and package names have to be in CamelCase',
    },
    {
        Name     => 'All fine',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

sub MyFunction {}
my $CamelCaseVar = 1;

1;
EOF
    },
    {
        Name     => 'Wrong sub',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

sub my_function {}

1;
EOF
        ExpectedMessageSubstring => 'Variable, subroutine, and package names have to be in CamelCase',
    },
    {
        Name     => 'Wrong var',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

my $_wrong_variable = 1;

1;
EOF
        ExpectedMessageSubstring => 'Variable, subroutine, and package names have to be in CamelCase',
    },
    {
        Name     => 'Package Variable',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

my $OTHER::PACKAGE::_private_variable = 1;

1;
EOF
    },
    {
        Name     => 'Derived Package (use parent)',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use parent qw(My::Package);

sub overridden_method {}

1;
EOF
    },
    {
        Name     => 'Derived Package (use base)',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

use base qw(My::Package);

sub overridden_method {}

1;
EOF
    },
    {
        Name     => 'RequireBaseClass',
        Filename => 'Test.pm',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
package Kernel::Test;
use strict;
use warnings;

$Kernel::OM->Get('Kernel::System::Main')->RequireBaseClass('Some::Class');

sub overridden_method {}

1;
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
