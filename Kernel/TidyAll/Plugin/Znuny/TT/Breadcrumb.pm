# --
# Copyright (C) 2012-2019 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::TT::Breadcrumb;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks for missing unit test in package

=cut

sub validate_file {    ## no critic
    my ( $Self, $File ) = @_;

    my $Code = $Self->_GetFileContents($File);
    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );
    return if $Code =~ m{\[% INCLUDE "Breadcrumb\.tt" Path = BreadcrumbPath %\]};

    my $Message = 'Found no Breadcrumb / BreadcrumbPath.\n'
        . 'Please add a valid BreadcrumbPath to this template.'
        . '[% INCLUDE "Breadcrumb.tt" Path = BreadcrumbPath %]'
        . '[See: https://github.com/OTRS/otrs/blob/rel-6_0/Kernel/Output/HTML/Templates/Standard/AdminUser.tt#L13';

    $Self->Print(
        Package  => __PACKAGE__,
        Priority => 'notice',
        Message  => $Message,
    );

}

1;
