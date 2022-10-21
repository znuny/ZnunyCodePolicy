# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::ISA;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # remove useless use vars qw(@ISA); (where ISA is not used)
    if ( $Code !~ m{\@ISA.*\@ISA}smx ) {
        $Code =~ s{^use \s+ vars \s+ qw\(\@ISA\);\n+}{}smx;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Don't allow push @ISA.
    if ( $Code =~ m{push\(?\s*\@ISA }xms ) {
        $Self->AddErrorMessage(<<"EOF");
Don't push to \@ISA. This can cause problems in persistent environments.
Use Kernel::System::Main::RequireBaseClass() instead.
EOF
    }

    return;
}

1;
