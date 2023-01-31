# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Perl::PerlCritic)

package scripts::test::TidyAll::Plugin::Znuny;    ## no critic

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin) . '/Kernel/';           # find TidyAll

use utf8;

use TidyAll::Znuny;

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;

=head1 Run()

runs Znuny code policy unit tests.

    $Self->scripts::test::TidyAll::Plugin::Znuny::Run(
        Tests => [
            {
                Name                     => 'Avoid C-style for-loops if possible.',
                Filename                 => 'Znuny.pm',
                Plugins                  => [qw(TidyAll::Plugin::Znuny::CodeStyle::CStyleForLoop)],
                Source                   => 'for (my $Test) {}',
                ExpectedSource           => undef, # expected changed source; undef if no change is expected.
                ExpectedMessageSubstring => "Avoid C-style for loops if possible.", # substring the file check result messages must contain.
            },
        ]
    );

=cut

sub Run {
    my ( $Self, %Param ) = @_;

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

    TEST:
    for my $Test ( @{ $Param{Tests} } ) {

        # Always create a new TidyAll object for each test because of generated (error) messages
        # after executing a code policy module.
        my $TidyAllObject = TidyAll::Znuny->new_from_conf_file(
            "$Home/Kernel/TidyAll/tidyallrc",
            no_cache   => 1,
            check_only => 1,
            mode       => 'tests',
            root_dir   => $Home,
            data_dir   => File::Spec->tmpdir(),
        );

        # Enable custom settings (e.g. "IsThirdPartyProduct")
        if ( %{ $Test->{Settings} // {} } ) {
            $TidyAllObject->SetSettings( %{ $Test->{Settings} } );
        }

        NEEDED:
        for my $Needed (qw(Name Filename Plugins Source)) {
            next NEEDED if defined $Test->{$Needed};

            my $Message = $Self->_Color( 'red', "Parameter '$Needed' missing in test: $Test->{Name}" );
            $Self->True(
                0,
                $Message,
            );
        }

        my $Source = $Test->{Source};

        my $STDOUT;
        eval {
            local *STDOUT;
            open STDOUT, '>:encoding(UTF-8)', \$STDOUT;

            for my $PluginModule ( @{ $Test->{Plugins} } ) {
                $MainObject->Require($PluginModule);
                my $Plugin = $PluginModule->new(
                    name    => $PluginModule,
                    tidyall => $TidyAllObject,
                );

                for my $Method (qw(preprocess_source process_source_or_file postprocess_source)) {
                    ($Source) = $Plugin->$Method( $Source, $Test->{Filename} );
                }
            }
        };

        # Check if source has changed.
        if ( !defined $Test->{ExpectedSource} ) {
            $Test->{ExpectedSource} = $Test->{Source};
        }

        $Self->Is(
            scalar $Source,
            scalar $Test->{ExpectedSource},
            "$Test->{Name}: Source must match expected one.",
        );

        # Check messages.
        my $FileCheckResults = $TidyAllObject->GetFileCheckResults();

        # for debugging/testing
        #                 use Data::Dumper;
        #                 print STDERR Dumper($FileCheckResults) . "\n";

        $Self->True(
            ref $FileCheckResults eq 'HASH',
            "$Test->{Name}: File check results must be a hash.",
        ) || next TEST;

        my @Messages;
        if ( @{ $FileCheckResults->{ $Test->{Filename} }->{Messages} // [] } ) {
            push @Messages, @{ $FileCheckResults->{ $Test->{Filename} }->{Messages} };
        }
        if ( @{ $FileCheckResults->{ $Test->{Filename} }->{ErrorMessages} // [] } ) {
            push @Messages, @{ $FileCheckResults->{ $Test->{Filename} }->{ErrorMessages} };
        }

        $Self->True(
            ( scalar @Messages && defined $Test->{ExpectedMessageSubstring} )
                || ( !scalar @Messages && !defined $Test->{ExpectedMessageSubstring} ),
            'ExpectedMessageSubstring parameter must be given if plugin result contains messages. ExpectedMessageSubstring parameter must not be given if plugin result does not contains messages.'
        );

        if ( defined $Test->{ExpectedMessageSubstring} ) {
            if ( ref $Test->{ExpectedMessageSubstring} ne 'ARRAY' ) {
                $Test->{ExpectedMessageSubstring} = [ $Test->{ExpectedMessageSubstring} ];
            }

            for my $ExpectedMessageSubstring ( @{ $Test->{ExpectedMessageSubstring} } ) {

                $Self->True(
                    defined $ExpectedMessageSubstring && length $ExpectedMessageSubstring,
                    'Expected message substring must be defined and have a length.',
                );

                my $MessageFound = grep {
                    index( $_, $ExpectedMessageSubstring ) != -1
                } @Messages;

                $Self->True(
                    $MessageFound,
                    "$Test->{Name}: Messages of file check results must contain expected substring.",
                );
            }

            next TEST;
        }

        $Self->False(
            scalar @Messages,
            "$Test->{Name}: File check results must not contain any messages.",
        );
    }

    return 1;
}

1;
