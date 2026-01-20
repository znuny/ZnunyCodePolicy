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

my $InvisibleCharsClass = '[\x{00A0}\x{00AD}\x{034F}\x{061C}\x{200B}-\x{200F}\x{202A}-\x{202F}\x{205F}\x{2060}-\x{2065}\x{FEFF}]';
my $InvisibleOptional   = "(?:$InvisibleCharsClass)*";
my $CopyrightPattern    = _WordPatternWithInvisibleGaps('Copyright');
my $ZnunyPattern        = _WordPatternWithInvisibleGaps('Znuny');
my $OTRSPattern         = _WordPatternWithInvisibleGaps('OTRS');
my $CommentLeader       = qr{\s*(?:\#|//|/\*)\s*};


sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $Context = $Self->GetZnunyVendorContext();
    return $Code if !$Context;

    my $CopyrightString = $Self->GetZnunyCopyrightString($Context);
    return $Code if !$CopyrightString;

    # Check if a Znuny copyright is already present and replace it with the updated one.
    if ( $Code =~ m{^$CommentLeader.*?$CopyrightPattern.*?$ZnunyPattern}m ) {
        $Code =~ s{^($CommentLeader).*?$CopyrightPattern.*?$ZnunyPattern.*$}{$1$CopyrightString}mg;
        return $Code;
    }

    # Add a Znuny copyright under an existing OTRS copyright.
    if ( $Code =~ m{^$CommentLeader.*?$CopyrightPattern.*?$OTRSPattern}m ) {
        $Code =~ s{^($CommentLeader)(.*?$CopyrightPattern.*?$OTRSPattern.*$)}{$1$2\n$1$CopyrightString}mg;
        return $Code;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code =~ m{^$CommentLeader.*?$CopyrightPattern.*?$ZnunyPattern}m;

    my $Context = $Self->GetZnunyVendorContext();
    return if !$Context;

    my $CopyrightString = $Self->GetZnunyCopyrightString($Context);
    return if !$CopyrightString;

    my $Message = "File is missing copyright in header section. Add the following string:\n\n"
        . "$CopyrightString\n";

    $Self->AddErrorMessage($Message);

    return;
}

sub _WordPatternWithInvisibleGaps {
    my ($Word) = @_;

    my @Chars = map { quotemeta $_ } split //, $Word;
    my $Pattern = join $InvisibleOptional, @Chars;

    return qr/$Pattern/i;
}

1;
