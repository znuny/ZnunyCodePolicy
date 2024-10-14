# --
# Copyright (C) 2012-2016 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::ObjectManagerDirectCall;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $IsFrameworkContext = $Self->GetSetting('Context::Framework');
    return if $IsFrameworkContext;

    return if $Code =~ m{no \s warnings \s 'redefine';}xms;
    return if $Code =~ m{^ \# \s+ \$origin}xms;

    my $DirectCallLines = '';
    my $LineCounter     = 0;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        next LINE if $Line !~ m{\$Kernel::OM->Get\('Kernel::[^']+'\)->};

        $DirectCallLines .= "Line $LineCounter: $Line\n";
    }

    return if !$DirectCallLines;

    my $Message = "Don't use direct object manager calls. Fetch the object in a separate variable first.\n"
        . "$DirectCallLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'notice',
    );

    return;
}

1;
