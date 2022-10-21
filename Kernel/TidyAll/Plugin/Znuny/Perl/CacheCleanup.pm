# --
# Copyright (C) Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::CacheCleanup;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $LineCounter  = 0;
    my $ErrorMessage = '';

    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        # Only test for $CacheObject and Kernel::System::Cache
        next LINE if $Line !~ m{(\$CacheObject|\('Kernel::System::Cache'\))->CleanUp\(\s*\)};
        $ErrorMessage .= "Line $LineCounter: $Line\n";
    }

    return if !$ErrorMessage;

    my $Message  = <<EOF;
Kernel::System::Cache::CleanUp() must be called with arguments.
$ErrorMessage
EOF

    $Self->AddErrorMessage($Message);

    return;
}

1;
