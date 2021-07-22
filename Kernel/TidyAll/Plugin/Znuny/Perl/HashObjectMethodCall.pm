# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::HashObjectMethodCall;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

# This filter prevents direct method calls to objects within hash assignments.
sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Code =~ m{^ \# \s+ \$origin}xms;

    my $HashObjectMethodCallLines = '';
    my $LineCounter               = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {

        $LineCounter++;

        next LINE if $Line =~ m{\A\s*#};

        # Ignore $ConfigObject->Get()
        next LINE if $Line =~ m{=>\s+\$ConfigObject->Get\(};

        # Ignore ->RandomID()
        next LINE if $Line =~ m{=>\s*\$.*?Object->GetRandomID\(};

        # e.g. Coffee => $CoffeObject->Get()
        next LINE if $Line !~ m{=>\s*\$.*?Object->.*?\(};

        $HashObjectMethodCallLines .= "\n\tLine $LineCounter: $Line";
    }

    return if !length $HashObjectMethodCallLines;

    my $Message  = <<EOF;
Object method calls in hash assignment found:
$HashObjectMethodCallLines
EOF

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

    return;
}

1;
