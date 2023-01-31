# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::Tests::Helper;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my %MatchRegexes = (
        HelperObjectParams               => qr{->ObjectParamAdd\(\s*'Kernel::System::UnitTest::Helper'}xms,
        HelperObjectFlagRestoreDatabase  => qr{RestoreDatabase\s*=>\s*1}xms,
        HelperObjectFlagPGPEnvironment   => qr{ProvideTestPGPEnvironment\s*=>\s*1}xms,
        HelperObjectFlagSMIMEEnvironment => qr{ProvideTestSMIMEEnvironment\s*=>\s*1}xms,
        HelperInstantiation              => qr{->Get\('Kernel::System::UnitTest::Helper'}xms,
        SeleniumInstantiation            => qr{->Get\('Kernel::System::UnitTest::Selenium'}xms,
        PGPInstantiation                 => qr{->Get\('Kernel::System::Crypt::PGP'}xms,
        SMIMEInstantiation               => qr{->Get\('Kernel::System::Crypt::SMIME'}xms,
    );

    my %MatchPositions;

    for my $Key ( sort keys %MatchRegexes ) {
        if ( $Code =~ $MatchRegexes{$Key} ) {

            # Store the position of the first match.
            $MatchPositions{$Key} = $-[0];
        }
    }

    return if !$MatchPositions{HelperInstantiation};

    if ( $MatchPositions{SeleniumInstantiation} && $MatchPositions{HelperObjectParams} ) {
        if ( $MatchPositions{SeleniumInstantiation} < $MatchPositions{HelperObjectParams} ) {
            $Self->AddErrorMessage(<<"EOF");
Always set the Helper object params before creating the Selenium object to make sure any constructor flags are properly set and processed. This needs to be done because Selenium::new() already may create the Helper.
EOF
        }
    }

    if ( $MatchPositions{SeleniumInstantiation} && $MatchPositions{HelperObjectFlagRestoreDatabase} ) {
        $Self->AddErrorMessage(<<"EOF");
Don't use the Helper flag 'RestoreDatabase' in Selenium tests, as the web server cannot access the test transaction and data will get lost between requests.
EOF
    }

    return;
}

1;
