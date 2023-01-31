# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::DBObject;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
#         next LINE if $Line !~ m{\bKernel::System::DB(\b|::)}sm;
        next LINE if $Line !~ m{^[^#]*?\bKernel::System::DB(\b|::)}m;

        $ErrorMessage .= "Line $Counter: $Line\n";
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Don't use Kernel::System::DB in frontend modules.
$ErrorMessage
EOF
    }

    return;
}

1;
