# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::TODOCheck;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for "todo"s in comments.

=cut

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );
    return if $TidyAll::Znuny::SkipTodos;

    my $LineCounter = 0;
    my $TODOLine    = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        my $LowerCaseLine = lc($Line);
        next LINE if $LowerCaseLine !~ m{todo}smx;

        $TODOLine .= "\tLine $LineCounter: $Line\n";
    }

    my $ErrorMessage = '';
    if ( length $TODOLine ) {
        $ErrorMessage .= "NOTICE: Please pay attention to maybe not completed tasks:\n\n" . $TODOLine;
    }

    return if !length $ErrorMessage;

    my $FilePath = $Self->FilePath($File);

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $ErrorMessage,
        FilePath => $FilePath,
    );
}
1;
