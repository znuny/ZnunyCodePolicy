# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Config::MemoryLeak;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for potential memory leaks in custom .pm config files which use the old file format and redefines.

=cut

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    return if $Filename !~ m{Kernel/Config/Files/};
    my $Code = $Self->GetFileContent($Filename);

    return if $Code =~ m{\A#\s*VERSION:\s*1\.1\b};

    return if $Code !~ m{no \s warnings \s (?:\'|\")redefine(?:\'|\");}xms;
    return if $Code =~ m{sub \s+ Load \s+ \{}xms;

    my $ErrorMessage = <<EOF;
ATTENTION! Possible memory leak detected. Please use config VERSION:1.1 'sub Load {' functionality to avoid this. See 'Znuny4OTRS-Repo/Kernel/Config/Files/ZZZZZZnuny4OTRSRepo.pm' for an example.
EOF

    $Self->AddErrorMessage($ErrorMessage);

    return;
}

1;
