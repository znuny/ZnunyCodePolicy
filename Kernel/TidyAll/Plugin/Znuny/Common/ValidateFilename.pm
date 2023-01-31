# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Common::ValidateFilename;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Performs basic filename checks.

=cut

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my @ForbiddenCharacters = (
        ' ', "\n", "\t", '"', '`', '´', '\'', '$', '!', '?,', '*',
        '(', ')', '{', '}', '[', ']', '#', '<', '>', ':', '\\', '|',
    );

    for my $ForbiddenCharacter (@ForbiddenCharacters) {
        if ( index( $Filename, $ForbiddenCharacter ) != -1 ) {
            my $ForbiddenList = join( ' ', @ForbiddenCharacters );
            $Self->AddErrorMessage(<<"EOF");
Forbidden character '$ForbiddenCharacter' found in file name.
You should not use these characters in file names: $ForbiddenList.
EOF
        }
    }

    return;
}

1;
