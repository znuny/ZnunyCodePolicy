# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2021 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Common::Contributors;

use strict;
use warnings;
use IO::File;
use utf8;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    my $RootDir = $Self->GetOTRSRootDir();
    chdir $RootDir;

    my @Lines = qx{git log --format="%aN <%aE>"};
    my %Seen;
    map { $Seen{$_}++ } @Lines;

    my $FileHandle = IO::File->new( 'AUTHORS.md', 'w' );
    $FileHandle->print("The following persons contributed to OTRS:\n\n");

    AUTHOR:
    for my $Author ( sort keys %Seen ) {

        chomp $Author;
        if ( $Author =~ m/^[^<>]+ \s <>\s?$/smx ) {
            $Self->Print("<yellow>Author $Author of commit could not be reliably determined.</yellow>\n");
            next AUTHOR;
        }
        $FileHandle->print("* $Author\n");
    }

    $FileHandle->close();

    my $FilePath = 'AUTHORS.md';
    my $Message  = "Updated 'AUTHORS.md'";

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'success',
        Message  => $Message,
        FilePath => $FilePath,
    );

    return $Code;
}

1;
