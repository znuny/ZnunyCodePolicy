# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Perl::HTMLUtils;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

=head1 SYNOPSIS

This plugin checks for calls to Kernel::System::HTMLUtils::DocumentComplete and informs
developers that the 'UserType' parameter is required.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan('7.2');

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    my ( $ErrorMessage, $Counter );

    # Return if no DocumentComplete exists
    return if $Code !~ m{^[^#]*?\bDocumentComplete\s*\(}m;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # Look for calls to DocumentComplete function
        next LINE if $Line !~ m{^[^#]*?\bDocumentComplete\s*\(}m;

        # Check if it's specifically HTMLUtils::DocumentComplete
        if ( $Line =~ m{^[^#]*?\b(?:HTMLUtils|Kernel::System::HTMLUtils)->DocumentComplete\s*\(}m
            || $Line =~ m{^[^#]*?\$.*?HTMLUtils.*?->DocumentComplete\s*\(}m ) {

            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Found calls to Kernel::System::HTMLUtils::DocumentComplete.
This function requires the 'UserType' parameter to work correctly.
Please ensure you pass the UserType parameter in your function call.

$ErrorMessage
EOF
    }

    return;
}

1;
