# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::ConsolePrintCheck;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks deprecated print statements in OTRS / Znuny Console scripts

=cut

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );

    my $LineCounter  = 0;
    my $ErrorMessage = '';

    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;
        next LINE if $Line !~ /\bprint(\z|\s|\()/sm;
        $ErrorMessage .= "\n\tLine $LineCounter: $Line";
    }

    return if !length $ErrorMessage;

    my $Message = "In console scripts use " . '$Self->Print("Hello World\n")'
        . " instead of just print as in bin scripts for OTRS versions older than 5.\n"
        . "If printing to a file handle, consider using Kernel::System::Main::FileWrite()."
        . $ErrorMessage;


    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

}

1;
