# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
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
        Name     => 'PerlCritic ProhibitOpen regular file, old-style read',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '<filename.txt');
close $FH;
EOF
        ExpectedMessageSubstring => 'Two-argument "open" used',
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, read',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '<', 'filename.txt');
close $FH;
EOF
        ExpectedMessageSubstring => 'Use of "open" is not allowed to read or write files',
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, read, no parentheses, bareword filehandle',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
open FH, '<', 'filename.txt';
close $FH;
EOF
        ExpectedMessageSubstring => [
            'Bareword file handle opened',
            'Close filehandles as soon as possible after opening them',
            'Use of "open" is not allowed to read or write files',
        ],
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, write',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '>', 'filename.txt');
close $FH;
EOF
        ExpectedMessageSubstring => 'Use of "open" is not allowed to read or write files',
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, write, no parentheses',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, '>', 'filename.txt';
close $FH;
EOF
        ExpectedMessageSubstring => 'Use of "open" is not allowed to read or write files',
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, bidirectional',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '+>', 'filename.txt');
close $FH;
EOF
        ExpectedSource => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '+>', 'filename.txt');
close $FH;
EOF
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, external command',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '-|', 'some_command');
close $FH;
EOF
        ExpectedSource => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '-|', 'some_command');
close $FH;
EOF
    },
    {
        Name     => 'PerlCritic ProhibitOpen regular file, unclear mode',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, $Mode, $Param{Location};
close $FH;
EOF
        ExpectedSource => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, $Mode, $Param{Location};
close $FH;
EOF
    },
    {
        Name     => 'PerlCritic ProhibitOpen in another context',
        Filename => 'test.pl',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Perl::PerlCritic)],
        Source   => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $GeoIPObject = Geo::IP->open( $GeoIPDatabaseFile, Geo::IP::GEOIP_STANDARD() );
EOF
        ExpectedSource => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $GeoIPObject = Geo::IP->open( $GeoIPDatabaseFile, Geo::IP::GEOIP_STANDARD() );
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
