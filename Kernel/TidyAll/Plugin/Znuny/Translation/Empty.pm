# --
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Translation::Empty;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for empty language files.

=cut

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    return if $Filename !~ m{\.pm\z};

    my $Code = $Self->GetFileContent($Filename);

    return if $Code =~ m{\$Self\-\>\{(Translation|JavaScriptStrings)\}}ms;

    $Self->AddMessage(
        Message  => 'Language file seems to not contain any translations.',
        Priority => 'warning',
    );

    return;
}

1;
