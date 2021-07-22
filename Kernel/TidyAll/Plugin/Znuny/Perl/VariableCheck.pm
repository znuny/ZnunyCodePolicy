# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::VariableCheck;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for missing uses of the variablecheck if functions are used.

=cut

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );

    my $VariableCheckFunction = qr{
        (
            IsString
            | IsStringWithData
            | IsArrayRefWithData
            | IsHashRefWithData
            | IsNumber
            | IsInteger
            | IsPositiveInteger
            | IsIPv4Address
            | IsIPv6Address
            | IsMD5Sum
            | DataIsDifferent
        )\(
    }xmsi;

    my $VariableCheckUse = qr{ use \s Kernel\:\:System\:\:VariableCheck }xmsi;

    return if $Code !~ $VariableCheckFunction;
    return if $Code =~ $VariableCheckUse;

    my $Message = "Man... It's nice that you are using the variable check function but you forgot the use:"
    ."\n\nuse Kernel::System::VariableCheck qw(:all);";

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

    return;
}

1;
