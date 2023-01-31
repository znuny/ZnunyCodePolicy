# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Autoload::ObjectManagerDisabled;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks if object manager is disabled in autoload module which is not allowed because
it leads to server errors.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    return if $Code !~ m{(\A|\r?\n)\s*our\s+\$ObjectManagerDisabled\s*=\s*1\s*;}sm;

    my $Message = "Don't disable object manager in autoload modules. It leads to server errors.";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'notice',
    );

    return;
}

1;
