# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::Pod::FunctionPod;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $FunctionNameInPod = '';
    my $FunctionLineInPod = '';
    my $FunctionCallInPod = '';
    my $Counter           = 0;

    my $ErrorMessage;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $Counter++;
        if ( $Line =~ m{^=head2 \s+ ([A-Za-z0-9]+) (\(\))? \s* $}smx ) {

            my $FunctionName  = $1;
            my $IsFunctionPod = $2 ? 1 : 0;

            if ($IsFunctionPod) {
                $FunctionNameInPod = $FunctionName;
                $FunctionLineInPod = $Line;
                chomp($FunctionLineInPod);
            }
            elsif ( $Code =~ m{sub $FunctionName} ) {
                $ErrorMessage
                    .= "=head2 does not match function name or is missing parentheses (near line $Counter). The line should look something like '=head2 MyFunctionName()'\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
        if ( $FunctionNameInPod && $Line =~ /->(.+?)\(/ && !$FunctionCallInPod ) {
            $FunctionCallInPod = $1;
            $FunctionCallInPod =~ s/ //;

            if ( $Line =~ /\$Self->/ ) {
                $ErrorMessage .= "Don't use \$Self in perldoc\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            elsif ( $FunctionNameInPod ne $FunctionCallInPod ) {
                if ( $FunctionNameInPod ne 'new' || ( $FunctionCallInPod ne 'Get' && $FunctionCallInPod ne 'Create' ) )
                {
                    my $DescriptionLine = $Line;
                    chomp($DescriptionLine);
                    $ErrorMessage .= "$FunctionLineInPod <-> $DescriptionLine\n";
                }
            }
            if ( $FunctionNameInPod && $Line !~ /\$[A-Za-z0-9:]+->(.+?)\(/ && $FunctionNameInPod ne 'new' ) {
                $ErrorMessage .= "The function syntax is not correct!\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
        if ( $FunctionNameInPod && $Line =~ /sub/ ) {
            if ( $Line =~ /sub (.+) \{/ ) {
                my $FunctionSub = $1;
                $FunctionSub =~ s/ //;
                my $SubLine = $Line;

                if ( $FunctionSub ne $FunctionNameInPod ) {
                    chomp($SubLine);
                    $ErrorMessage .= "$FunctionLineInPod <-> $SubLine \n";
                }
            }
            $FunctionNameInPod = '';
            $FunctionCallInPod = '';
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }

    return;
}

1;
