# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line !~ m{(print\s+STDERR)};

        my $PrintSTDERRPosition = index( $Line, $1 );
        my $CommentPosition     = index( $Line, '#' );

        next LINE if $CommentPosition != -1 && $CommentPosition < $PrintSTDERRPosition;

        $ErrorMessage .= "Line $Counter: $Line\n";
    }

    return if !length $ErrorMessage;

    my $Message = "Don't forget to remove debug code like `print STDERR (...)\n$ErrorMessage";

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

    return;
}

1;
