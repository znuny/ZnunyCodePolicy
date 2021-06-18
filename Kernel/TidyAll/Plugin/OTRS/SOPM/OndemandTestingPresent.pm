# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::OTRS::SOPM::OndemandTestingPresent;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTRS::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my $OndemandTestingPresent = grep { $_ =~ m{[.]otrs-ci[.]yml} } @TidyAll::OTRS::FileList;

    if ( !$OndemandTestingPresent ) {
        return $Self->DieWithError(
            "Every package needs to contain an active OnDemand testing configuration (.otrs-ci.yml).\n"
        );
    }
}

1;
