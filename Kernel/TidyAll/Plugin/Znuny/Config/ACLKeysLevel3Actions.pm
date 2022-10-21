# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Config::ACLKeysLevel3Actions;

use strict;
use warnings;

use base qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for new dynamic field screen registrations in SysConfig (xml).

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my %Check = (
        NewFrontendRegEx => "\<Setting Name\=\"Frontend::Module\#\#\#(.*)",
        AdditionalRegEx  => "\<Setting Name\=\"ACLKeysLevel3::Actions\#\#\#.*",
        Findings         => [],
        Registered       => 0,
    );

    my $LineCounter = 0;
    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        last LINE if $Check{Registered};

        if ( $Line =~ /$Check{AdditionalRegEx}/ ) {
            $Check{Registered} = 1;
        }

        if ( $Line =~ /$Check{NewFrontendRegEx}/ ) {
            push @{ $Check{Findings} }, "Line $LineCounter: $Line";
        }
    }


    my $ErrorMessage = '';

    return if $Check{Registered};
    return if !@{ $Check{Findings} };

    $ErrorMessage
        .= "Found frontend module registration but no ACLKeysLevel3::Actions registration for the following:";

    for my $Lines ( @{ $Check{Findings} } ) {
        $ErrorMessage .= "\n\t$Lines";
    }

    $Self->AddMessage(
        Message  => $ErrorMessage,
        Priority => 'notice',
    );
}

1;
