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

use vars qw($Self);
use utf8;

use File::Spec;

use scripts::test::TidyAll::Plugin::Znuny;

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use TidyAll::Znuny;

sub CreateTidyAllZnuny {
    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );

    my $Home = $ConfigObject->Get('Home');

    my $TidyAllObject = TidyAll::Znuny->new_from_conf_file(
        "$Home/Kernel/TidyAll/tidyallrc",
        no_cache   => 1,
        check_only => 1,
        mode       => 'tests',
        root_dir   => $Home,
        data_dir   => File::Spec->tmpdir(),
    );

    return $TidyAllObject;
}

my $TidyAllZnuny = CreateTidyAllZnuny();

my @ValidTests = (
    {
        Name     => 'three numeric segments',
        Input    => '7.1.2',
        Expected => {
            Major => 7,
            Minor => 1,
            Patch => 2
        },
    },
    {
        Name     => 'two segments patch defaults to 0',
        Input    => '7.1',
        Expected => {
            Major => 7,
            Minor => 1,
            Patch => 0
        },
    },
    {
        Name     => 'wildcard patch segment',
        Input    => '6.4.x',
        Expected => {
            Major => 6,
            Minor => 4,
            Patch => 'x'
        },
    },
    {
        Name     => 'multi-digit segments',
        Input    => '10.20.30',
        Expected => {
            Major => 10,
            Minor => 20,
            Patch => 30
        },
    },
);

for my $Test (@ValidTests) {
    my %Got = $TidyAllZnuny->GetSemanticVersion( $Test->{Input} );
    for my $Key (qw(Major Minor Patch)) {
        $Self->Is(
            $Got{$Key},
            $Test->{Expected}{$Key},
            "GetSemanticVersion valid ($Test->{Name}) - $Key",
        );
    }
}

my @InvalidInputs = (
    {
        Name  => 'undef',
        Input => undef,
    },
    {
        Name  => 'empty string',
        Input => '',
    },
    {
        Name  => 'single segment',
        Input => '7',
    },
    {
        Name  => 'four segments',
        Input => '7.1.2.3',
    },
    {
        Name  => 'v-prefix',
        Input => 'v7.1.2',
    },
    {
        Name  => 'leading whitespace',
        Input => ' 7.1.2',
    },
    {
        Name  => 'patch letter other than x',
        Input => '7.1.a',
    },
);

for my $Test (@InvalidInputs) {
    my %Got = $TidyAllZnuny->GetSemanticVersion( $Test->{Input} );
    $Self->Is(
        scalar keys %Got,
        0,
        "GetSemanticVersion invalid ($Test->{Name}) returns empty hash",
    );
}

1;
