# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::UnitTest::Path;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks unit test path.

=cut

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my $ProductName = $Self->GetSetting('ProductName') // '';
    return if !length $ProductName;

    ( my $ProductDirectoryName = $ProductName ) =~ s{-}{}g;

    my $ExpectedUnitTestPath = 'scripts\/test\/' . $ProductDirectoryName . '\/.+\.t';
    return if $Filename =~ m{$ExpectedUnitTestPath\z};

    my $Message  = "Found unit test '$Filename' in wrong directory.\n"
        . "The following directory is expected: 'scripts/test/$ProductDirectoryName/*.t'";

    $Self->AddErrorMessage($Message);
}
1;
