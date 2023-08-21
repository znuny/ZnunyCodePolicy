# --
# Copyright (C) 2012-2021 Znuny GmbH, http://znuny.com/
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

Checks for missing "use" statement for Kernel::System::VariableCheck.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

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

    return if $Code !~ $VariableCheckFunction && $Code !~ $VariableCheckUse;
    return if $Code =~ $VariableCheckFunction && $Code =~ $VariableCheckUse;

    my $Message;
    if ($Code =~ $VariableCheckFunction && $Code !~ $VariableCheckUse){
        $Message = "'use' statement for Kernel::System::VariableCheck is missing:\n"
        . "use Kernel::System::VariableCheck qw(:all);";

        $Self->AddErrorMessage($Message);
    }

    if ($Code !~ $VariableCheckFunction && $Code =~ $VariableCheckUse){
        $Message = "'use' statement for Kernel::System::VariableCheck is used, but no VariableCheck function was ever used.";

        $Self->AddMessage(
            Message  => $Message,
            Priority => 'warning',
        );
    }


    return;
}

1;
