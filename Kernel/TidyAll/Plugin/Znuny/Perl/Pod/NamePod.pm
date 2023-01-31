# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::Pod::NamePod;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't modify files which are derived files (have change markers).
    if ( $Code =~ m{ ^ \s* \# \s* \$origin: }xms ) {
        return $Code;
    }

    my $PackageName = '';
    my $InsideNamePod;
    my $PackageNamePod;
    my $Updated = 0;

    my @CodeLines = split /\n/, $Code;

    LINE:
    for my $Line (@CodeLines) {
        if ( $Line =~ m{^package \s+? ([A-Za-z0-9:]+?);}smx ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $Line =~ m{^=head1 \s+ NAME \s* $}smx ) {
            $InsideNamePod = 1;
            next LINE;
        }

        next LINE if !$InsideNamePod;
        next LINE if !$Line;
        last LINE if $Line =~ m{^=cut \s* $}smx;
        last LINE if $Line =~ m{^=head1}smx;

        if ( $Line =~ m{^\s* ([A-Za-z0-9:/\.]+)}smx ) {
            $PackageNamePod = $1;
            if ( $PackageName ne $PackageNamePod ) {
                $Line =~ s{^\s* ([A-Za-z0-9:/\.]+)}{$PackageName}smx;
                $Updated = 1;
            }
            last LINE;
        }
    }

    if ($Updated) {
        $Code = join "\n", @CodeLines;
        $Code .= "\n";
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't check files which are derived files (have change markers).
    if ( $Code =~ m{ ^ \s* \# \s* \$origin: }xms ) {
        return $Code;
    }

    my $PackageName = '';
    my $InsideNamePod;
    my $PackageNamePod;
    my $Counter = 0;
    my $ErrorMessage;

    my @CodeLines = split /\n/, $Code;

    LINE:
    for my $Line (@CodeLines) {
        $Counter++;

        if ( $Line =~ m{^package \s+? ([A-Za-z0-9:]+?);}smx ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $Line =~ m{^=head1 \s+ NAME \s* $}smx ) {
            $InsideNamePod = 1;
            next LINE;
        }

        next LINE if !$InsideNamePod;
        next LINE if !$Line;
        last LINE if $Line =~ m{^=cut \s* $}smx;
        last LINE if $Line =~ m{^=head1}smx;

        if ( $Line =~ m{^\s* ([A-Za-z0-9:/\.]+)}smx ) {
            $PackageNamePod = $1;
            if ( $PackageName ne $PackageNamePod ) {
                $ErrorMessage = "Package name $PackageNamePod does not match package $PackageName\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            last LINE;
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }

    return;
}

1;
