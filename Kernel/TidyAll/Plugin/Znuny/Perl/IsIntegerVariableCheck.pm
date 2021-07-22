# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::IsIntegerVariableCheck;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks warns developers to avoid using IsInteger and IsPositiveInteger (expensive)

=cut

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage = '';
    my $Counter = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line =~ m{^ \#}smx;

        next LINE if $Line !~ m{looks_like_number}smx;

        $ErrorMessage .= "\nLine $Counter: $Line";
    }

    return if !length $ErrorMessage;

    my $FilePath = $Self->FilePath($Code);
    my $Message  = <<EOF;
NOTICE: Avoid looks_like_number since the result is not consistent on different systems.
Use IsInteger() and IsPositiveInteger().
$ErrorMessage
EOF

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
        FilePath => $FilePath,
    );

    return;
}

1;
