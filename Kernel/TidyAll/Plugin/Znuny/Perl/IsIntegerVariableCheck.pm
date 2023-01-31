# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::IsIntegerVariableCheck;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage = '';
    my $Counter = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line =~ m{^ \#}smx;

        next LINE if $Line !~ m{looks_like_number}smx;

        $ErrorMessage .= "Line $Counter: $Line\n";
    }

    return if !length $ErrorMessage;

    my $Message  = <<EOF;
Avoid looks_like_number since the result is inconsistent across different systems.
Use IsInteger() and IsPositiveInteger() instead.
$ErrorMessage
EOF

    $Self->AddErrorMessage($Message);

    return;
}

1;
