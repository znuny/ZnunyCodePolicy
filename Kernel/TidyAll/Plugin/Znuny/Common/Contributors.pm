# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Common::Contributors;

use strict;
use warnings;

use utf8;

use Encode;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Updates AUTHORS.md with authors of Git repository.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    my $RootDir = $Self->GetSetting('TidyAll::RootDir');
    chdir $RootDir;

    my @Authors = qx{git log --format="%aN <%aE>"};
    my %Authors = map { $_ => 1 } @Authors;

    my $AuthorContent = "The following persons contributed to Znuny:\n\n";

    my %ProblematicAuthors;

    AUTHOR:
    for my $Author ( sort keys %Authors ) {
        chomp $Author;

        if ( $Author =~ m{^[^<>]+ \s <>\s?$}smx ) {
            $ProblematicAuthors{$Author} = 1;
            next AUTHOR;
        }

        $AuthorContent .= "* $Author\n";
    }

    return $AuthorContent if !%ProblematicAuthors;

    my $ProblematicAuthors = join "\n", sort keys %ProblematicAuthors;

    $Self->AddErrorMessage(
        "The following authors could not reliably be determined:\n$ProblematicAuthors",
    );

    # Return unchanged code.
    return $Code;
}

1;
