# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::UTF8;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks if "use utf8" is present in Perl files.

=cut

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );
    return if $Filename !~ m{\.(pl|pm|t)\z};

    my $Code = $Self->GetFileContent($Filename);
    return if $Code =~ m{^\s*use\s*utf8\s*;}m;

    $Self->AddMessage(
        Message  => 'Check if file has UTF-8 encoding and consider adding "use utf8;" to prevent encoding problems.',
        Priority => 'warning', # or: success, transform, warning, notice
    );

    return;
}

1;
