# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::ObjectManagerDirectCall;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Code =~ m{no \s warnings \s 'redefine';}xms;
    return if $Code =~ m{^ \# \s+ \$origin}xms;

    my $DirectCallLines = '';
    my $LineCounter     = 0;

    LINE:
    for my $Line ( split /\n/, $Code ) {

        $LineCounter++;

        next LINE if $Line !~ m{\$Kernel::OM->Get\('Kernel::[^']+'\)->};

        $DirectCallLines .= "\tLine $LineCounter: $Line\n";
    }

    return if !$DirectCallLines;

    my $Message = "Direct ObjectManager call found:"
        . "\n\n$DirectCallLines";

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

    return;
}

1;
