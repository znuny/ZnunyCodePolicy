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

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name      => 'valid package name with no critic',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'valid package name with out no critic',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
package scripts::test::Pod::Test;

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name correct format',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
        ExpectedSource => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name slashes',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts/test/Pod/Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
        ExpectedSource => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name slashes custom file', # Does not modify the file even it its wrong
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
# $origin: otrs - d152f0ba9f7b326b4bd3b8624cc2c99944e2a956 - scripts/test/Pod/Test.pm
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts/test/Pod/Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
        ExpectedSource => <<'EOF',
# $origin: otrs - d152f0ba9f7b326b4bd3b8624cc2c99944e2a956 - scripts/test/Pod/Test.pm
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts/test/Pod/Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name just name',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
        ExpectedSource => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },

    {
        Name      => 'wrong package name correct format extended POD',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::Znuny::Perl::Pod::NamePod)],
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Test -  Testing file.

=head1 DESCRIPTION

some description

=head1 SYNOPSIS

some synopsys

=cut

sub Run {
    ...
}
EOF
        ExpectedSource => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=head1 DESCRIPTION

some description

=head1 SYNOPSIS

some synopsys

=cut

sub Run {
    ...
}
EOF
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
