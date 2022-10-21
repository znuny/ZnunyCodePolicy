# --
# Copyright (C) Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::HashObjectFunctionCall;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

# Prevents direct method calls to objects within hash assignments.

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsOriginalOTRSCode($Code);

    my $HashObjectFunctionCallLines = '';
    my $LineCounter               = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        next LINE if $Line =~ m{\A\s*#};

        # Ignore $ConfigObject->Get()
        next LINE if $Line =~ m{=>\s+\$ConfigObject->Get\(};

        # Ignore ->RandomID()
        next LINE if $Line =~ m{=>\s*\$.*?Object->GetRandomID\(};

        # e.g. Coffee => $CoffeObject->Get()
        next LINE if $Line !~ m{=>\s*\$.*?Object->.*?\(};

        $HashObjectFunctionCallLines .= "Line $LineCounter: $Line\n";
    }

    return if !length $HashObjectFunctionCallLines;

    my $Message  = <<EOF;
Don't use object function calls in hash assignments:
$HashObjectFunctionCallLines
EOF

    $Self->AddErrorMessage($Message);

    return;
}

1;
