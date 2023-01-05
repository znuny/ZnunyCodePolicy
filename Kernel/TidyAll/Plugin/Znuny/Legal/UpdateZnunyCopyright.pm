# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $Context = $Self->GetZnunyVendorContext();
    return $Code if !$Context;

    my $CopyrightString = $Self->GetZnunyCopyrightString($Context);
    return $Code if !$CopyrightString;

    # Check if a Znuny copyright is already present and replace it with the updated one.
    if ( $Code =~ m{^.*?Copyright.*?Znuny}m ) {
        $Code =~ s{^(.*?)Copyright.*?Znuny.*$}{$1$CopyrightString}mg;
        return $Code;
    }

    # Add a Znuny copyright under an existing OTRS copyright.
    if ( $Code =~ m{^.*?Copyright.*?OTRS}m ) {
        $Code =~ s{(^(.*?)Copyright.*?OTRS.*$)}{$1\n$2$CopyrightString}m;
        return $Code;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code =~ m{^.*?Copyright.*?Znuny}m;

    my $Context = $Self->GetZnunyVendorContext();
    return if !$Context;

    my $CopyrightString = $Self->GetZnunyCopyrightString($Context);
    return if !$CopyrightString;

    my $Message = "File is missing copyright in header section. Add the following string:\n\n"
        . "$CopyrightString\n";

    $Self->AddErrorMessage($Message);

    return;
}

1;
