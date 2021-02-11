# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2021 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Legal::UpdateZnunyCopyright;
## nofilter(TidyAll::Plugin::OTRS::Perl::Time)

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't replace copyright in thirdparty code.
    return $Code if $Self->IsThirdpartyModule();

    my $Copyright = $Self->GetZnunyCopyrightString();

    # Only changed files will be updated.
    # This allows to run the code policy for unchanged files without updating
    # the copyright.
    my $FilePath      = $Self->FilePath($Code);
    my $FileIsChanged = $Self->IsFileChanged($FilePath);
    return $Code if !$FileIsChanged;

    #
    # Check if a Znuny copyright is already present and replace it with the current one.
    #
    if ( $Code =~ m{^.*?Copyright.*?Znuny}m ) {
        $Code =~ s{^(.*?)Copyright.*?Znuny.*?$}{$1$Copyright}mg;
        return $Code;
    }

    #
    # Add a Znuny copyright under an existing OTRS copyright.
    #
    if ( $Code =~ m{^.*?Copyright.*?OTRS}m ) {
        $Code =~ s{(^(.*?)Copyright.*?OTRS.*?$)}{$1\n$2$Copyright}m;
        return $Code;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Don't warn about missing copyright in thirdparty code.
    return $Code if $Self->IsThirdpartyModule();

    # Only changed files will be updated.
    # This allows to run the code policy for unchanged files without updating
    # the copyright.
    my $FilePath      = $Self->FilePath($Code);
    my $FileIsChanged = $Self->IsFileChanged($FilePath);
    return $Code if !$FileIsChanged;

    return if $Code =~ m{^.*?Copyright.*?Znuny}m;

    my $Copyright = $Self->GetZnunyCopyrightString();

    my $Message = "File is missing copyright in header section. Add the following string:\n\n"
        . "$Copyright\n";

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'error',
        Message  => $Message,
        FilePath => $FilePath,
    );

    return;
}

1;
