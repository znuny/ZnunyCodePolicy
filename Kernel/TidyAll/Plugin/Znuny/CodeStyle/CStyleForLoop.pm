# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::CodeStyle::CStyleForLoop;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code =~ m{^ \# \s+ \$origin}xms;

    my $Counter      = 0;
    my $ErrorMessage = '';
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line =~ m{^ \#}smx;

        next LINE if $Line !~ m{\A \s* for \s+ \( \s* (my)? \s* (\$|;)}smx;

        $ErrorMessage .= "\n\tLine $Counter: $Line";
    }

    return if !length $ErrorMessage;

    my $FilePath = $Self->FilePath($Code);
    my $Message  = "NOTICE: Avoid C-style for-loops if possible.\n$ErrorMessage";

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
        FilePath => $FilePath,
    );

    return;
}

1;
