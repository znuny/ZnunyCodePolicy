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
use Kernel::System::Main;
use TidyAll::Znuny;

sub CreatePlugin {
    my (%Param) = @_;

    my $ConfigObject = Kernel::Config->new();
    my $EncodeObject = Kernel::System::Encode->new(
        ConfigObject => $ConfigObject,
    );
    my $LogObject = Kernel::System::Log->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
    );
    my $MainObject = Kernel::System::Main->new(
        ConfigObject => $ConfigObject,
        EncodeObject => $EncodeObject,
        LogObject    => $LogObject,
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

    $TidyAllObject->SetSettings(
        'Framework::Version' => $Param{FrameworkVersion},
    );

    $MainObject->Require('TidyAll::Plugin::Znuny::Perl::ForeachToFor');

    return TidyAll::Plugin::Znuny::Perl::ForeachToFor->new(
        name    => 'TidyAll::Plugin::Znuny::Perl::ForeachToFor',
        tidyall => $TidyAllObject,
    );
}

# IsFrameworkVersionLessThan / IsFrameworkVersionGreaterThan compare major and minor only;
# patch (third segment) is ignored (see Kernel/TidyAll/Plugin/Znuny/Base.pm).

my @LessThanTests = (
    {
        Name             => '7.2 is less than 7.3',
        FrameworkVersion => '7.2',
        ReferenceVersion => '7.3',
        ExpectedResult   => 1,
    },
    {
        Name             => '7.3 is not less than 7.3 (same major.minor)',
        FrameworkVersion => '7.3',
        ReferenceVersion => '7.3',
        ExpectedResult   => 0,
    },
    {
        Name             => '7.4 is not less than 7.3 (same major.minor; patch ignored)',
        FrameworkVersion => '7.4',
        ReferenceVersion => '7.3',
        ExpectedResult   => 0,
    },
    {
        Name             => 'invalid reference version yields false',
        FrameworkVersion => '7.3.0',
        ReferenceVersion => 'not-a-version',
        ExpectedResult   => 0,
    },
);

for my $Test (@LessThanTests) {
    my $Plugin = CreatePlugin( FrameworkVersion => $Test->{FrameworkVersion} );
    my $Result = $Plugin->IsFrameworkVersionLessThan( $Test->{ReferenceVersion} ) ? 1 : 0;
    $Self->Is(
        $Result,
        $Test->{ExpectedResult},
        "IsFrameworkVersionLessThan: $Test->{Name}",
    );
}

my @GreaterThanTests = (
    {
        Name             => '7.4 is greater than 7.3',
        FrameworkVersion => '7.4',
        ReferenceVersion => '7.3',
        ExpectedResult   => 1,
    },
    {
        Name             => '7.3 is not greater than 7.3 (same major.minor)',
        FrameworkVersion => '7.3',
        ReferenceVersion => '7.3',
        ExpectedResult   => 0,
    },
    {
        Name             => '7.2 is not greater than 7.3',
        FrameworkVersion => '7.2',
        ReferenceVersion => '7.3',
        ExpectedResult   => 0,
    },
);

for my $Test (@GreaterThanTests) {
    my $Plugin = CreatePlugin( FrameworkVersion => $Test->{FrameworkVersion} );
    my $Result = $Plugin->IsFrameworkVersionGreaterThan( $Test->{ReferenceVersion} ) ? 1 : 0;
    $Self->Is(
        $Result,
        $Test->{ExpectedResult},
        "IsFrameworkVersionGreaterThan: $Test->{Name}",
    );
}

1;
