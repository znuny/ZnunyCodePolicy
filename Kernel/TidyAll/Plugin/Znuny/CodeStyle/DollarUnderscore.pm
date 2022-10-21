# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::DollarUnderscore;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter      = 0;
    my $ErrorMessage = '';
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line =~ m{^ \#}smx;

        # Check if for-loop without explicit loop variable
        next LINE if $Line !~ m{\A \s* for \s+ \(}smx;

        # Check if C-style for-loop, these should be ignored here
        next LINE if $Line =~ m{\A \s* for \s+ \( \s* (my)? \s* (\$|;)}smx;

        $ErrorMessage .= "\n\tLine $Counter: $Line";
    }

    return if !length $ErrorMessage;

    my $Message
        = "Don't (implicitly) use the default variable \$_. Variables should have meaningful names.$ErrorMessage";

    $Self->AddErrorMessage($Message);

    return;
}

1;
