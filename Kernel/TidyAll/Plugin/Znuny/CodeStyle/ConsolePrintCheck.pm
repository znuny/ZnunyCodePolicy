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

Checks for deprecated print statements in console commands.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

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

    my $Message = 'Use $Self->Print("Hello World\n") in console commands instead of "print"' . ".\n"
        . "If writing to a file, consider using Kernel::System::Main::FileWrite()."
        . $ErrorMessage;

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'notice',
    );
}

1;
