# --
# Copyright (C) 2012-2017 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Deprecated::AjaxAttachment;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for renamed AjaxAttachment module (Renamed to AJAXAttachment in 7.2).

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan('7.2');

    # Rename AjaxAttachment to AJAXAttachment
    $Code =~ s{(AjaxAttachment)}{AJAXAttachment}g;

    return $Code;
}

1;
