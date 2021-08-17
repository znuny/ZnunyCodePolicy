# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::SeleniumTest::RestoreDatabase;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code =~ m{^ \# \s+ \$origin}xms;
    return if $Code !~ m{('|")Kernel::System::UnitTest::Selenium("|')}sm;

    my $Counter      = 0;
    my $ErrorMessage = '';
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line =~ m{^ \#}smx;

        next LINE if $Line !~ m{RestoreDatabase\s*=>\s*1}sm;

        $ErrorMessage .= "\nLine $Counter: $Line";
    }

    return if !length $ErrorMessage;

    my $Message
        = "Using Kernel::System::UnitTest::Helper with option RestoreDatabase within Selenium tests is most likely a mistake because data will get lost between requests."
        . $ErrorMessage;

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

    return;
}

1;
