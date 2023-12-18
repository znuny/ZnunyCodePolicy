# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Documentation::Title;

use strict;
use warnings;


use File::Basename;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for default documentation tiles (en/de).

=cut

sub validate_file {    ## no critic
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my $Code = $Self->GetFileContent($Filename);


    my $Basename = basename $Filename;
    my ( $FileBasename, $FileExtension ) = $Basename =~ /([\w_\-.]+\.(\w+?))$/;
    return if $FileExtension ne 'md';

    my $Dir = dirname($Filename);

    my $Language = $Dir;
    $Language =~ s{\A.*\/doc\/(.*)\z}{$1};

    $Self->_CheckTitle(
        Code     => $Code,
        Language => $Language,
        Filename => $Basename,
    );

    return;
}

sub _CheckTitle {
    my ( $Self, %Param ) = @_;

    my $Code = $Param{Code};

    my %TitleMapping = (
        de => {
            'feature.md' => '# Funktionalität',
            'config.md'  => '# Konfiguration',
        },
        en => {
            'feature.md' => '# Functionality',
            'config.md'  => '# Configuration',
        },
    );

    my @Line = split /\n/, $Code;
    my $ExpectedTitle = $TitleMapping{ $Param{Language} }->{ $Param{Filename} };

    return 1 if !$ExpectedTitle;

    if ( !@Line ) {
        $Self->AddErrorMessage(
            "The documentation file '$Param{Language}/$Param{Filename}' is empty."
        );
        return;
    }

    # Check the title of current documentation
    if (
        $Line[0] !~ m{^$ExpectedTitle$}ms
        )
    {

        my $ErrorMessage = <<EOF;
The title for this documentation file ($Param{Language}/$Param{Filename}) is not correct ($Line[0]).
Following title is expected: ($ExpectedTitle)
EOF

        $Self->AddErrorMessage($ErrorMessage);
    }

}

1;
