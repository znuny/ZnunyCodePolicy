# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Deprecated::CreateTimeUnix;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for deprecated ticket field 'CreateTimeUnix'.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $LineCounter = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;
        next LINE if $Line =~ m{\A\s*#};
        next LINE if $Line !~ m{Ticket.*?\{(["'])?CreateTimeUnix(["'])?\}};

        $ErrorMessage .= "\n\tLine $LineCounter: $Line";
    }

    return if !defined $ErrorMessage;

    my $Message = "There's code referencing ticket field CreateTimeUnix. This field was removed from tickets in Znuny 6. Use field Created and convert it to a unix timestamp." . $ErrorMessage;

    $Self->AddErrorMessage($Message);

    return;
}

1;
