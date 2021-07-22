# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::CacheCleanup;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;
    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );

    my $LineCounter  = 0;
    my $ErrorMessage = '';

    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        # Only test for $CacheObject and Kernel::System::Cache
        next LINE if $Line !~ m{(\$CacheObject|\('Kernel::System::Cache'\))->CleanUp\(\s*\)};
        $ErrorMessage .= "\n\tLine $LineCounter: $Line";
    }

    return if !$ErrorMessage;

    my $Message  = <<EOF;
Kernel::System::Cache::CleanUp() must be called with arguments.
$ErrorMessage
EOF

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

    return;
}

1;