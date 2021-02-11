# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
package scripts::test::ZnunyCodePolicyPlugins;    ## no critic

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin) . '/Kernel/';          # find TidyAll

use utf8;

use TidyAll::OTRS;

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;

=head2 ()

runs znuny unit tests.

    $Self->scripts::test::ZnunyCodePolicyPlugins::Run(
        Tests => [
            {

                Name      => '6.0 - In console scripts use $Self->Print("Hello World\n")',          # Name of Test
                Filename  => 'Kernel/System/Console/Command/Znuny4OTRS.pm',                         # Path and Filename to test
                Plugins   => [qw(TidyAll::Plugin::OTRS::Znuny4OTRS::CodeStyle::ConsolePrintCheck)], # defines test plugin
                Framework => '6.0',                                                                 # Framwork
                Source    => <<'EOF',                                                               # CodeContent of 'Filename'
        print "ConsolePrintCheck \n";
        EOF
                Exception => 1,                                                                     # ( 1 | 0 )
                                                                                                    # (1 = test died with error)
                                                                                                    # (0 =  prints NOTICE)
                STDOUT                                                                              # expected STDOUT
                Result                                                                              # expected CodeContent (transform_source)
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

    my $TidyAll = TidyAll::OTRS->new_from_conf_file(
        "$Home/Kernel/TidyAll/tidyallrc",
        no_cache   => 1,
        check_only => 1,
        mode       => 'tests',
        root_dir   => $Home,
        data_dir   => File::Spec->tmpdir(),

        #verbose    => 1,
    );


    TEST:
    for my $Test ( @{ $Param{Tests} } ) {

        NEEDED:
        for my $Needed ( qw(Name Filename Plugins Framework Source) ) {
            next NEEDED if defined $Test->{ $Needed };
            my $Message = $Self->_Color('red', "$Test->{Name} - STDOUT");
            $Self->True(
                0,
                $Message,
            );
        }

        if (!defined $Test->{Exception} && !$Test->{Result} && !$Test->{STDOUT}){
            my $Message = $Self->_Color('red', "Parameter 'Exception' or 'Result' or 'STDOUT' is needed!");
            $Self->True(
                0,
                $Message,
            );
        }

        # Set framework version in TidyAll so that plugins can use it.
        my ( $FrameworkVersionMajor, $FrameworkVersionMinor ) = $Test->{Framework} =~ m/(\d+)[.](\d+)/xms;
        $TidyAll::OTRS::FrameworkVersionMajor                 = $FrameworkVersionMajor;
        $TidyAll::OTRS::FrameworkVersionMinor                 = $FrameworkVersionMinor;
        $TidyAll::OTRS::PackageName                           = $Test->{'TidyAll::OTRS::PackageName'} || 'ZnunyCodePolicy';
        $TidyAll::OTRS::OTRSRootDir                           = $Test->{'TidyAll::OTRS::OTRSRootDir'} || $ConfigObject->Get('Home');

        my $Temp = $Test->{'TidyAll::OTRS::FileList'} || ['ZnunyCodePolicy.sopm'];
        @TidyAll::OTRS::FileList = @$Temp;

        my $Source = $Test->{Source};

        my $STDOUT;
        eval {

            local *STDOUT;
            open STDOUT, '>:encoding(UTF-8)', \$STDOUT;

            for my $PluginModule ( @{ $Test->{Plugins} } ) {
                $MainObject->Require($PluginModule);
                my $Plugin = $PluginModule->new(
                    name    => $PluginModule,
                    tidyall => $TidyAll,
                );

                for my $Method (qw(preprocess_source process_source_or_file postprocess_source)) {
                    ($Source) = $Plugin->$Method( $Source, $Test->{Filename} );
                }
            }
        };

        my $Exception = $@;

        if ($STDOUT){
            $STDOUT =~ s/\x1b\[[0-9;]*m//g;
        }

        if ($Exception){
            $Exception =~ s/\x1b\[[0-9;]*m//g;
        }

        # make sure color is correct before check
        if ($Test->{STDOUT} && $Test->{Result}) {
            $Test->{STDOUT} = $Self->_Color('green', $Test->{STDOUT});
            if ($STDOUT){
                $STDOUT    = $Self->_Color('green', $STDOUT);
            }
            if ($Exception){
                $Exception = $Self->_Color('green', $Exception);
            }
        }
        elsif ($Test->{STDOUT} && !$Test->{Exception}){
            $Test->{STDOUT} = $Self->_Color('yellow', $Test->{STDOUT});
            if ($STDOUT){
                $STDOUT    = $Self->_Color('yellow', $STDOUT);
            }
            if ($Exception){
                $Exception = $Self->_Color('yellow', $Exception);
            }
        }
        elsif ($Test->{STDOUT} && $Test->{Exception}){
            $Test->{STDOUT} = $Self->_Color('red', $Test->{STDOUT});
            if ($STDOUT){
                $STDOUT    = $Self->_Color('red', $STDOUT);
            }
            if ($Exception){
                $Exception = $Self->_Color('red', $Exception);
            }
        }


        $Self->Is(
            $Exception ? 1 : 0,
            $Test->{Exception},
            "$Test->{Name} - exception found: $@",
        );

        if ($Test->{Exception} && $Test->{STDOUT}){
            $Self->Is(
                $Exception,
                $Test->{STDOUT},
                "$Test->{Name} - Exception <-> STDOUT",
            );
        }

        if ($Test->{STDOUT} && $STDOUT){
            $Self->Is(
                $STDOUT,
                $Test->{STDOUT},
                "$Test->{Name} - STDOUT <-> STDOUT",
            );
        }

        next TEST if $Exception;

        # check if result has changed after transform_source
        $Self->Is(
            $Source,
            $Test->{Result} // $Test->{Source},
            "$Test->{Name} - result",
        );
    }

    return;
}

1;
